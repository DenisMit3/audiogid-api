
export const METRICS = {
    dau: {
        label: 'Daily Active Users',
        description: 'Unique anonymous device IDs active within 24h'
    },
    mau: {
        label: 'Monthly Active Users',
        description: 'Unique anonymous device IDs active within 30 days'
    },
    revenue: {
        label: 'Revenue',
        description: 'Total revenue from purchases'
    },
    conversion: {
        label: 'Conversion Rate',
        description: 'Percentage of active users who made a purchase'
    }
}

export type AnalyticsPeriod = '7d' | '30d' | '90d';
