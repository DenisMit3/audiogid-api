
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
                        {isPublished ? "Manage Publication" : "Publish Content"}
                    </DialogTitle>
                    <DialogDescription>
                        {isPublished
                            ? "This content is currently live. You can unpublish it to hide it from users."
                            : "Review the quality checks before making this content live."}
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
                                {checkResult?.can_publish ? "Ready to Publish" : "Issues Found"}
                            </h4>
                            {!checkResult?.can_publish && (
                                <p className="text-xs text-amber-700 mt-1">
                                    You must fix the critical issues below before publishing.
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Issues List */}
                    {checkResult?.issues && checkResult.issues.length > 0 && (
                        <div className="space-y-2">
                            <span className="text-sm font-medium">Validation Report:</span>
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
                    <Button variant="outline" onClick={onClose}>Close</Button>

                    {isPublished && onUnpublish && (
                        <Button variant="destructive" onClick={onUnpublish} disabled={isPublishing}>
                            {isPublishing ? "Processing..." : "Unpublish Now"}
                        </Button>
                    )}

                    {!isPublished && (
                        <Button
                            onClick={onPublish}
                            disabled={!checkResult?.can_publish || isPublishing}
                            className="bg-green-600 hover:bg-green-700 text-white"
                        >
                            {isPublishing ? "Publishing..." : "Publish Now"}
                        </Button>
                    )}
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}


