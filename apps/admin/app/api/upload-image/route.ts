import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';

/**
 * Server-side upload proxy for image files.
 * Similar to upload-audio but for images (cover images, etc.)
 */

const BACKEND_URL = process.env.BACKEND_URL || process.env.NEXT_PUBLIC_API_URL || 'http://82.202.159.64/v1';
const MINIO_PUBLIC_URL = process.env.MINIO_PUBLIC_URL || 'http://82.202.159.64:9000';

export async function POST(request: NextRequest) {
    try {
        const cookieStore = cookies();
        const token = cookieStore.get('token');
        const bearerToken = token?.value;
        
        console.log('Upload-image: Auth check', { 
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
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'];
        if (!allowedTypes.includes(file.type)) {
            return NextResponse.json({ 
                error: 'Invalid file type', 
                detail: `Allowed: ${allowedTypes.join(', ')}` 
            }, { status: 400 });
        }

        // Validate file size (10MB max for images)
        const maxSize = 10 * 1024 * 1024;
        if (file.size > maxSize) {
            return NextResponse.json({ 
                error: 'File too large', 
                detail: 'Maximum size is 10MB' 
            }, { status: 400 });
        }

        console.log('Upload-image: Getting presigned URL...');

        // Get presigned URL from backend
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
            console.error('Upload-image: Presign failed', presignRes.status, errorText);
            return NextResponse.json({ 
                error: 'Failed to get upload URL',
                detail: errorText,
            }, { status: presignRes.status });
        }

        const presignData = await presignRes.json();
        let { upload_url, final_url } = presignData;

        console.log('Upload-image: Got presigned URL', { 
            original: upload_url.substring(0, 80) + '...',
            final_url: final_url.substring(0, 80) + '...'
        });

        // Replace localhost with public URL if needed
        if (upload_url.includes('localhost:9000')) {
            upload_url = upload_url.replace('http://localhost:9000', MINIO_PUBLIC_URL);
            console.log('Upload-image: Replaced localhost with public URL');
        }

        // Upload file to MinIO
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
            console.error('Upload-image: MinIO connection error', uploadError);
            
            const errorCode = uploadError.cause?.code || '';
            const errorMsg = String(uploadError);
            
            if (errorCode === 'ECONNREFUSED' || errorCode === 'UND_ERR_CONNECT_TIMEOUT' || 
                errorMsg.includes('ECONNREFUSED') || errorMsg.includes('timeout')) {
                return NextResponse.json({ 
                    error: 'Хранилище файлов недоступно',
                    detail: 'Порт 9000 (MinIO) закрыт на сервере.',
                    technical: `${errorCode}: ${upload_url.split('?')[0]}`
                }, { status: 503 });
            }
            
            throw uploadError;
        }

        if (!uploadRes.ok) {
            const errorText = await uploadRes.text();
            console.error('Upload-image: MinIO upload failed', uploadRes.status, errorText);
            return NextResponse.json({ 
                error: 'Upload to storage failed',
                detail: `Status: ${uploadRes.status}`,
            }, { status: 502 });
        }

        console.log('Upload-image: Success!', final_url);

        return NextResponse.json({
            url: final_url,
            filename: file.name,
            size: file.size,
        });

    } catch (error) {
        console.error('Upload-image: Server error', error);
        return NextResponse.json({ 
            error: 'Upload failed',
            detail: String(error),
        }, { status: 500 });
    }
}
