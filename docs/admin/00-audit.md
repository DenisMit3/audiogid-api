# Admin Audit (28 Jan 2026)

## Доменные сущности + ERD (text)
- **City** (slug PK) -> 1...* Poi, Tour.
- **Poi** (id PK, city_slug FK, geo POINT) -> 1...* Media, Source, Narration, TourItem.
- **Tour** (id PK, city_slug FK) -> 1...* TourItem (link to Poi).
- **User** (id PK, role str) -> 1...* UserIdentity (phone/tg).
- **Events**: AppEvent, ContentEvent, PurchaseEvent (ts, anon_id).
- **Audit**: AuditLog (action, target_id, ip, diff_json).
- **Analytics**: AnalyticsDailyStats, UserCohort, RetentionMatrix, Funnel, FunnelStep, FunnelConversion.

## Таблицы
~30 tables, managed by Alembic. Key tables: `pois`, `tours`, `users`, `audit_logs`, `app_events`.

## Admin Capabilities
1.  **Content Management**:
    - POI: CRUD, Geolocation, Media, Narrations.
    - Tours: CRUD, Ordering, Publishing Gates (Validation).
2.  **Analytics**:
    - Overview: DAU, Revenue, Top Content.
    - Cohorts: Retention Heatmap (D0-D30).
    - Funnels: Conversion Steps analysis.
3.  **User Management**:
    - List users, filter by role.
    - Change Role (RBAC).
    - Audit Logs: View activity, diffs, IP.

## Gap List
- **Media**: Vercel Blob integration is token-based; need prod token.
- **Analytics**: Funnels need strict event ordering logic for deeper insights.
- **Users**: No promo codes or detailed billing history yet.
- **Deploy**: Cloud infrastructure (Vercel/Railway/AWS) needs configuration.

## Risks
1.  **Security**: JWT TTL short; need refresh token flow for long sessions.
2.  **Performance**: Event table growth; need partitioning strategy for >1M rows.
3.  **Data Consistency**: External job dependencies (QStash) need monitoring.

## Metric Definitions (30-metrics.md snippet)
- **DAU**: Unique anonymous IDs active in a day.
- **Retention**: % of cohort returning on Day N.
- **Funnel Drop-off**: Users completing Step N / Users completing Step N-1.
