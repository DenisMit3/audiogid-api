'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import PoiForm from '@/components/PoiForm';

const API_URL = '/api/proxy';

export default function EditPoiPage({ params }: { params: { id: string } }) {
    const router = useRouter();
    const [poi, setPoi] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const token = localStorage.getItem('admin_token');
        if (!token) return;

        fetch(`${API_URL}/v1/admin/pois/${params.id}`, {
            headers: { 'Authorization': `Bearer ${token}` }
        })
            .then(res => {
                if (!res.ok) throw new Error('Не удалось загрузить');
                return res.json();
            })
            .then(data => {
                setPoi(data);
                setLoading(false);
            })
            .catch(err => {
                console.error(err);
                setLoading(false);
            });
    }, [params.id]);

    if (loading) return <div style={{ padding: 20 }}>Загрузка...</div>;
    if (!poi) return <div style={{ padding: 20 }}>Точка не найдена или ошибка загрузки</div>;

    return (
        <div style={{ padding: 20 }}>
            <h1>Редактировать точку: {(poi as any).title_ru}</h1>
            <PoiForm poi={poi} onSuccess={() => router.push('/dashboard')} />
        </div>
    );
}
