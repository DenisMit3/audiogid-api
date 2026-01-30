'use client';

import { Database, Download, Upload, AlertTriangle } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

export default function BackupSettingsPage() {
    return (
        <div className="space-y-6 p-6 max-w-4xl">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Database Backups</h1>
                <p className="text-muted-foreground">Manage data snapshots and retention policies.</p>
            </div>

            <Alert>
                <AlertTriangle className="h-4 w-4" />
                <AlertTitle>Managed Infrastructure</AlertTitle>
                <AlertDescription>
                    Your database is hosted on <strong>Neon Serverless Postgres</strong>.
                    Point-in-time recovery (PITR) is enabled automatically with 7-day retention.
                </AlertDescription>
            </Alert>

            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Upload className="w-5 h-5" />
                            Direct Export
                        </CardTitle>
                        <CardDescription>Download a complete SQL dump of the current database state.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="bg-slate-950 text-slate-50 p-4 rounded-md font-mono text-xs overflow-x-auto">
                            pg_dump -h ep-plain-frog-123456.us-east-1.aws.neon.tech -U admin audiogid {'>'} backup_$(date +%F).sql
                        </div>
                    </CardContent>
                    <CardFooter>
                        <Button variant="outline" className="w-full" onClick={() => {
                            const token = localStorage.getItem('admin_token');
                            const url = `${process.env.NEXT_PUBLIC_API_URL}/admin/pois/export`;
                            // Fetch with auth, then download blob
                            fetch(url, { headers: { Authorization: `Bearer ${token}` } })
                                .then(res => res.blob())
                                .then(blob => {
                                    const url = window.URL.createObjectURL(blob);
                                    const a = document.createElement('a');
                                    a.href = url;
                                    a.download = `pois_export_${new Date().toISOString().split('T')[0]}.csv`;
                                    a.click();
                                });
                        }}>
                            <Download className="mr-2 w-4 h-4" />
                            Download CSV Archives
                        </Button>
                    </CardFooter>
                </Card>

                <Card className="opacity-75 relative overflow-hidden">
                    <div className="absolute inset-0 bg-slate-50/50 backdrop-blur-[1px] flex items-center justify-center z-10">
                        <span className="bg-slate-900 text-white px-3 py-1 rounded-full text-xs font-medium">Coming Soon</span>
                    </div>
                    <CardHeader>
                        <CardTitle>Restore Point</CardTitle>
                        <CardDescription>Rollback the database to a specific timeframe.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <p className="text-sm text-muted-foreground">
                            Restoring will overwrite current data. This action cannot be undone without another backup.
                        </p>
                    </CardContent>
                    <CardFooter>
                        <Button variant="destructive" className="w-full" disabled>
                            Restore Data...
                        </Button>
                    </CardFooter>
                </Card>
            </div>
        </div>
    );
}




