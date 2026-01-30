
'use client';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function GeneralSettings() {
    return (
        <div className="space-y-6 max-w-2xl p-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">General Settings</h1>
                <p className="text-muted-foreground">Basic application configuration.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Application Identity</CardTitle>
                    <CardDescription>Visible in emails and app metadata.</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="grid gap-2">
                        <Label>App Name</Label>
                        <Input defaultValue="Audiogid" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Support Email</Label>
                        <Input defaultValue="support@audiogid.app" />
                    </div>
                </CardContent>
            </Card>

            <div className="flex justify-end">
                <Button>Save Changes</Button>
            </div>
        </div>
    );
}
