'use client';

import { useState, useCallback, useRef } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Upload, Trash2, Play, Pause, Loader2, CheckCircle2, XCircle, Music } from 'lucide-react';
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
            const token = localStorage.getItem('admin_token');
            
            // Get presigned URL
            const preRes = await fetch(`${API_URL}/admin/media/presign`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    filename: file.name,
                    content_type: file.type,
                    entity_type: entityType,
                    entity_id: entityId || 'transition-audio'
                })
            });

            if (!preRes.ok) throw new Error("Не удалось получить URL для загрузки");
            const { upload_url, final_url, method, headers } = await preRes.json();

            // Simulate progress
            const progressInterval = setInterval(() => {
                setUploadProgress(prev => Math.min(prev + 10, 90));
            }, 150);

            try {
                const uploadRes = await fetch(upload_url, {
                    method: method || 'PUT',
                    body: file,
                    headers: headers || {}
                });

                clearInterval(progressInterval);
                setUploadProgress(100);

                if (!uploadRes.ok) throw new Error("Не удалось загрузить файл");
                return final_url;
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

    return (
        <div className="space-y-3">
            {/* Hidden file input */}
            <input
                ref={fileInputRef}
                type="file"
                accept="audio/*"
                onChange={handleFileSelect}
                className="hidden"
            />

            {/* Upload progress */}
            {uploadMutation.isPending && (
                <div className="space-y-2 p-3 bg-blue-50 rounded-lg">
                    <div className="flex items-center gap-2 text-blue-600 text-sm">
                        <Loader2 className="w-4 h-4 animate-spin" />
                        <span>Загрузка аудио...</span>
                        <span className="ml-auto">{uploadProgress}%</span>
                    </div>
                    <Progress value={uploadProgress} className="h-2" />
                </div>
            )}

            {/* Error message */}
            {errorMsg && (
                <div className="p-3 bg-red-50 text-red-600 rounded-lg text-sm flex items-center gap-2">
                    <XCircle className="w-4 h-4 shrink-0" />
                    <span>{errorMsg}</span>
                </div>
            )}

            {/* Current audio file */}
            {value && !uploadMutation.isPending && (
                <div className="flex items-center gap-3 p-3 bg-purple-50 rounded-lg">
                    <audio 
                        ref={audioRef} 
                        src={value} 
                        onEnded={handleAudioEnded}
                        className="hidden"
                    />
                    
                    <div className="flex items-center gap-2 flex-1 min-w-0">
                        <Music className="w-5 h-5 text-purple-500 shrink-0" />
                        <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-purple-700 truncate">
                                Аудио загружено
                            </p>
                            <p className="text-xs text-purple-500 truncate">
                                {value.split('/').pop()}
                            </p>
                        </div>
                    </div>

                    <div className="flex items-center gap-1">
                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={togglePlay}
                            className="text-purple-600 hover:text-purple-700 hover:bg-purple-100"
                        >
                            {isPlaying ? (
                                <Pause className="w-4 h-4" />
                            ) : (
                                <Play className="w-4 h-4" />
                            )}
                        </Button>
                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={handleRemove}
                            className="text-red-500 hover:text-red-700 hover:bg-red-50"
                        >
                            <Trash2 className="w-4 h-4" />
                        </Button>
                    </div>
                </div>
            )}

            {/* Upload button - show when no file or after successful upload for replacement */}
            {!uploadMutation.isPending && (
                <div className="flex gap-2">
                    <Button
                        type="button"
                        variant={value ? "outline" : "default"}
                        size="sm"
                        onClick={() => fileInputRef.current?.click()}
                        className={value ? "" : "bg-purple-500 hover:bg-purple-600"}
                    >
                        <Upload className="w-4 h-4 mr-2" />
                        {value ? "Заменить аудио" : "Загрузить аудио"}
                    </Button>
                </div>
            )}

            {/* Audio player for preview */}
            {value && (
                <audio src={value} controls className="w-full h-10" />
            )}
        </div>
    );
}
