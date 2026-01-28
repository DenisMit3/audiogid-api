
"use client"

import React, { useCallback, useState } from 'react'
import { useDropzone } from 'react-dropzone'
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { UploadCloud, FileAudio, ImageIcon, Loader2 } from 'lucide-react'

interface MediaUploadProps {
    onUploadComplete: (url: string, fileType: string) => void
    accept?: Record<string, string[]>
}

export function MediaUpload({ onUploadComplete, accept }: MediaUploadProps) {
    const [uploading, setUploading] = useState(false);

    const onDrop = useCallback(async (acceptedFiles: File[]) => {
        const file = acceptedFiles[0];
        if (!file) return;

        setUploading(true);
        try {
            // 1. Get Token
            // Filename must be url encoded
            const res = await fetch(`/api/proxy/v1/admin/media/upload-token?filename=${encodeURIComponent(file.name)}`, {
                method: 'POST',
                headers: {
                    // Need auth header? Proxy handles cookie? 
                    // We need to fetch via Client Proxy to add Cookie if HttpOnly?
                    // Wait, our middleware passes cookie. 
                    // But we should use a Next.js Server Action or Route Handler to simplify dev.
                    // The endpoint expects POST.
                    // IMPORTANT: We need correct auth. 
                    // If using our `api/proxy` pattern from Login page?
                    // We haven't implemented general proxy yet.
                    // Let's assume we implement a route handler /api/media/upload that calls backend.
                }
            });

            // Temporary Fake Upload since we mocked the token response
            // If real Vercel Blob:
            // const { url, fields } = await res.json();
            // const formData = new FormData();
            // Object.entries({...fields, file}).forEach(([key, value]) => formData.append(key, value as string));
            // const uploadRes = await fetch(url, { method: 'POST', body: formData });

            // Mock Implementation logic
            await new Promise(r => setTimeout(r, 1000));
            onUploadComplete(`https://placehold.co/600x400?text=${file.name}`, file.type);

        } catch (e) {
            console.error(e);
            alert("Upload failed");
        } finally {
            setUploading(false);
        }
    }, [onUploadComplete]);

    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        accept: accept || {
            'image/*': [],
            'audio/*': []
        },
        maxFiles: 1
    });

    return (
        <div {...getRootProps()} className="border-2 border-dashed border-gray-300 rounded-lg p-6 cursor-pointer hover:border-gray-400 transition-colors">
            <input {...getInputProps()} />
            <div className="flex flex-col items-center justify-center gap-2 text-center">
                {uploading ? (
                    <Loader2 className="h-8 w-8 animate-spin text-gray-500" />
                ) : (
                    <UploadCloud className="h-8 w-8 text-gray-400" />
                )}
                {isDragActive ? (
                    <p className="text-sm font-medium">Drop the files here ...</p>
                ) : (
                    <p className="text-sm font-medium text-gray-500">Drag & drop media here, or click to select</p>
                )}
                <p className="text-xs text-gray-400">Images or Audio (MP3)</p>
            </div>
        </div>
    )
}
