'use client';

import { useState, useCallback, useRef } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Upload, Trash2, Play, Pause, Loader2, CheckCircle2, XCircle } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";

type Props = {
    value?: string;
    onChange: (url: string | undefined) => void;
    entityType?: string;
    entityId?: string;
};

const API_URL = '/api/proxy';

export function AudioUploadField({ value, onChange, entityType = 'tour', entityId }: Props) {
    const [uploadProgress, setUploadProgress] = useState(0);
    const [isPlaying, setIsPlaying] = useState(false);
    const [errorMsg, setErrorMsg] = useState<string | null>(null);
    const audioRef = useRef<HTMLAudioElement | null>(null);
    const fileInputRef = useRef<HTMLInputElement | null>(null);

    const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
    const ALLOWED_TYPES = ['audio/mpeg', 'audio/wav', 'audio/x-wav', 'audio/ogg', 'audio/mp3'];

    const uploadMutation = useMutation({
        mutationFn: async (file: File) => {
            // Use server-side upload proxy to avoid localhost:9000 issue
            // The /api/upload-audio endpoint runs on the server and can access MinIO
            const formData = new FormData();
            formData.append('file', file);
            formData.append('entity_type', entityType);
            if (entityId) {
                formData.append('entity_id', entityId);
            }

            // Simulate progress
            const progressInterval = setInterval(() => {
                setUploadProgress(prev => Math.min(prev + 5, 90));
            }, 200);

            try {
                // Don't send Authorization header - cookie is sent automatically
                const uploadRes = await fetch('/api/upload-audio', {
                    method: 'POST',
                    body: formData,
                    credentials: 'include' // Ensure cookies are sent
                });

                clearInterval(progressInterval);
                setUploadProgress(100);

                if (!uploadRes.ok) {
                    const errorData = await uploadRes.json().catch(() => ({}));
                    console.error('Upload failed:', uploadRes.status, errorData);
                    
                    // 503 = MinIO недоступен (ECONNREFUSED)
                    if (uploadRes.status === 503) {
                        throw new Error('Хранилище файлов недоступно. Загрузка работает только когда админка запущена на сервере Cloud.ru.');
                    }
                    
                    // 401 = не авторизован
                    if (uploadRes.status === 401) {
                        throw new Error('Сессия истекла. Пожалуйста, перезайдите в систему.');
                    }
                    
                    throw new Error(errorData.detail || errorData.error || 'Не удалось загрузить файл');
                }
                
                const result = await uploadRes.json();
                console.log('Upload success:', result.url);
                return result.url;
            } catch (e) {
                clearInterval(progressInterval);
                setUploadProgress(0);
                throw e;
            }
        },
        onSuccess: (url) => {
            onChange(url);
            setUploadProgress(0);
            setErrorMsg(null);
        },
        onError: (error: Error) => {
            setErrorMsg(error.message);
            setUploadProgress(0);
        }
    });

    const handleFileSelect = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setErrorMsg(null);
        setUploadProgress(0);

        if (!ALLOWED_TYPES.includes(file.type)) {
            setErrorMsg("Неверный формат. Допускаются: MP3, WAV, OGG");
            return;
        }

        if (file.size > MAX_FILE_SIZE) {
            setErrorMsg("Файл слишком большой. Максимум 50МБ.");
            return;
        }

        uploadMutation.mutate(file);
    }, [uploadMutation]);

    const handleRemove = () => {
        onChange(undefined);
        if (audioRef.current) {
            audioRef.current.pause();
            setIsPlaying(false);
        }
    };

    const togglePlay = () => {
        if (!audioRef.current || !value) return;
        
        if (isPlaying) {
            audioRef.current.pause();
        } else {
            audioRef.current.play();
        }
        setIsPlaying(!isPlaying);
    };

    const handleAudioEnded = () => {
        setIsPlaying(false);
    };

    // Получаем короткое имя файла
    const fileName = value ? decodeURIComponent(value.split('/').pop() || '').replace(/^[a-f0-9-]+_/, '') : '';

    return (
        <div className="space-y-3">
            <input
                ref={fileInputRef}
                type="file"
                accept="audio/*"
                onChange={handleFileSelect}
                className="hidden"
            />

            {/* Загрузка */}
            {uploadMutation.isPending && (
                <div className="flex items-center gap-3 text-sm text-slate-600">
                    <Loader2 className="w-4 h-4 animate-spin text-purple-500" />
                    <div className="flex-1">
                        <Progress value={uploadProgress} className="h-1.5" />
                    </div>
                    <span className="text-xs">{uploadProgress}%</span>
                </div>
            )}

            {/* Ошибка */}
            {errorMsg && (
                <p className="text-sm text-red-600 flex items-center gap-2">
                    <XCircle className="w-4 h-4 shrink-0" />
                    {errorMsg}
                </p>
            )}

            {/* Аудио загружено */}
            {value && !uploadMutation.isPending && (
                <div className="border rounded-lg overflow-hidden">
                    <audio ref={audioRef} src={value} onEnded={handleAudioEnded} className="hidden" />
                    
                    {/* Заголовок */}
                    <div className="flex items-center justify-between px-3 py-2 bg-slate-50 border-b">
                        <div className="flex items-center gap-2 min-w-0 flex-1">
                            <CheckCircle2 className="w-4 h-4 text-green-500 shrink-0" />
                            <span className="text-sm text-slate-700 truncate" title={fileName}>
                                {fileName || 'audio.mp3'}
                            </span>
                        </div>
                        <div className="flex items-center gap-1 shrink-0 ml-2">
                            <Button type="button" variant="ghost" size="icon" onClick={togglePlay} className="h-7 w-7">
                                {isPlaying ? <Pause className="w-3.5 h-3.5" /> : <Play className="w-3.5 h-3.5" />}
                            </Button>
                            <Button type="button" variant="ghost" size="icon" onClick={handleRemove} className="h-7 w-7 text-red-500 hover:text-red-600">
                                <Trash2 className="w-3.5 h-3.5" />
                            </Button>
                        </div>
                    </div>
                    
                    {/* Плеер */}
                    <audio src={value} controls className="w-full h-8" style={{ display: 'block' }} />
                </div>
            )}

            {/* Кнопка загрузки */}
            {!uploadMutation.isPending && (
                <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => fileInputRef.current?.click()}
                    className="w-full"
                >
                    <Upload className="w-4 h-4 mr-2" />
                    {value ? 'Заменить аудио' : 'Загрузить аудио'}
                </Button>
            )}
        </div>
    );
}
