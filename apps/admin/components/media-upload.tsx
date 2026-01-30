
'use client';

import { useState, useCallback } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useDropzone } from 'react-dropzone';
import { Trash, Upload, Image as ImageIcon, Music, FileAudio, ExternalLink } from 'lucide-react';

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

const API_URL = process.env.NEXT_PUBLIC_API_URL || "https://audiogid-api.vercel.app/v1";

export function MediaUploader({ entityId, entityType, media: initialMedia }: Props) {
    const [mediaList, setMediaList] = useState<MediaItem[]>(initialMedia || []);
    const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
    const [currentFile, setCurrentFile] = useState<File | null>(null);
    const [uploadedUrl, setUploadedUrl] = useState<string | null>(null);

    // License Form State
    const [licenseType, setLicenseType] = useState('cc-by-3.0');
    const [author, setAuthor] = useState('');
    const [sourceUrl, setSourceUrl] = useState('');

    const queryClient = useQueryClient();

    // 1. Get Presigned URL & Upload
    const uploadMutation = useMutation({
        mutationFn: async (file: File) => {
            // A. Get Presigned
            const token = localStorage.getItem('admin_token');
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
                    entity_id: entityId
                })
            });

            if (!preRes.ok) throw new Error("Presign failed");
            const { upload_url, final_url, method, headers } = await preRes.json();

            // B. Upload to Blob (PUT)
            // Note: If fields present (S3 POST), logic differs. Assuming simple PUT for now as per code.
            const uploadRes = await fetch(upload_url, {
                method: method || 'PUT',
                body: file,
                headers: headers || {}
            });

            if (!uploadRes.ok) throw new Error("Upload to storage failed");

            return final_url;
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
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
                },
                body: JSON.stringify({
                    url: uploadedUrl,
                    media_type: mediaType,
                    license_type: licenseType,
                    author: author,
                    source_page_url: sourceUrl
                })
            });
            if (!res.ok) throw new Error("Failed to save metadata");
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
                headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
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
                <CardTitle className="text-lg">Media Gallery</CardTitle>
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
                                    <span className="text-xs text-slate-500 mt-2">Audio</span>
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
                    <div {...getRootProps()} className={`
                        border-2 border-dashed rounded-lg aspect-square flex flex-col items-center justify-center cursor-pointer transition-colors
                        ${isDragActive ? 'border-primary bg-primary/10' : 'border-slate-200 hover:border-primary/50'}
                    `}>
                        <input {...getInputProps()} />
                        <Upload className="w-8 h-8 text-slate-400 mb-2" />
                        <span className="text-sm text-slate-500 font-medium text-center px-2">
                            {isDragActive ? 'Drop file...' : 'Drop image/audio'}
                        </span>
                    </div>
                </div>

                {/* Upload & License Modal */}
                <Dialog open={isUploadModalOpen} onOpenChange={setIsUploadModalOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Add Media Metadata</DialogTitle>
                            <DialogDescription>
                                Provide license information for: {currentFile?.name}
                            </DialogDescription>
                        </DialogHeader>

                        {uploadMutation.isPending && (
                            <div className="py-4 text-center text-sm text-blue-600">
                                Uploading file... {(uploadMutation.status === 'pending') && "Please wait"}
                            </div>
                        )}

                        {!uploadMutation.isPending && !uploadedUrl && uploadMutation.isError && (
                            <div className="py-4 text-center text-sm text-red-600">
                                Upload Failed: {uploadMutation.error?.message}
                            </div>
                        )}

                        <div className="space-y-4 py-4">
                            <div className="grid gap-2">
                                <Label>License Type</Label>
                                <Select value={licenseType} onValueChange={setLicenseType}>
                                    <SelectTrigger>
                                        <SelectValue />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="cc-by-3.0">CC BY 3.0</SelectItem>
                                        <SelectItem value="cc-by-sa-3.0">CC BY-SA 3.0</SelectItem>
                                        <SelectItem value="cc-0">CC0 (Public Domain)</SelectItem>
                                        <SelectItem value="own-work">Own Work</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                            <div className="grid gap-2">
                                <Label>Author / Attribution</Label>
                                <Input value={author} onChange={e => setAuthor(e.target.value)} placeholder="e.g. John Doe / Wikimedia" />
                            </div>
                            <div className="grid gap-2">
                                <Label>Source URL</Label>
                                <Input value={sourceUrl} onChange={e => setSourceUrl(e.target.value)} placeholder="https://commons.wikimedia.org/..." />
                            </div>
                        </div>

                        <DialogFooter>
                            <Button variant="outline" onClick={() => setIsUploadModalOpen(false)}>Cancel</Button>
                            <Button
                                onClick={() => saveMetaMutation.mutate()}
                                disabled={!uploadedUrl || !author || saveMetaMutation.isPending}
                            >
                                {saveMetaMutation.isPending ? 'Saving...' : 'Add to Library'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </CardContent>
        </Card>
    );

}
