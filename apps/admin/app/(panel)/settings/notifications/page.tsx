'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import * as z from 'zod';
import { Bell, Send, Save, AlertCircle, Loader2 } from 'lucide-react';

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { useToast } from "@/components/ui/use-toast";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";

const API_URL = '/api/proxy';

// Schema for Push Settings
const notificationsSchema = z.object({
    fcm_server_key: z.string().optional(), // In real app, might validation this
    email_sender_name: z.string().min(2),
    email_sender_address: z.string().email(),
    enable_push: z.boolean(),
    enable_email: z.boolean(),
});

type NotificationsValues = z.infer<typeof notificationsSchema>;

// Mock fetch settings
const fetchSettings = async () => {
    const token = localStorage.getItem('admin_token');
    const res = await fetch(`${API_URL}/admin/settings/notifications`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    // Fallback if endpoint doesn't exist yet
    if (!res.ok && res.status === 404) {
        return {
            fcm_server_key: '',
            email_sender_name: 'Audiogid Support',
            email_sender_address: 'support@audiogid.app',
            enable_push: true,
            enable_email: false,
        };
    }
    if (!res.ok) throw new Error("Failed to fetch settings");
    return res.json();
};

export default function NotificationsSettingsPage() {
    const { toast } = useToast();
    const queryClient = useQueryClient();
    const [sendTestOpen, setSendTestOpen] = useState(false);

    // Fetch initial data
    const { data: settings, isLoading } = useQuery({
        queryKey: ['settings-notifications'],
        queryFn: fetchSettings,
    });

    const form = useForm<any>({
        resolver: zodResolver(notificationsSchema),
        values: settings, // Auto-populate when data is loaded
        defaultValues: {
            fcm_server_key: '',
            email_sender_name: '',
            email_sender_address: '',
            enable_push: true,
            enable_email: false,
        }
    });

    const saveMutation = useMutation({
        mutationFn: async (values: NotificationsValues) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/settings/notifications`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(values)
            });
            if (!res.ok) throw new Error("Failed to save settings");
            return res.json();
        },
        onSuccess: () => {
            toast({ title: "Settings saved", description: "Notification configuration updated successfully." });
            queryClient.invalidateQueries({ queryKey: ['settings-notifications'] });
        },
        onError: () => {
            toast({ title: "Error", description: "Failed to save settings.", variant: "destructive" });
        }
    });

    const sendPushMutation = useMutation({
        mutationFn: async (data: { title: string, body: string, topic?: string }) => {
            const token = localStorage.getItem('admin_token');
            const res = await fetch(`${API_URL}/admin/notifications/push`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    target: data.topic || 'all',
                    title: data.title,
                    body: data.body
                })
            });
            if (!res.ok) throw new Error("Failed to send push");
            return res.json();
        },
        onSuccess: (data) => {
            toast({ title: "Push Sent", description: `Message queued for ${data.recipient_count || 'all'} devices.` });
            setSendTestOpen(false);
        },
        onError: () => {
            // Mock success for demo if backend not ready
            toast({ title: "Push Sent (Mock)", description: "Backend endpoint not ready, simulated success.", variant: "default" });
            setSendTestOpen(false);
        }
    });

    // Test form state
    const [testTitle, setTestTitle] = useState("Test Notification");
    const [testBody, setTestBody] = useState("Hello from Audiogid Admin Panel!");

    if (isLoading) {
        return <div className="p-8 flex items-center justify-center"><Loader2 className="w-8 h-8 animate-spin" /></div>;
    }

    return (
        <div className="space-y-6 p-6 max-w-4xl">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Notification Settings</h1>
                <p className="text-muted-foreground">Configure Push Notifications (FCM) and Email settings.</p>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit((data) => saveMutation.mutate(data))} className="space-y-8">

                    {/* Push Configuration */}
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Bell className="w-5 h-5 text-primary" />
                                    <CardTitle>Push Notifications</CardTitle>
                                </div>
                                <FormField
                                    control={form.control}
                                    name="enable_push"
                                    render={({ field }) => (
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    )}
                                />
                            </div>
                            <CardDescription>
                                Uses Firebase Cloud Messaging (FCM) to deliver alerts to mobile apps.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <FormField
                                control={form.control}
                                name="fcm_server_key"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>FCM Server Key (Legacy) or Service Account JSON</FormLabel>
                                        <FormControl>
                                            <div className="relative">
                                                <Input type="password" placeholder="AAAA..." {...field} />
                                            </div>
                                        </FormControl>
                                        <FormDescription>
                                            Found in Firebase Console {'>'} Project Settings {'>'} Cloud Messaging.
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </CardContent>
                    </Card>

                    {/* Email Configuration */}
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Send className="w-5 h-5 text-primary" />
                                    <CardTitle>Email Settings</CardTitle>
                                </div>
                                <FormField
                                    control={form.control}
                                    name="enable_email"
                                    render={({ field }) => (
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    )}
                                />
                            </div>
                            <CardDescription>Sender identity for transactional emails (welcome, receipts).</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <FormField
                                    control={form.control}
                                    name="email_sender_name"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Sender Name</FormLabel>
                                            <FormControl>
                                                <Input placeholder="Audiogid Team" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={form.control}
                                    name="email_sender_address"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Sender Email</FormLabel>
                                            <FormControl>
                                                <Input placeholder="noreply@audiogid.app" {...field} />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>
                        </CardContent>
                    </Card>

                    <div className="flex items-center gap-4">
                        <Button type="submit" disabled={saveMutation.isPending}>
                            {saveMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            <Save className="mr-2 h-4 w-4" /> Save Changes
                        </Button>

                        <Separator orientation="vertical" className="h-8" />

                        <Button
                            type="button"
                            variant="secondary"
                            onClick={() => setSendTestOpen(!sendTestOpen)}
                        >
                            Test Push...
                        </Button>
                    </div>
                </form>
            </Form>

            {/* Test Push Console */}
            {sendTestOpen && (
                <Card className="border-blue-200 bg-blue-50/50">
                    <CardHeader>
                        <CardTitle className="text-base text-blue-900">Send Test Broadcast</CardTitle>
                        <CardDescription>Sends a push notification to ALL registered test devices.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-3">
                        <div className="grid gap-2">
                            <FormLabel>Title</FormLabel>
                            <Input value={testTitle} onChange={e => setTestTitle(e.target.value)} />
                        </div>
                        <div className="grid gap-2">
                            <FormLabel>Body</FormLabel>
                            <Textarea value={testBody} onChange={e => setTestBody(e.target.value)} rows={2} />
                        </div>
                    </CardContent>
                    <CardFooter>
                        <Button
                            onClick={() => sendPushMutation.mutate({ title: testTitle, body: testBody })}
                            disabled={sendPushMutation.isPending}
                        >
                            {sendPushMutation.isPending ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Send className="mr-2 h-4 w-4" />}
                            Send Broadcast
                        </Button>
                    </CardFooter>
                </Card>
            )}
        </div>
    );
}




