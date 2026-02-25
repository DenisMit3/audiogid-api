import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';

/**
 * Server-side upload proxy for audio files.
 * 
 * Strategy: Get presigned URL from backend, then:
 * 1. If URL contains localhost:9000 - replace with public MinIO URL and try
 * 2. If that fails - return error with instructions
 */

const BACKEND_URL = process.env.BACKEND_URL || process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';
const MINIO_PUBLIC_URL = process.env.MINIO_PUBLIC_URL || 'http://82.202.159.64:9000';

export async function POST(request: NextRequest) {
    try {
        const cookieStore = cookies();
        const token = cookieStore.get('token');
        const bearerToken = token?.value;
        
        console.log('Upload-audio: Auth check', { 
            hasCookieToken: !!token?.value,
            tokenLength: bearerToken?.length,
            backendUrl: BACKEND_URL
        });
        
        if (!bearerToken) {
            return NextResponse.json({ error: 'Not authenticated. Please login again.' }, { status: 401 });
        }

        const formData = await request.formData();
        const file = formData.get('file') as File;
        const entityType = formData.get('entity_type') as string || 'uploads';
        const entityId = formData.get('entity_id') as string || '';

        if (!file) {
            return NextResponse.json({ error: 'No file provided' }, { status: 400 });
        }

        // Validate file type
        const allowedTypes = ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/ogg'];
        if (!allowedTypes.includes(file.type)) {
            return NextResponse.json({ 
                error: 'Invalid file type', 
                detail: `Allowed: ${allowedTypes.join(', ')}` 
            }, { status: 400 });
        }

        // Validate file size (50MB max)
        const maxSize = 50 * 1024 * 1024;
        if (file.size > maxSize) {
            return NextResponse.json({ 
                error: 'File too large', 
                detail: 'Maximum size is 50MB' 
            }, { status: 400 });
        }

        // Step 1: Try direct upload endpoint first (if available on server)
        console.log('Upload-audio: Trying direct upload endpoint...');
        
        const directFormData = new FormData();
        directFormData.append('file', file);
        directFormData.append('entity_type', entityType);
        if (entityId) {
            directFormData.append('entity_id', entityId);
        }

        const directRes = await fetch(`${BACKEND_URL}/admin/media/upload`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${bearerToken}`,
            },
            body: directFormData,
            // @ts-ignore - duplex is required for Node.js 18+ when sending body
            duplex: 'half',
        });

        if (directRes.ok) {
            const result = await directRes.json();
            console.log('Upload-audio: Direct upload success', result);
            return NextResponse.json({
                url: result.url,
                filename: result.filename || file.name,
                size: result.size || file.size,
            });
        }

        // If direct upload returns 404, fall back to presign method
        if (directRes.status !== 404) {
            const errorText = await directRes.text();
            console.error('Upload-audio: Direct upload failed', directRes.status, errorText);
            return NextResponse.json({ 
                error: 'Upload failed',
                detail: errorText,
            }, { status: directRes.status });
        }

        console.log('Upload-audio: Direct upload not available (404), trying presign method...');

        // Step 2: Get presigned URL from backend
        const presignRes = await fetch(`${BACKEND_URL}/admin/media/presign`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${bearerToken}`,
            },
            body: JSON.stringify({
                filename: file.name.replace(/[^a-zA-Z0-9._-]/g, '_'),
                content_type: file.type,
                entity_type: entityType,
                entity_id: entityId || undefined,
            }),
        });

        if (!presignRes.ok) {
            const errorText = await presignRes.text();
            console.error('Upload-audio: Presign failed', presignRes.status, errorText);
            return NextResponse.json({ 
                error: 'Failed to get upload URL',
                detail: errorText,
            }, { status: presignRes.status });
        }

        const presignData = await presignRes.json();
        let { upload_url, final_url } = presignData;

        console.log('Upload-audio: Got presigned URL', { 
            original: upload_url.substring(0, 80) + '...',
            final_url: final_url.substring(0, 80) + '...'
        });

        // Step 3: Replace localhost with public URL if needed
        if (upload_url.includes('localhost:9000')) {
            upload_url = upload_url.replace('http://localhost:9000', MINIO_PUBLIC_URL);
            console.log('Upload-audio: Replaced localhost with public URL', upload_url.substring(0, 80) + '...');
        }

        // Step 4: Upload file to MinIO
        const fileBuffer = await file.arrayBuffer();
        
        let uploadRes;
        try {
            uploadRes = await fetch(upload_url, {
                method: 'PUT',
                body: fileBuffer,
                headers: {
                    'Content-Type': file.type,
                },
                // @ts-ignore - duplex is required for Node.js 18+ when sending body
                duplex: 'half',
            });
        } catch (uploadError: any) {
            console.error('Upload-audio: MinIO connection error', uploadError);
            
            const errorCode = uploadError.cause?.code || '';
            const errorMsg = String(uploadError);
            
            if (errorCode === 'ECONNREFUSED' || errorCode === 'UND_ERR_CONNECT_TIMEOUT' || 
                errorMsg.includes('ECONNREFUSED') || errorMsg.includes('timeout')) {
                return NextResponse.json({ 
                    error: 'Хранилище файлов недоступно',
                    detail: 'Порт 9000 (MinIO) закрыт на сервере. Для загрузки файлов необходимо открыть порт 9000 в настройках сервера Cloud.ru или обновить API на сервере.',
                    technical: `${errorCode}: ${upload_url.split('?')[0]}`
                }, { status: 503 });
            }
            
            throw uploadError;
        }

        if (!uploadRes.ok) {
            const errorText = await uploadRes.text();
            console.error('Upload-audio: MinIO upload failed', uploadRes.status, errorText);
            return NextResponse.json({ 
                error: 'Upload to storage failed',
                detail: `Status: ${uploadRes.status}`,
            }, { status: 502 });
        }

        console.log('Upload-audio: Success!', final_url);

        return NextResponse.json({
            url: final_url,
            filename: file.name,
            size: file.size,
        });

    } catch (error) {
        console.error('Upload-audio: Server error', error);
        return NextResponse.json({ 
            error: 'Upload failed',
            detail: String(error),
        }, { status: 500 });
    }
}
