'use client';
import { useRouter } from 'next/navigation';
import PoiForm from '@/components/PoiForm';

export default function NewPoiPage() {
    const router = useRouter();
    return (
        <div style={{ padding: 20 }}>
            <h1>Создать новую точку</h1>
            <PoiForm onSuccess={() => router.push('/dashboard')} />
        </div>
    );
}




