
'use client';

import { useState, useCallback } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useDropzone } from 'react-dropzone';
import { Trash, Upload, Mic, FileAudio, Play } from 'lucide-react';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import {
    Dialog,
    DialogContent,
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
import { useToast } from "@/components/ui/use-toast";

// Types
type NarrationItem = {
    id: string;
    url: string;
    kids_url?: string;
    locale: string;
    duration_seconds: number;
    transcript: string;
};

type Props = {
    poiId: string;
    narrations: NarrationItem[];
};

const API_URL = '/api/proxy';
// throw removed for build

export function NarrationsManager({ poiId, narrations: initialNarrations }: Props) {
    const [list, setList] = useState<NarrationItem[]>(initialNarrations || []);
    const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
    const [currentFile, setCurrentFile] = useState<File | null>(null);
    const [uploadedUrl, setUploadedUrl] = useState<string | null>(null);
    const [audioDuration, setAudioDuration] = useState<number>(0);

    // Form State
    const [locale, setLocale] = useState('ru');
    const [transcript, setTranscript] = useState('');
    const [kidsUrl, setKidsUrl] = useState<string | null>(null);
    const [kidsFile, setKidsFile] = useState<File | null>(null);

    const queryClient = useQueryClient();

    // 1. Get Presigned URL & Upload
    const uploadMutation = useMutation({
        mutationFn: async (file: File) => {
            const preRes = await fetch(`${API_URL}/admin/media/presign`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    filename: file.name,
                    content_type: file.type,
                    entity_type: 'poi', // narrations technically under POI folder logic
                    entity_id: poiId
                })
            });

            if (!preRes.ok) throw new Error("Не удалось получить presign URL");
            const { upload_url, final_url, method, headers } = await preRes.json();

            const uploadRes = await fetch(upload_url, {
                method: method || 'PUT',
                body: file,
                headers: headers || {}
            });

            if (!uploadRes.ok) throw new Error("Не удалось загрузить в хранилище");

            // Extract duration if possible
            const audio = new Audio(URL.createObjectURL(file));
            audio.onloadedmetadata = () => {
                setAudioDuration(audio.duration);
            };

            return final_url;
        },
        onSuccess: (url) => {
            setUploadedUrl(url);
        }
    });

    // 2. Save Metadata to DB
    const saveMetaMutation = useMutation({
        mutationFn: async () => {
            const res = await fetch(`${API_URL}/admin/pois/${poiId}/narrations`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({
                    url: uploadedUrl,
                    kids_url: kidsUrl || undefined,
                    locale: locale,
                    duration_seconds: audioDuration,
                    transcript: transcript
                })
            });
            if (!res.ok) throw new Error("Не удалось сохранить озвучку");
            return res.json();
        },
        onSuccess: (data) => {
            setIsUploadModalOpen(false);
            setList([...list, {
                id: data.id,
                url: uploadedUrl!,
                kids_url: kidsUrl || undefined,
                locale,
                duration_seconds: audioDuration,
                transcript
            }]);
            resetForm();
            queryClient.invalidateQueries({ queryKey: ['poi', poiId] });
        }
    });

    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            await fetch(`${API_URL}/admin/pois/${poiId}/narrations/${id}`, {
                method: 'DELETE',
                credentials: 'include'
            });
            return id;
        },
        onSuccess: (id) => {
            setList(list.filter(n => n.id !== id));
            queryClient.invalidateQueries({ queryKey: ['poi', poiId] });
        }
    });

    const onDrop = useCallback((acceptedFiles: File[]) => {
        const file = acceptedFiles[0];
        if (!file) return;
        setCurrentFile(file);
        setIsUploadModalOpen(true);
        uploadMutation.mutate(file);
    }, [uploadMutation]);

    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        maxFiles: 1,
        accept: { 'audio/*': ['.mp3', '.wav', '.ogg', '.m4a'] }
    });

    const resetForm = () => {
        setLocale('ru');
        setTranscript('');
        setUploadedUrl(null);
        setCurrentFile(null);
        setAudioDuration(0);
        setKidsUrl(null);
        setKidsFile(null);
    };

    const formatDuration = (sec: number) => {
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return `${m}:${s.toString().padStart(2, '0')}`;
    }

    return (
        <Card>
            <CardHeader>
                <CardTitle className="text-lg">Аудио-озвучка</CardTitle>
                <CardDescription>Загрузите профессиональную озвучку для этой точки.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
                <div className="space-y-2">
                    {list.map((n) => (
                        <div key={n.id} className="flex items-center justify-between p-3 border rounded-lg bg-slate-50 dark:bg-slate-900">
                            <div className="flex items-center gap-3">
                                <div className="h-10 w-10 flex items-center justify-center bg-blue-100 text-blue-600 rounded-full">
                                    <Play className="w-5 h-5 ml-1" />
                                </div>
                                <div>
                                    <div className="font-medium flex items-center gap-2">
                                        <span className="uppercase text-xs font-bold bg-slate-200 px-1.5 py-0.5 rounded">{n.locale}</span>
                                        <span>{formatDuration(n.duration_seconds)}</span>
                                        {n.kids_url && (
                                            <span className="text-xs bg-purple-100 text-purple-700 px-1.5 py-0.5 rounded">👶 детская</span>
                                        )}
                                    </div>
                                    <div className="text-xs text-muted-foreground truncate max-w-[200px]">
                                        {n.transcript || "Нет транскрипта"}
                                    </div>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-700 hover:bg-red-50"
                                    onClick={() => deleteMutation.mutate(n.id)}>
                                    <Trash className="w-4 h-4" />
                                </Button>
                            </div>
                        </div>
                    ))}
                </div>

                <div {...getRootProps()} className={`
                    border-2 border-dashed rounded-lg p-8 flex flex-col items-center justify-center cursor-pointer transition-colors
                    ${isDragActive ? 'border-primary bg-primary/10' : 'border-slate-200 hover:border-primary/50'}
                `}>
                    <input {...getInputProps()} />
                    <Mic className="w-8 h-8 text-slate-400 mb-2" />
                    <span className="text-sm text-slate-500 font-medium">
                        {isDragActive ? 'Перетащите аудиофайл...' : 'Перетащите аудиофайл или нажмите для загрузки'}
                    </span>
                    <span className="text-xs text-slate-400 mt-1">Поддерживаются MP3, WAV, M4A</span>
                </div>

                <div className="flex justify-center border-t pt-4">
                    <GenerateAIButton poiId={poiId} />
                </div>

                <Dialog open={isUploadModalOpen} onOpenChange={setIsUploadModalOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Добавить озвучку</DialogTitle>
                        </DialogHeader>

                        {uploadMutation.isPending && <div className="text-blue-600 text-sm">Загрузка...</div>}

                        <div className="space-y-4 py-4">
                            <div className="grid gap-2">
                                <Label>Язык</Label>
                                <Select value={locale} onValueChange={setLocale}>
                                    <SelectTrigger><SelectValue /></SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="ru">Русский</SelectItem>
                                        <SelectItem value="en">Английский</SelectItem>
                                        <SelectItem value="de">Немецкий</SelectItem>
                                        <SelectItem value="zh">Китайский</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                            <div className="grid gap-2">
                                <Label>Транскрипт</Label>
                                <Textarea
                                    value={transcript}
                                    onChange={e => setTranscript(e.target.value)}
                                    placeholder="Текст озвучки..."
                                    rows={5}
                                />
                            </div>
                            
                            {/* Kids Audio Upload */}
                            <div className="grid gap-2 p-3 border rounded-lg bg-purple-50/50">
                                <Label className="flex items-center gap-2">
                                    <span>👶</span> Детская версия (опционально)
                                </Label>
                                <p className="text-xs text-muted-foreground">
                                    Упрощённая озвучка для режима "С детьми"
                                </p>
                                {kidsUrl ? (
                                    <div className="flex items-center gap-2">
                                        <audio src={kidsUrl} controls className="flex-1 h-8" />
                                        <Button 
                                            type="button" 
                                            variant="ghost" 
                                            size="sm"
                                            onClick={() => { setKidsUrl(null); setKidsFile(null); }}
                                        >
                                            <Trash className="w-4 h-4 text-red-500" />
                                        </Button>
                                    </div>
                                ) : (
                                    <div>
                                        <input
                                            type="file"
                                            accept="audio/*"
                                            className="hidden"
                                            id="kids-audio-input"
                                            onChange={async (e) => {
                                                const file = e.target.files?.[0];
                                                if (!file) return;
                                                setKidsFile(file);
                                                
                                                // Upload kids audio
                                                try {
                                                    const preRes = await fetch(`${API_URL}/admin/media/presign`, {
                                                        method: 'POST',
                                                        headers: { 'Content-Type': 'application/json' },
                                                        credentials: 'include',
                                                        body: JSON.stringify({
                                                            filename: `kids_${file.name}`,
                                                            content_type: file.type,
                                                            entity_type: 'poi',
                                                            entity_id: poiId
                                                        })
                                                    });
                                                    if (!preRes.ok) throw new Error("Presign failed");
                                                    const { upload_url, final_url, headers } = await preRes.json();
                                                    
                                                    const uploadRes = await fetch(upload_url, {
                                                        method: 'PUT',
                                                        body: file,
                                                        headers: headers || {}
                                                    });
                                                    if (!uploadRes.ok) throw new Error("Upload failed");
                                                    
                                                    setKidsUrl(final_url);
                                                } catch (err) {
                                                    console.error('Kids audio upload failed:', err);
                                                    setKidsFile(null);
                                                }
                                            }}
                                        />
                                        <Button
                                            type="button"
                                            variant="outline"
                                            size="sm"
                                            className="w-full"
                                            onClick={() => document.getElementById('kids-audio-input')?.click()}
                                        >
                                            <Upload className="w-4 h-4 mr-2" />
                                            {kidsFile ? 'Загрузка...' : 'Загрузить детскую версию'}
                                        </Button>
                                    </div>
                                )}
                            </div>
                            
                            {audioDuration > 0 && <div className="text-xs text-slate-500">Определённая длительность: {audioDuration.toFixed(1)}с</div>}
                        </div>

                        <DialogFooter>
                            <Button variant="outline" onClick={() => setIsUploadModalOpen(false)}>Отмена</Button>
                            <Button
                                onClick={() => saveMetaMutation.mutate()}
                                disabled={!uploadedUrl || saveMetaMutation.isPending}
                            >
                                {saveMetaMutation.isPending ? 'Сохранение...' : 'Сохранить озвучку'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </CardContent>
        </Card>
    );
}

function GenerateAIButton({ poiId }: { poiId: string }) {
    const { toast } = useToast();
    const mutation = useMutation({
        mutationFn: async () => {
            const res = await fetch(`${API_URL}/admin/pois/${poiId}/generate-tts`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include',
                body: JSON.stringify({ locale: 'ru' })
            });
            if (!res.ok) {
                const err = await res.json();
                throw new Error(err.detail || "Не удалось начать генерацию");
            }
            return res.json();
        },
        onSuccess: (data) => {
            toast({
                title: "Генерация запущена",
                description: `ID задачи: ${data.job_id}. Проверьте панель задач.`
            });
        },
        onError: (err) => {
            toast({ title: "Ошибка", description: err.message, variant: "destructive" });
        }
    });

    return (
        <Button
            variant="outline"
            className="w-full sm:w-auto border-purple-200 bg-purple-50 text-purple-700 hover:bg-purple-100 hover:text-purple-800"
            onClick={() => mutation.mutate()}
            disabled={mutation.isPending}
        >
            <Mic className="w-4 h-4 mr-2" />
            {mutation.isPending ? 'Постановка в очередь...' : 'Сгенерировать с ИИ (TTS)'}
        </Button>
    )
}




