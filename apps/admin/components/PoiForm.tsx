'use client';
import { useState } from 'react';

const API_URL = '/api/proxy';

export default function PoiForm({ poi, onSuccess }: { poi?: any, onSuccess: () => void }) {
    const [formData, setFormData] = useState({
        title_ru: poi?.title_ru || '',
        description_ru: poi?.description_ru || '',
        lat: poi?.lat || '',
        lon: poi?.lon || '',
        city_slug: poi?.city_slug || 'kaliningrad_city',
        is_active: poi?.is_active ?? true
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        const token = localStorage.getItem('admin_token');
        const url = poi
            ? `${API_URL}/v1/admin/pois/${poi.id}`
            : `${API_URL}/v1/admin/pois`;

        const method = poi ? 'PATCH' : 'POST';

        try {
            const res = await fetch(url, {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify(formData)
            });

            if (res.ok) {
                onSuccess();
            } else {
                const err = await res.json();
                alert(`Error saving POI: ${JSON.stringify(err)}`);
            }
        } catch (e) {
            alert('Network error');
        }
    };

    const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>, type: 'image' | 'audio') => {
        if (!e.target.files || !e.target.files[0] || !poi?.id) return;
        const file = e.target.files[0];
        const fd = new FormData();
        fd.append('file', file);

        const token = localStorage.getItem('admin_token');
        try {
            const res = await fetch(`${API_URL}/v1/admin/pois/${poi.id}/media_upload?media_type=${type}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` },
                body: fd
            });
            if (res.ok) {
                alert('Uploaded!');
                // We should ideally reload the POI data here, but for now just tell user.
                // Trigger onSuccess to maybe reload parent?
                // onSuccess(); // This might nav away. 
            } else {
                alert('Upload failed');
            }
        } catch (e) {
            alert('Upload error');
        }
    };

    return (
        <div style={{ fontFamily: 'sans-serif', maxWidth: 600 }}>
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 15 }}>
                <div>
                    <label style={{ display: 'block', marginBottom: 5, fontWeight: 'bold' }}>Title (RU)</label>
                    <input
                        required
                        value={formData.title_ru}
                        onChange={e => setFormData({ ...formData, title_ru: e.target.value })}
                        style={{ width: '100%', padding: 8, border: '1px solid #ccc', borderRadius: 4 }}
                    />
                </div>

                <div>
                    <label style={{ display: 'block', marginBottom: 5, fontWeight: 'bold' }}>City Slug</label>
                    <select
                        value={formData.city_slug}
                        onChange={e => setFormData({ ...formData, city_slug: e.target.value })}
                        style={{ width: '100%', padding: 8, border: '1px solid #ccc', borderRadius: 4 }}
                    >
                        <option value="kaliningrad_city">Kaliningrad City</option>
                        <option value="kaliningrad_oblast">Kaliningrad Oblast</option>
                    </select>
                </div>

                <div style={{ display: 'flex', gap: 10 }}>
                    <div style={{ flex: 1 }}>
                        <label style={{ display: 'block', marginBottom: 5, fontWeight: 'bold' }}>Lat</label>
                        <input
                            type="number" step="any"
                            value={formData.lat}
                            onChange={e => setFormData({ ...formData, lat: parseFloat(e.target.value) })}
                            style={{ width: '100%', padding: 8, border: '1px solid #ccc', borderRadius: 4 }}
                        />
                    </div>
                    <div style={{ flex: 1 }}>
                        <label style={{ display: 'block', marginBottom: 5, fontWeight: 'bold' }}>Lon</label>
                        <input
                            type="number" step="any"
                            value={formData.lon}
                            onChange={e => setFormData({ ...formData, lon: parseFloat(e.target.value) })}
                            style={{ width: '100%', padding: 8, border: '1px solid #ccc', borderRadius: 4 }}
                        />
                    </div>
                </div>

                <div>
                    <label style={{ display: 'block', marginBottom: 5, fontWeight: 'bold' }}>Description</label>
                    <textarea
                        value={formData.description_ru}
                        onChange={e => setFormData({ ...formData, description_ru: e.target.value })}
                        style={{ width: '100%', height: 100, padding: 8, border: '1px solid #ccc', borderRadius: 4, fontFamily: 'sans-serif' }}
                    />
                </div>

                <label style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <input
                        type="checkbox"
                        checked={formData.is_active}
                        onChange={e => setFormData({ ...formData, is_active: e.target.checked })}
                    />
                    Active
                </label>

                <button type="submit" style={{ padding: 12, background: '#0070f3', color: 'white', border: 'none', borderRadius: 4, cursor: 'pointer', fontWeight: 'bold' }}>
                    {poi ? 'Update POI Details' : 'Create POI'}
                </button>
            </form>

            {poi && (
                <div style={{ marginTop: 30, borderTop: '2px solid #eee', paddingTop: 20 }}>
                    <h3>Media & Files</h3>

                    <div style={{ marginBottom: 20 }}>
                        <label style={{ display: 'block', fontWeight: 'bold', marginBottom: 5 }}>Upload Audio (MP3)</label>
                        <input type="file" accept="audio/*" onChange={e => handleUpload(e, 'audio')} />
                    </div>

                    <div style={{ marginBottom: 20 }}>
                        <label style={{ display: 'block', fontWeight: 'bold', marginBottom: 5 }}>Upload Image (JPG/PNG)</label>
                        <input type="file" accept="image/*" onChange={e => handleUpload(e, 'image')} />
                    </div>

                    {poi.media && poi.media.length > 0 && (
                        <div>
                            <h4>Attached Media:</h4>
                            <ul style={{ listStyle: 'none', padding: 0 }}>
                                {poi.media.map((m: any, i: number) => (
                                    <li key={i} style={{ marginBottom: 5, padding: 5, background: '#f9f9f9' }}>
                                        <strong>[{m.media_type}]</strong>
                                        <a href={m.url} target="_blank" style={{ marginLeft: 10 }}>{m.url.split('/').pop()}</a>
                                    </li>
                                ))}
                            </ul>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}
