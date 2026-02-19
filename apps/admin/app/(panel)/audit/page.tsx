
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
                <h1 className="text-3xl font-bold">Журнал аудита</h1>
            </div>

            <Card>
                <CardHeader><CardTitle>Поток активности</CardTitle></CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Время</TableHead>
                                <TableHead>Действие</TableHead>
                                <TableHead>Актор</TableHead>
                                <TableHead>Цель</TableHead>
                                <TableHead>IP</TableHead>
                                <TableHead className="text-right">Детали</TableHead>
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
                        <DialogTitle>Детали записи аудита</DialogTitle>
                        <DialogDescription>
                            ID: {selectedLog?.id}
                        </DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div><strong>Действие:</strong> {selectedLog?.action}</div>
                            <div><strong>Актор:</strong> {selectedLog?.actor_fingerprint}</div>
                            <div><strong>IP:</strong> {selectedLog?.ip_address}</div>
                            <div><strong>User Agent:</strong> {selectedLog?.user_agent}</div>
                        </div>
                        <div>
                            <h3 className="font-semibold mb-2 flex items-center gap-2">
                                <FileJson className="h-4 w-4" /> Изменения (JSON)
                            </h3>
                            <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-xs">
                                {selectedLog?.diff_json ? JSON.stringify(JSON.parse(selectedLog.diff_json), null, 2) : 'Нет данных об изменениях'}
                            </pre>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </div>
    )
}




