# Audio Guide API

Backend for Audio Guide 2026.
Built with FastAPI, SQLModel, and PostgreSQL + PostGIS.

## 🚀 Quick Links

- **API Docs**: [OpenAPI Spec](./apps/api/openapi.yaml)
- **Architecture**: [Full Documentation](./docs/ARCHITECTURE.md)
- **Getting Started**: [Developer Guide](./docs/GETTING_STARTED.md)
- **API Examples**: [Code Snippets](./docs/API_EXAMPLES.md)
- **Contributing**: [Contribution Guidelines](./CONTRIBUTING.md)
- **FAQ**: [Frequently Asked Questions](./docs/FAQ.md)

## ✨ Status

- **Cloud.ru Deployment**: Active ✅
- **Database**: PostgreSQL + PostGIS (локально на Cloud.ru)
- **API Version**: 1.13.0
- **Server**: http://82.202.159.64:8000/v1
- **Admin Panel**: http://82.202.159.64:3080

## 📚 Documentation Index

### For Developers
- [Getting Started](./docs/GETTING_STARTED.md) - Start here
- [API Reference](./docs/api.md) - Endpoints and Schema
- [API Examples](./docs/API_EXAMPLES.md) - Code snippets
- [Architecture](./docs/ARCHITECTURE.md) - System design

### For Operations
- [Runbook](./docs/runbook.md) - Deployment and Operations
- [Status Tracker](./docs/STATUS.md) - Feature implementation status

### For Contributors
- [Contributing Guidelines](./CONTRIBUTING.md)
- [PR Templates](./PR_3.md) - Examples

### For End Users
- [User Guide](./docs/USER_GUIDE.md) - Admin Panel Usage
- [FAQ](./docs/FAQ.md) - Common Questions

## 🛠️ Tech Stack

- **Backend**: FastAPI + Python 3.11+
- **Database**: PostgreSQL + PostGIS
- **Mobile**: Flutter + Riverpod
- **Admin Panel**: Next.js 14.1 + React 18
- **Infrastructure**: Cloud.ru + QStash

## 📦 Project Structure

```
Audiogid/
├── apps/
│   ├── api/              # FastAPI backend
│   └── mobile_flutter/   # Flutter mobile app
├── packages/
│   └── api_client/       # Generated API client
├── docs/                 # Documentation
└── README.md             # This file
```

## 🚀 Quick Start

### Backend (FastAPI)

```bash
cd apps/api
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn index:app --reload
```

### Mobile (Flutter)

```bash
cd apps/mobile_flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=FLAVOR=dev
```

## 📖 Key Features

- Offline-first API with ETag/Caching
- JWT Authentication with blacklist
- Billing: Apple/Google/YooKassa
- Background Jobs via QStash
- PostGIS for geolocation
- Multi-tenant support (kaliningrad_city, kaliningrad_oblast)

## 🔗 Useful Links

- **Production API**: http://82.202.159.64:8000/v1
- **Admin Panel**: http://82.202.159.64:3080
- **OpenAPI Swagger**: http://82.202.159.64:8000/docs
- **GitHub**: https://github.com/DenisMit3/audiogid-api
- **Issues**: https://github.com/DenisMit3/audiogid-api/issues

## ❓ Need Help?

- Check [FAQ](./docs/FAQ.md) for common questions
- Read [Getting Started](./docs/GETTING_STARTED.md) guide
- See [API Examples](./docs/API_EXAMPLES.md) for code samples
- Review [Contributing Guidelines](./CONTRIBUTING.md)

## 📝 License

All rights reserved © 2026 Audiogid Team.