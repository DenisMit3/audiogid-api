-- Создание бесплатного entitlement для тура Лимпопо
-- Tour ID: db086913-97cd-4716-8f7e-1d14f31f40af

INSERT INTO entitlements (id, slug, scope, ref, title_ru, price_amount, price_currency, is_active)
VALUES (
    gen_random_uuid(),
    'tour_db086913-97cd-4716-8f7e-1d14f31f40af_free',
    'tour',
    'db086913-97cd-4716-8f7e-1d14f31f40af',
    'Бесплатный доступ: Лимпопо',
    0,
    'RUB',
    true
)
ON CONFLICT (slug) DO NOTHING;
