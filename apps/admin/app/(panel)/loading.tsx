import { Skeleton } from "@/components/ui/skeleton"
import { Card, CardContent, CardHeader } from "@/components/ui/card"

export default function Loading() {
    return (
        <div className="flex flex-col space-y-8 w-full p-8">
            {/* Header Skeleton */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-primary/5 via-accent/5 to-primary/5 p-8 border border-primary/10">
                <div className="flex items-center justify-between">
                    <div className="space-y-3">
                        <Skeleton className="h-10 w-[250px] rounded-lg" />
                        <Skeleton className="h-5 w-[350px] rounded-lg" />
                    </div>
                    <div className="flex gap-3">
                        <Skeleton className="h-10 w-[130px] rounded-lg" />
                        <Skeleton className="h-10 w-[130px] rounded-lg" />
                    </div>
                </div>
            </div>

            {/* KPI Cards Skeleton */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                {[...Array(4)].map((_, i) => (
                    <Card key={i} className="overflow-hidden">
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <Skeleton className="h-4 w-[120px] rounded" />
                            <Skeleton className="h-10 w-10 rounded-xl" />
                        </CardHeader>
                        <CardContent>
                            <Skeleton className="h-9 w-[80px] mb-3 rounded" />
                            <div className="flex items-center gap-2">
                                <Skeleton className="h-5 w-[60px] rounded-full" />
                                <Skeleton className="h-4 w-[80px] rounded" />
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {/* Charts Skeleton */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                <Card className="col-span-4 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <div className="flex items-center justify-between">
                            <div className="space-y-2">
                                <Skeleton className="h-5 w-[180px] rounded" />
                                <Skeleton className="h-4 w-[250px] rounded" />
                            </div>
                            <Skeleton className="h-6 w-[80px] rounded-full" />
                        </div>
                    </CardHeader>
                    <CardContent className="pt-6">
                        <Skeleton className="h-[300px] w-full rounded-xl" />
                    </CardContent>
                </Card>
                <Card className="col-span-3 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <Skeleton className="h-5 w-[150px] rounded" />
                        <Skeleton className="h-4 w-[200px] rounded mt-2" />
                    </CardHeader>
                    <CardContent className="pt-6">
                        <Skeleton className="h-[300px] w-full rounded-xl" />
                    </CardContent>
                </Card>
            </div>

            {/* Activity & Top Content Skeleton */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                <Card className="col-span-4 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <Skeleton className="h-5 w-[180px] rounded" />
                    </CardHeader>
                    <CardContent className="pt-4">
                        <div className="space-y-2">
                            {[...Array(5)].map((_, i) => (
                                <div key={i} className="flex items-center gap-4 p-3 rounded-xl">
                                    <Skeleton className="h-10 w-10 rounded-xl" />
                                    <div className="space-y-2 flex-1">
                                        <Skeleton className="h-4 w-full rounded" />
                                        <Skeleton className="h-3 w-[60%] rounded" />
                                    </div>
                                    <Skeleton className="h-6 w-[80px] rounded-md" />
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
                <Card className="col-span-3 overflow-hidden">
                    <CardHeader className="border-b border-border/50 bg-muted/20">
                        <Skeleton className="h-5 w-[150px] rounded" />
                    </CardHeader>
                    <CardContent className="p-0">
                        <div className="divide-y divide-border/50">
                            {[...Array(5)].map((_, i) => (
                                <div key={i} className="flex items-center gap-3 p-4">
                                    <Skeleton className="h-8 w-8 rounded-lg" />
                                    <div className="space-y-2 flex-1">
                                        <Skeleton className="h-4 w-[120px] rounded" />
                                        <Skeleton className="h-5 w-[60px] rounded-full" />
                                    </div>
                                    <Skeleton className="h-6 w-[50px] rounded" />
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}




