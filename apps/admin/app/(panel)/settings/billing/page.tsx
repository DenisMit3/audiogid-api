
'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default function BillingSettingsPage() {
    return (
        <div className="space-y-6 max-w-5xl">
            <div>
                <h2 className="text-2xl font-bold tracking-tight">Billing & Plans</h2>
                <p className="text-muted-foreground">Configure In-App Purchases and Subscription tiers.</p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Products Configuration</CardTitle>
                    <CardDescription>Mapped from App Store / Play Store IDs</CardDescription>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Product ID</TableHead>
                                <TableHead>Name</TableHead>
                                <TableHead>Type</TableHead>
                                <TableHead>Price (USD)</TableHead>
                                <TableHead>Status</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            <TableRow>
                                <TableCell className="font-mono">com.audiogid.full_access_1m</TableCell>
                                <TableCell>Full Access (Monthly)</TableCell>
                                <TableCell>Subscription</TableCell>
                                <TableCell>$9.99</TableCell>
                                <TableCell><Badge>Active</Badge></TableCell>
                            </TableRow>
                            <TableRow>
                                <TableCell className="font-mono">com.audiogid.city_kaliningrad</TableCell>
                                <TableCell>Kaliningrad Bundle</TableCell>
                                <TableCell>Non-Consumable</TableCell>
                                <TableCell>$4.99</TableCell>
                                <TableCell><Badge>Active</Badge></TableCell>
                            </TableRow>
                        </TableBody>
                    </Table>
                    <div className="pt-4 flex justify-end">
                        <Button variant="outline">Sync from Stores</Button>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}


