
import { useEffect, useState } from 'react';
import { io, Socket } from 'socket.io-client';

const WS_URL = process.env.NEXT_PUBLIC_WS_URL || 'wss://audiogid-api.vercel.app';

type JobUpdate = {
    job_id: string;
    status: string;
    progress: number;
};

export const useJobsWebSocket = (onUpdate?: (update: JobUpdate) => void) => {
    const [socket, setSocket] = useState<Socket | null>(null);
    const [isConnected, setIsConnected] = useState(false);

    useEffect(() => {
        const token = localStorage.getItem('admin_token');
        const socketInstance = io(WS_URL, {
            query: { token },
            transports: ['websocket'],
            path: '/v1/admin/jobs/ws' // Path must match API router
        });

        socketInstance.on('connect', () => {
            console.log('WS Connected');
            setIsConnected(true);
        });

        socketInstance.on('disconnect', () => {
            console.log('WS Disconnected');
            setIsConnected(false);
        });

        socketInstance.on('message', (msg: string) => {
            try {
                const data = JSON.parse(msg);
                if (data.type === 'job_update' && onUpdate) {
                    onUpdate(data);
                }
            } catch (e) {
                console.error("WS Parse Error", e);
            }
        });

        setSocket(socketInstance);

        return () => {
            socketInstance.disconnect();
        };
    }, []);

    return { isConnected };
};
