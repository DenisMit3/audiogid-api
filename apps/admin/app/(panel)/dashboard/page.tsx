'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

const API_URL = '/api/proxy';

export default function Dashboard() {
    const router = useRouter();
    const [pois, setPois] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // SECURITY REMOVED BY USER REQUEST
        // Just fetch data. Backend allows everyone.
        fetch(`${API_URL}/v1/admin/pois?limit=100`, {
            // Send dummy token just in case middleware parses it, though deps.py bypasses it.
            headers: { 'Authorization': `Bearer bypass-security` }
        })
            .then(res => res.json())
            .then(data => {
                if (Array.isArray(data)) {
                    setPois(data);
                }
                setLoading(false);
            })
            .catch(err => {
                console.error(err);
                setLoading(false);
            });
    }, [router]);

    if (loading) return <div style={{ padding: 20 }}>Loading...</div>;

    return (
        <div style={{ padding: 20, fontFamily: 'sans-serif' }}>
            <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
                <h1>POI Management</h1>
                <div>
                    <span style={{ marginRight: 10 }}>Admin</span>
                    <button onClick={() => {
                        localStorage.removeItem('admin_token');
                        router.push('/login');
                    }}>Logout</button>
                </div>
            </header>

            <div style={{ marginBottom: 20 }}>
                <button
                    style={{ padding: '8px 16px', background: '#0070f3', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer' }}
                    onClick={() => router.push('/dashboard/pois/new')}
                >
                    + Create New POI
                </button>
            </div>

            <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20 }}>
                <thead>
                    <tr style={{ textAlign: 'left', borderBottom: '2px solid #ccc' }}>
                        <th style={{ padding: 10 }}>Title</th>
                        <th style={{ padding: 10 }}>City</th>
                        <th style={{ padding: 10 }}>ID</th>
                        <th style={{ padding: 10 }}>Coords</th>
                        <th style={{ padding: 10 }}>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    {pois.map(poi => (
                        <tr key={poi.id} style={{ borderBottom: '1px solid #eee' }}>
                            <td style={{ padding: 10, fontWeight: 'bold' }}>{poi.title_ru}</td>
                            <td style={{ padding: 10 }}>{poi.city_slug}</td>
                            <td style={{ padding: 10, fontFamily: 'monospace', fontSize: '12px' }}>{poi.id}</td>
                            <td style={{ padding: 10 }}>{poi.lat?.toFixed(4)}, {poi.lon?.toFixed(4)}</td>
                            <td style={{ padding: 10 }}>
                                <button
                                    style={{ marginRight: 10, cursor: 'pointer' }}
                                    onClick={() => router.push(`/dashboard/pois/${poi.id}`)}
                                >
                                    Edit
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
