
"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import useSWR from "swr"
import { useState } from "react"
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table"
import { Eye, FileJson } from "lucide-react"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function AuditPage() {
    const { data: logs } = useSWR('/api/proxy/admin/audit/logs', fetcher);
    const [selectedLog, setSelectedLog] = useState<any>(null);

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Audit Logs</h1>
            </div>

            <Card>
                <CardHeader><CardTitle>Activity Stream</CardTitle></CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Timestamp</TableHead>
                                <TableHead>Action</TableHead>
                                <TableHead>Actor</TableHead>
                                <TableHead>Target</TableHead>
                                <TableHead>IP</TableHead>
                                <TableHead className="text-right">Details</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {logs?.map((log: any) => (
                                <TableRow key={log.id}>
                                    <TableCell className="text-muted-foreground whitespace-nowrap">
                                        {new Date(log.timestamp).toLocaleString()}
                                    </TableCell>
                                    <TableCell>
                                        <div className="font-medium">{log.action}</div>
                                    </TableCell>
                                    <TableCell>{log.actor_fingerprint}</TableCell>
                                    <TableCell className="font-mono text-xs">{log.target_id}</TableCell>
                                    <TableCell>{log.ip_address}</TableCell>
                                    <TableCell className="text-right">
                                        <Button variant="ghost" size="sm" onClick={() => setSelectedLog(log)}>
                                            <Eye className="h-4 w-4" />
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>

            <Dialog open={!!selectedLog} onOpenChange={(open) => !open && setSelectedLog(null)}>
                <DialogContent className="max-w-3xl max-h-[80vh] overflow-auto">
                    <DialogHeader>
                        <DialogTitle>Audit Log Details</DialogTitle>
                        <DialogDescription>
                            ID: {selectedLog?.id}
                        </DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div><strong>Action:</strong> {selectedLog?.action}</div>
                            <div><strong>Actor:</strong> {selectedLog?.actor_fingerprint}</div>
                            <div><strong>IP:</strong> {selectedLog?.ip_address}</div>
                            <div><strong>User Agent:</strong> {selectedLog?.user_agent}</div>
                        </div>
                        <div>
                            <h3 className="font-semibold mb-2 flex items-center gap-2">
                                <FileJson className="h-4 w-4" /> Changes (JSON)
                            </h3>
                            <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-xs">
                                {selectedLog?.diff_json ? JSON.stringify(JSON.parse(selectedLog.diff_json), null, 2) : 'No diff data'}
                            </pre>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </div>
    )
}

