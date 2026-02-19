
'use client';

import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { CheckCircle2, AlertTriangle, XCircle, ExternalLink } from "lucide-react";
import { Badge } from "@/components/ui/badge";

type Props = {
    isOpen: boolean;
    onClose: () => void;
    onPublish: () => void;
    onUnpublish?: () => void;
    checkResult: {
        can_publish: boolean;
        issues: string[];
        missing_requirements?: string[];
        unpublished_poi_ids?: string[];
    } | null;
    isPublishing: boolean;
    currentStatus: 'published' | 'draft';
};

export function PublishCheckModal({
    isOpen,
    onClose,
    onPublish,
    onUnpublish,
    checkResult,
    isPublishing,
    currentStatus
}: Props) {
    if (!checkResult && isOpen) return null;

    const isPublished = currentStatus === 'published';

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="sm:max-w-md">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                        {isPublished ? "Управление публикацией" : "Публикация контента"}
                    </DialogTitle>
                    <DialogDescription>
                        {isPublished
                            ? "Этот контент сейчас опубликован. Вы можете снять его с публикации, чтобы скрыть от пользователей."
                            : "Проверьте качество перед публикацией контента."}
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-4 py-4">
                    {/* Status Card */}
                    <div className={`p-4 rounded-lg flex items-start gap-3 border ${checkResult?.can_publish
                            ? 'bg-green-50 border-green-200'
                            : 'bg-amber-50 border-amber-200'
                        }`}>
                        {checkResult?.can_publish ? (
                            <CheckCircle2 className="w-5 h-5 text-green-600 mt-0.5" />
                        ) : (
                            <AlertTriangle className="w-5 h-5 text-amber-600 mt-0.5" />
                        )}
                        <div>
                            <h4 className={`text-sm font-semibold ${checkResult?.can_publish ? 'text-green-800' : 'text-amber-800'
                                }`}>
                                {checkResult?.can_publish ? "Готово к публикации" : "Найдены проблемы"}
                            </h4>
                            {!checkResult?.can_publish && (
                                <p className="text-xs text-amber-700 mt-1">
                                    Необходимо исправить критические проблемы перед публикацией.
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Issues List */}
                    {checkResult?.issues && checkResult.issues.length > 0 && (
                        <div className="space-y-2">
                            <span className="text-sm font-medium">Отчёт валидации:</span>
                            <ul className="text-sm space-y-2 pl-1">
                                {checkResult.issues.map((issue, idx) => (
                                    <li key={idx} className="flex items-start gap-2 text-slate-700 bg-slate-50 p-2 rounded">
                                        <XCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                                        <span>{issue}</span>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>

                <DialogFooter className="gap-2 sm:gap-0">
                    <Button variant="outline" onClick={onClose}>Закрыть</Button>

                    {isPublished && onUnpublish && (
                        <Button variant="destructive" onClick={onUnpublish} disabled={isPublishing}>
                            {isPublishing ? "Обработка..." : "Снять с публикации"}
                        </Button>
                    )}

                    {!isPublished && (
                        <Button
                            onClick={onPublish}
                            disabled={!checkResult?.can_publish || isPublishing}
                            className="bg-green-600 hover:bg-green-700 text-white"
                        >
                            {isPublishing ? "Публикация..." : "Опубликовать"}
                        </Button>
                    )}
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}




