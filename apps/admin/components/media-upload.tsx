
'use client';

import { useState, useCallback } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useDropzone } from 'react-dropzone';
import { Trash, Upload, Image as ImageIcon, Music, FileAudio, ExternalLink, CheckCircle2, XCircle } from 'lucide-react';
import { Progress } from "@/components/ui/progress";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";

// Types
type MediaItem = {
    id: string;
    url: string;
    media_type: 'image' | 'audio';
    license_type: string;
    author: string;
    source_page_url: string;
};

type Props = {
    entityId: string;
    entityType: 'poi' | 'tour';
    media: MediaItem[];
};

const API_URL = '/api/proxy';
// throw removed for build

export function MediaUploader({ entityId, entityType, media: initialMedia }: Props) {
    const [mediaList, setMediaList] = useState<MediaItem[]>(initialMedia || []);
    const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
    const [currentFile, setCurrentFile] = useState<File | null>(null);
    const [uploadedUrl, setUploadedUrl] = useState<string | null>(null);
    const [uploadProgress, setUploadProgress] = useState(0);
    const [errorMsg, setErrorMsg] = useState<string | null>(null);

    const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
    const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'audio/mpeg', 'audio/wav', 'audio/x-wav'];

    // License Form State
    const [licenseType, setLicenseType] = useState('cc-by-3.0');
    const [author, setAuthor] = useState('');
    const [sourceUrl, setSourceUrl] = useState('');

    const queryClient = useQueryClient();

    // 1. Get Presigned URL & Upload
    const uploadMutation = useMutation({
        mutationFn: async (file: File) => {
            // A. Get Presigned
            const preRes = await fetch(`${API_URL}/admin/media/presign`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    filename: file.name,
                    content_type: file.type,
                    entity_type: entityType,
                    entity_id: entityId
                })
            });

            if (!preRes.ok) throw new Error("Не удалось получить presign URL");
            const { upload_url, final_url, method, headers } = await preRes.json();

            // B. Upload to Blob (PUT)
            // Note: If fields present (S3 POST), logic differs. Assuming simple PUT for now as per code.


            // Simulate progress for better UX
            const progressInterval = setInterval(() => {
                setUploadProgress(prev => Math.min(prev + 10, 90));
            }, 200);

            try {
                const uploadRes = await fetch(upload_url, {
                    method: method || 'PUT',
                    body: file,
                    headers: headers || {}
                });

                clearInterval(progressInterval);
                setUploadProgress(100);

                if (!uploadRes.ok) throw new Error("Не удалось загрузить в хранилище");
                return final_url;
            } catch (e) {
                clearInterval(progressInterval);
                setUploadProgress(0);
                throw e;
            }


        },
        onSuccess: (url) => {
            setUploadedUrl(url);
            // Open License Modal
            // (Is already open if we did this immediately after drop? Or we show progress in modal)
        }
    });

    // 2. Save Metadata to DB
    const saveMetaMutation = useMutation({
        mutationFn: async () => {
            const endpoint = entityType === 'poi'
                ? `${API_URL}/admin/pois/${entityId}/media`
                : `${API_URL}/admin/tours/${entityId}/media`;

            const mediaType = currentFile?.type.startsWith('audio') ? 'audio' : 'image';

            const res = await fetch(endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    url: uploadedUrl,
                    media_type: mediaType,
                    license_type: licenseType,
                    author: author,
                    source_page_url: sourceUrl
                })
            });
            if (!res.ok) throw new Error("Не удалось сохранить метаданные");
            return res.json();
        },
        onSuccess: (data) => {
            setIsUploadModalOpen(false);
            setMediaList([...mediaList, {
                id: data.id,
                url: uploadedUrl!,
                media_type: currentFile?.type.startsWith('audio') ? 'audio' : 'image',
                license_type: licenseType,
                author,
                source_page_url: sourceUrl
            }]);
            resetForm();
            queryClient.invalidateQueries({ queryKey: [entityType + 's', entityId] });
        }
    });

    const deleteMutation = useMutation({
        mutationFn: async (mediaId: string) => {
            const endpoint = entityType === 'poi'
                ? `${API_URL}/admin/pois/${entityId}/media/${mediaId}`
                : `${API_URL}/admin/tours/${entityId}/media/${mediaId}`;
            await fetch(endpoint, {
                method: 'DELETE',
                credentials: 'include'
            });
            return mediaId;
        },
        onSuccess: (id) => {
            setMediaList(mediaList.filter(m => m.id !== id));
            queryClient.invalidateQueries({ queryKey: [entityType + 's', entityId] });
        }
    });

    const onDrop = useCallback((acceptedFiles: File[]) => {
        const file = acceptedFiles[0];
        if (!file) return;

        setErrorMsg(null);
        setUploadProgress(0);

        if (!ALLOWED_TYPES.includes(file.type)) {
            setErrorMsg("Неверный тип файла. Допускаются только JPEG, PNG, WEBP, MP3, WAV.");
            return;
        }

        if (file.size > MAX_FILE_SIZE) {
            setErrorMsg("Файл слишком большой. Максимум 50МБ.");
            return;
        }

        setCurrentFile(file);
        setIsUploadModalOpen(true);
        // Start upload immediately? Or wait for modal "Upload"? 
        // Better: Start upload immediately to save time, show spinner in modal.
        uploadMutation.mutate(file);
    }, [uploadMutation]);

    const { getRootProps, getInputProps, isDragActive } = useDropzone({ onDrop, maxFiles: 1 });

    const resetForm = () => {
        setAuthor('');
        setSourceUrl('');
        setUploadedUrl(null);
        setCurrentFile(null);
    };

    return (
        <Card>
            <CardHeader>
                <CardTitle className="text-lg">Галерея медиа</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
                {/* Gallery Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {mediaList.map((m) => (
                        <div key={m.id} className="relative group border rounded-lg overflow-hidden bg-slate-100 aspect-square flex items-center justify-center">
                            {m.media_type === 'image' ? (
                                <img src={m.url} alt="media" className="object-cover w-full h-full" />
                            ) : (
                                <div className="flex flex-col items-center">
                                    <Music className="w-8 h-8 text-slate-400" />
                                    <span className="text-xs text-slate-500 mt-2">Аудио</span>
                                </div>
                            )}

                            <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center gap-2 p-2">
                                <span className="text-white text-xs text-center line-clamp-2">© {m.author}</span>
                                <div className="flex gap-2">
                                    <Button variant="destructive" size="icon" className="h-8 w-8" onClick={() => deleteMutation.mutate(m.id)}>
                                        <Trash className="w-4 h-4" />
                                    </Button>
                                    <Button variant="secondary" size="icon" className="h-8 w-8" asChild>
                                        <a href={m.source_page_url} target="_blank">
                                            <ExternalLink className="w-4 h-4" />
                                        </a>
                                    </Button>
                                </div>
                            </div>
                        </div>
                    ))}

                    {/* Upload Dropzone */}
                    {!isUploadModalOpen && (
                        <div {...getRootProps()} className={`
                            border-2 border-dashed rounded-lg aspect-square flex flex-col items-center justify-center cursor-pointer transition-colors relative
                            ${isDragActive ? 'border-primary bg-primary/10' : 'border-slate-200 hover:border-primary/50'}
                            ${errorMsg ? 'border-red-500 bg-red-50' : ''}
                        `}>
                            <input {...getInputProps()} />
                            <Upload className={`w-8 h-8 mb-2 ${errorMsg ? 'text-red-400' : 'text-slate-400'}`} />
                            <span className={`text-sm font-medium text-center px-2 ${errorMsg ? 'text-red-500' : 'text-slate-500'}`}>
                                {errorMsg || (isDragActive ? 'Перетащите файл...' : 'Перетащите изображение/аудио')}
                            </span>
                            <span className="text-xs text-slate-400 mt-1">
                                Макс. 50MB. Изображения/Аудио.
                            </span>
                        </div>
                    )}
                </div>

                {/* Upload & License Modal */}
                <Dialog open={isUploadModalOpen} onOpenChange={(open) => {
                    if (!open && uploadMutation.isPending) return; // Prevent closing while uploading
                    setIsUploadModalOpen(open);
                }}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Добавить метаданные медиа</DialogTitle>
                            <DialogDescription>
                                {currentFile ? `Файл: ${currentFile.name} (${(currentFile.size / 1024 / 1024).toFixed(2)} MB)` : 'Укажите данные медиа'}
                            </DialogDescription>
                        </DialogHeader>

                        {/* Upload Status & Progress */}
                        <div className="py-4 space-y-2">
                            {uploadMutation.isPending && (
                                <div className="space-y-1">
                                    <div className="flex justify-between text-xs text-slate-500">
                                        <span>Загрузка...</span>
                                        <span>{uploadProgress}%</span>
                                    </div>
                                    <Progress value={uploadProgress} className="h-2" />
                                </div>
                            )}

                            {!uploadMutation.isPending && !uploadedUrl && uploadMutation.isError && (
                                <div className="p-3 bg-red-50 text-red-600 rounded-md text-sm flex items-start gap-2">
                                    <XCircle className="w-4 h-4 mt-0.5 shrink-0" />
                                    <span>Загрузка не удалась: {uploadMutation.error?.message}</span>
                                </div>
                            )}

                            {uploadedUrl && (
                                <div className="p-3 bg-green-50 text-green-700 rounded-md text-sm flex items-center gap-2">
                                    <CheckCircle2 className="w-4 h-4" />
                                    <span>Файл успешно загружен!</span>
                                </div>
                            )}
                        </div>

                        <div className="space-y-4">
                            <div className="grid gap-2">
                                <Label>Тип лицензии <span className="text-red-500">*</span></Label>
                                <Select value={licenseType} onValueChange={setLicenseType}>
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="cc-by-3.0">Creative Commons BY 3.0</SelectItem>
                                        <SelectItem value="cc-by-sa-3.0">Creative Commons BY-SA 3.0</SelectItem>
                                        <SelectItem value="cc-0">CC0 (Общественное достояние)</SelectItem>
                                        <SelectItem value="own-work">Собственная работа (я создал это)</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                            <div className="grid gap-2">
                                <Label>Автор / Атрибуция <span className="text-red-500">*</span></Label>
                                <Input
                                    value={author}
                                    onChange={e => setAuthor(e.target.value)}
                                    placeholder="напр. Иван Иванов / Wikimedia Commons"
                                />
                            </div>
                            <div className="grid gap-2">
                                <Label>URL источника</Label>
                                <Input
                                    value={sourceUrl}
                                    onChange={e => setSourceUrl(e.target.value)}
                                    placeholder="https://commons.wikimedia.org/wiki/File:..."
                                />
                            </div>
                        </div>

                        <DialogFooter className="mt-4">
                            <Button variant="outline" onClick={() => setIsUploadModalOpen(false)} disabled={uploadMutation.isPending}>
                                Отмена
                            </Button>
                            <Button
                                onClick={() => saveMetaMutation.mutate()}
                                disabled={!uploadedUrl || !author || saveMetaMutation.isPending}
                            >
                                {saveMetaMutation.isPending ? 'Сохранение...' : 'Добавить в библиотеку'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </CardContent>
        </Card>
    );

}




