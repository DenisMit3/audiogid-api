'use client';

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Upload, X, Loader2, ImageIcon } from 'lucide-react';
import { Button } from "@/components/ui/button";

const API_URL = '/api/proxy';

type Props = {
    value?: string;
    onChange: (url: string) => void;
    entityType?: string;
    entityId?: string;
};

export function CoverImageUploader({ value, onChange, entityType = 'tours', entityId }: Props) {
    const [isUploading, setIsUploading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [preview, setPreview] = useState<string | null>(value || null);

    const uploadFile = async (file: File): Promise<string> => {
        const token = localStorage.getItem('admin_token');
        
        const formData = new FormData();
        formData.append('file', file);
        formData.append('entity_type', entityType);
        if (entityId) {
            formData.append('entity_id', entityId);
        }

        const res = await fetch(`${API_URL}/admin/media/upload`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`
            },
            body: formData
        });

        if (!res.ok) {
            const errData = await res.json().catch(() => ({}));
            throw new Error(errData.detail || 'Ошибка загрузки');
        }

        const data = await res.json();
        return data.url;
    };

    const onDrop = useCallback(async (acceptedFiles: File[]) => {
        const file = acceptedFiles[0];
        if (!file) return;

        setError(null);
        setIsUploading(true);

        // Validate
        const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
        if (!allowedTypes.includes(file.type)) {
            setError('Допускаются только изображения (JPEG, PNG, WebP, GIF)');
            setIsUploading(false);
            return;
        }

        const maxSize = 10 * 1024 * 1024; // 10MB
        if (file.size > maxSize) {
            setError('Файл слишком большой. Максимум 10MB');
            setIsUploading(false);
            return;
        }

        // Show local preview immediately
        const localPreview = URL.createObjectURL(file);
        setPreview(localPreview);

        try {
            const url = await uploadFile(file);
            setPreview(url);
            onChange(url);
        } catch (e: any) {
            setError(e.message || 'Ошибка загрузки');
            setPreview(value || null);
        } finally {
            setIsUploading(false);
            URL.revokeObjectURL(localPreview);
        }
    }, [onChange, value, entityType, entityId]);

    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        maxFiles: 1,
        accept: {
            'image/*': ['.jpeg', '.jpg', '.png', '.webp', '.gif']
        }
    });

    const handleRemove = () => {
        setPreview(null);
        onChange('');
    };

    return (
        <div className="space-y-2">
            {preview ? (
                <div className="relative w-full aspect-video rounded-lg overflow-hidden border bg-slate-100">
                    <img
                        src={preview}
                        alt="Обложка"
                        className="w-full h-full object-cover"
                    />
                    {isUploading && (
                        <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                            <Loader2 className="w-8 h-8 text-white animate-spin" />
                        </div>
                    )}
                    {!isUploading && (
                        <div className="absolute top-2 right-2 flex gap-2">
                            <Button
                                type="button"
                                variant="destructive"
                                size="icon"
                                className="h-8 w-8"
                                onClick={handleRemove}
                            >
                                <X className="w-4 h-4" />
                            </Button>
                        </div>
                    )}
                </div>
            ) : (
                <div
                    {...getRootProps()}
                    className={`
                        w-full aspect-video border-2 border-dashed rounded-lg
                        flex flex-col items-center justify-center cursor-pointer
                        transition-colors
                        ${isDragActive ? 'border-primary bg-primary/10' : 'border-slate-200 hover:border-primary/50 bg-slate-50'}
                        ${error ? 'border-red-500 bg-red-50' : ''}
                        ${isUploading ? 'pointer-events-none opacity-50' : ''}
                    `}
                >
                    <input {...getInputProps()} />
                    {isUploading ? (
                        <Loader2 className="w-8 h-8 text-slate-400 animate-spin" />
                    ) : (
                        <>
                            <ImageIcon className={`w-10 h-10 mb-2 ${error ? 'text-red-400' : 'text-slate-400'}`} />
                            <span className={`text-sm font-medium ${error ? 'text-red-500' : 'text-slate-500'}`}>
                                {error || (isDragActive ? 'Отпустите файл...' : 'Перетащите изображение или нажмите')}
                            </span>
                            <span className="text-xs text-slate-400 mt-1">
                                JPEG, PNG, WebP, GIF. Макс. 10MB
                            </span>
                        </>
                    )}
                </div>
            )}
        </div>
    );
}
