-- Создаем grant для тестового устройства
INSERT INTO entitlement_grants (id, device_anon_id, entitlement_id, source, source_ref, granted_at)
VALUES (
    'a0000001-0000-0000-0000-000000000001',
    'test123',
    'e0000001-0000-0000-0000-000000000001',
    'system',
    'free_zoo_tour_test',
    NOW()
) ON CONFLICT (source_ref) DO NOTHING;

SELECT 'Grant created' as status;
