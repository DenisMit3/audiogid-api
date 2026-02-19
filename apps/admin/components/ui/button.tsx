import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
    "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-1 disabled:pointer-events-none disabled:opacity-50 active:scale-[0.97]",
    {
        variants: {
            variant: {
                default:
                    "bg-gradient-to-r from-primary to-primary/90 text-primary-foreground shadow-sm hover:shadow-md hover:brightness-110 active:brightness-95",
                destructive:
                    "bg-gradient-to-r from-destructive to-destructive/90 text-destructive-foreground shadow-sm hover:shadow-md hover:brightness-110",
                outline:
                    "border border-input bg-background hover:bg-accent hover:text-accent-foreground hover:border-primary/30",
                secondary:
                    "bg-secondary text-secondary-foreground hover:bg-secondary/80",
                ghost: 
                    "hover:bg-accent hover:text-accent-foreground",
                link: 
                    "text-primary underline-offset-4 hover:underline",
                success:
                    "bg-gradient-to-r from-emerald-500 to-emerald-600 text-white shadow-sm hover:shadow-md hover:brightness-110",
                warning:
                    "bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-sm hover:shadow-md hover:brightness-110",
                info:
                    "bg-gradient-to-r from-blue-500 to-cyan-500 text-white shadow-sm hover:shadow-md hover:brightness-110",
                glow:
                    "bg-gradient-to-r from-primary to-accent text-white shadow-lg shadow-primary/30 hover:shadow-xl hover:shadow-primary/40",
            },
            size: {
                default: "h-8 px-3 py-1.5",
                sm: "h-7 rounded-md px-2.5 text-xs",
                lg: "h-9 rounded-md px-4",
                icon: "h-8 w-8",
                xs: "h-6 px-2 text-xs rounded",
            },
        },
        defaultVariants: {
            variant: "default",
            size: "default",
        },
    }
)

export interface ButtonProps
    extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
    asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
    ({ className, variant, size, asChild = false, ...props }, ref) => {
        const Comp = asChild ? Slot : "button"
        return (
            <Comp
                className={cn(buttonVariants({ variant, size, className }))}
                ref={ref}
                {...props}
            />
        )
    }
)
Button.displayName = "Button"

export { Button, buttonVariants }
