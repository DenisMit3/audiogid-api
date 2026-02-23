-- Создаем бесплатный entitlement для тура Зоопарк Лимпопо
INSERT INTO entitlements (id, slug, scope, ref, title_ru, price_amount, price_currency, is_active)
VALUES (
    'e0000001-0000-0000-0000-000000000001',
    'zoo_limpopo_free',
    'tour',
    'b2000001-0000-0000-0000-000000000001',
    'Бесплатный доступ к туру Зоопарк Лимпопо',
    0.0,
    'RUB',
    true
) ON CONFLICT (slug) DO NOTHING;

-- Создаем grant для тестового устройства (можно использовать любой device_anon_id)
-- Для реального теста нужно использовать device_anon_id из телефона
INSERT INTO entitlement_grants (id, device_anon_id, entitlement_id, source, source_ref, granted_at)
VALUES (
    'g0000001-0000-0000-0000-000000000001',
    'test123',
    'e0000001-0000-0000-0000-000000000001',
    'system',
    'free_zoo_tour_test',
    NOW()
) ON CONFLICT (source_ref) DO NOTHING;

SELECT 'Entitlement created' as status;
