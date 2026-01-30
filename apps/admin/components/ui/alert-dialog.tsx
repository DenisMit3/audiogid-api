// Adapted from Shadcn UI - Simplified for manual install
"use client"

import * as React from "react"
import {
    AlertDialog as AlertDialogPrimitive,
    AlertDialogAction as AlertDialogActionPrimitive,
    AlertDialogCancel as AlertDialogCancelPrimitive,
    AlertDialogContent as AlertDialogContentPrimitive,
    AlertDialogDescription as AlertDialogDescriptionPrimitive,
    AlertDialogOverlay as AlertDialogOverlayPrimitive,
    AlertDialogPortal as AlertDialogPortalPrimitive,
    AlertDialogTitle as AlertDialogTitlePrimitive,
    AlertDialogTrigger as AlertDialogTriggerPrimitive,
} from "@radix-ui/react-alert-dialog"

// IMPORTANT: We need to properly export from package or mock if package fails
// Using standard shadcn structure assuming package installs correctly.

import { cn } from "@/lib/utils"
// import { buttonVariants } from "@/components/ui/button"

const AlertDialog = AlertDialogPrimitive
const AlertDialogTrigger = AlertDialogTriggerPrimitive
const AlertDialogPortal = AlertDialogPortalPrimitive

const AlertDialogOverlay = React.forwardRef<
    React.ElementRef<typeof AlertDialogOverlayPrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogOverlayPrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogOverlayPrimitive
        className={cn(
            "fixed inset-0 z-50 bg-black/80  data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            className
        )}
        {...props}
        ref={ref}
    />
))
AlertDialogOverlay.displayName = AlertDialogOverlayPrimitive.displayName

const AlertDialogContent = React.forwardRef<
    React.ElementRef<typeof AlertDialogContentPrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogContentPrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogPortal>
        <AlertDialogOverlay />
        <AlertDialogContentPrimitive
            ref={ref}
            className={cn(
                "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border border-slate-200 bg-white p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg dark:border-slate-800 dark:bg-slate-950",
                className
            )}
            {...props}
        />
    </AlertDialogPortal>
))
AlertDialogContent.displayName = AlertDialogContentPrimitive.displayName

const AlertDialogHeader = ({
    className,
    ...props
}: React.HTMLAttributes<HTMLDivElement>) => (
    <div
        className={cn(
            "flex flex-col space-y-2 text-center sm:text-left",
            className
        )}
        {...props}
    />
)
AlertDialogHeader.displayName = "AlertDialogHeader"

const AlertDialogFooter = ({
    className,
    ...props
}: React.HTMLAttributes<HTMLDivElement>) => (
    <div
        className={cn(
            "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2",
            className
        )}
        {...props}
    />
)
AlertDialogFooter.displayName = "AlertDialogFooter"

const AlertDialogTitle = React.forwardRef<
    React.ElementRef<typeof AlertDialogTitlePrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogTitlePrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogTitlePrimitive
        ref={ref}
        className={cn("text-lg font-semibold", className)}
        {...props}
    />
))
AlertDialogTitle.displayName = AlertDialogTitlePrimitive.displayName

const AlertDialogDescription = React.forwardRef<
    React.ElementRef<typeof AlertDialogDescriptionPrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogDescriptionPrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogDescriptionPrimitive
        ref={ref}
        className={cn("text-sm text-slate-500 dark:text-slate-400", className)}
        {...props}
    />
))
AlertDialogDescription.displayName = AlertDialogDescriptionPrimitive.displayName

const AlertDialogAction = React.forwardRef<
    React.ElementRef<typeof AlertDialogActionPrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogActionPrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogActionPrimitive
        ref={ref}
        className={cn("inline-flex h-10 items-center justify-center rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-slate-50 ring-offset-white transition-colors hover:bg-slate-900/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 dark:bg-slate-50 dark:text-slate-900 dark:hover:bg-slate-50/90 dark:focus-visible:ring-slate-300", className)}
        {...props}
    />
))
AlertDialogAction.displayName = AlertDialogActionPrimitive.displayName

const AlertDialogCancel = React.forwardRef<
    React.ElementRef<typeof AlertDialogCancelPrimitive>,
    React.ComponentPropsWithoutRef<typeof AlertDialogCancelPrimitive>
>(({ className, ...props }, ref) => (
    <AlertDialogCancelPrimitive
        ref={ref}
        className={cn("inline-flex h-10 items-center justify-center rounded-md border border-slate-200 bg-white px-4 py-2 text-sm font-medium ring-offset-white transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 dark:border-slate-800 dark:bg-slate-950 dark:hover:bg-slate-800 dark:hover:text-slate-50 dark:focus-visible:ring-slate-300", className)}
        {...props}
    />
))
AlertDialogCancel.displayName = AlertDialogCancelPrimitive.displayName

export {
    AlertDialog,
    AlertDialogPortal,
    AlertDialogOverlay,
    AlertDialogTrigger,
    AlertDialogContent,
    AlertDialogHeader,
    AlertDialogFooter,
    AlertDialogTitle,
    AlertDialogDescription,
    AlertDialogAction,
    AlertDialogCancel,
}

