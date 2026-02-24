# Audio Guide API

Backend for Audio Guide 2026.
Built with FastAPI, SQLModel, and PostgreSQL + PostGIS.

## Status
- **Cloud.ru Deployment**: Active ✅
- **Database**: PostgreSQL + PostGIS (локально на Cloud.ru)
- **API Version**: 1.13.0
- **Server**: http://82.202.159.64:8000/v1
- **Admin Panel**: http://82.202.159.64:3080

## Quick Start

```bash
cd apps/api
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn index:app --reload
```

## Key Features
- Offline-first API с ETag/Caching
- JWT Authentication с blacklist
- Billing: Apple/Google/YooKassa
- Background Jobs через QStash
- PostGIS для геолокации

## Documentation
- OpenAPI Spec: `apps/api/openapi.yaml`
- Full Architecture: `docs/ARCHITECTURE.md`
