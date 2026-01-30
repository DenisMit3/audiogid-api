# 🎧 AUDIOGID ADMIN PANEL — WORLD-CLASS ENGINEERING SPECIFICATION

**Version:** 3.0 — Complete Modernization  
**Date:** 29 January 2026  
**Status:** 📋 READY FOR IMPLEMENTATION  
**Type:** Professional Engineering Prompt for AI Agent Execution

---

## 📌 EXECUTIVE SUMMARY

This document is a comprehensive engineering specification for building a **world-class Audio Guide Admin Panel**. The requirements are based on analysis of **10+ leading platforms** in the audio guide industry:

| Platform | Country | Key Strengths Analyzed |
|----------|---------|------------------------|
| **izi.TRAVEL** | Netherlands | Multi-project CMS, API integration, self-sufficient publishing |
| **VoiceMap** | South Africa | GPS-triggered playback, Mapmaker CMS, voucher system, heatmaps |
| **SmartGuide** | Czech Republic | Big data dashboards, GPS heatmaps, GDPR-compliant analytics |
| **STQRY** | New Zealand | No-code builder, geofencing, membership monetization |
| **Nubart** | Germany | PWA-first, anonymous statistics, feedback surveys |
| **Orpheo Group** | France | Enterprise hardware+software, accessibility focus |
| **Cortina Productions** | USA | DeepL translation, professional TTS voices |
| **Cuseum** | USA | Membership integration, AI personalization |
| **Attractions.io** | UK | Theme park scale, real-time operations |
| **My Smart Journey** | Canada | Gamification, AR/VR integration |

---

## 🎯 PROJECT OBJECTIVES

### Primary Goal
Transform the existing Audiogid Admin Panel into **the most functional, user-friendly, and technologically advanced** audio guide management system available, surpassing industry leaders.

### Success Criteria
1. ✅ **Zero crashes** — All navigation, buttons, and forms must work flawlessly
2. ✅ **Sub-200ms response** — Optimistic updates, edge caching, efficient queries
3. ✅ **Mobile app sync** — Real-time data synchronization with Flutter app
4. ✅ **Feature parity+** — Match and exceed features of top 10 competitors
5. ✅ **Professional UX** — Modern, intuitive interface with dark mode support

---

## 🏗️ ARCHITECTURAL REQUIREMENTS

### Technology Stack (Non-Negotiable)

```yaml
Frontend (apps/admin/):
  Framework: Next.js 14+ with App Router
  Language: TypeScript 5.3+ (strict mode)
  State: TanStack Query v5 (React Query)
  Forms: React Hook Form + Zod validation
  Tables: TanStack Table v8 with virtualization
  UI Components: shadcn/ui + Radix UI + Tailwind CSS
  Drag & Drop: @dnd-kit/core + @dnd-kit/sortable
  Charts: Recharts 2.12+
  Real-time: Socket.IO client or native WebSocket
  Maps: Mapbox GL JS or MapLibre GL
  Media: react-dropzone + wavesurfer.js (audio visualization)
  i18n: next-intl (Russian + English minimum)

Backend (apps/api/):
  Framework: FastAPI (Python 3.11+)
  ORM: SQLModel + SQLAlchemy
  Database: PostgreSQL (Neon/Supabase)
  Caching: Redis (Upstash)
  Queue: QStash (Vercel)
  Storage: Vercel Blob / AWS S3
  Real-time: WebSocket (FastAPI native)
  Search: PostgreSQL Full-Text or Meilisearch

Mobile (apps/mobile_flutter/):
  Framework: Flutter 3.16+
  State: Riverpod
  Local DB: Drift (SQLite)
  API: Generated OpenAPI client
  Audio: just_audio + audio_service
```

### Architecture Principles

1. **Offline-First Mobile** — All content cached locally, sync on connectivity
2. **Optimistic Updates** — UI updates immediately, rollback on server error
3. **Server Components** — Use RSC for static content (navigation, layouts)
4. **Edge Functions** — Deploy API routes to edge where possible
5. **Type Safety** — End-to-end types from OpenAPI spec to frontend

---

## 📊 MODULE SPECIFICATIONS

### MODULE 1: DASHBOARD (Home Page)

**Location:** `apps/admin/app/(panel)/page.tsx`

**Requirements:**
```
┌─────────────────────────────────────────────────────────────────┐
│                        DASHBOARD LAYOUT                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Total    │  │ Published│  │ Active   │  │ Revenue  │        │
│  │ POIs     │  │ Tours    │  │ Users    │  │ This Mo  │        │
│  │ 1,234    │  │ 45       │  │ 12.5K    │  │ $4,320   │        │
│  │ +12%     │  │ +3       │  │ +8.2%    │  │ +15%     │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│                                                                  │
│  ┌────────────────────────────────┐  ┌─────────────────────────┐│
│  │   VISITOR ANALYTICS (7 days)   │  │   CONTENT STATUS        ││
│  │   ▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆ │  │   ● 45 Published        ││
│  │   Line chart with daily users  │  │   ● 12 Draft            ││
│  │   Peak times, geo distribution │  │   ● 3 Pending Review    ││
│  └────────────────────────────────┘  │   ● 2 Issues            ││
│                                      └─────────────────────────┘│
│  ┌────────────────────────────────┐  ┌─────────────────────────┐│
│  │   RECENT ACTIVITY FEED         │  │   QUICK ACTIONS         ││
│  │   • POI "Hermitage" updated    │  │   [+ New POI]           ││
│  │   • Tour "City Walk" published │  │   [+ New Tour]          ││
│  │   • Job #123 completed         │  │   [Run Validation]      ││
│  │   • 5 new QR scans today       │  │   [Generate Report]     ││
│  └────────────────────────────────┘  └─────────────────────────┘│
│                                                                  │
│  ┌──────────────────────────────────────────────────────────────┐│
│  │   GPS HEATMAP (SmartGuide-style)                             ││
│  │   Interactive map showing visitor concentration              ││
│  │   Zoom, filter by date, toggle layers                        ││
│  └──────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘

FEATURES:
✅ Real-time metrics cards with trend indicators
✅ Interactive visitor analytics chart (Recharts)
✅ Content status breakdown pie chart
✅ Activity feed with WebSocket updates (Polling implemented)
✅ Quick action buttons
✅ GPS heatmap integration (like SmartGuide)
□ Date range picker for all analytics
□ Export to PDF/Excel functionality
```

**Backend Endpoints Required:**
```python
GET /admin/dashboard/metrics
GET /admin/dashboard/analytics?range=7d&city=kaliningrad
GET /admin/dashboard/activity?limit=20
GET /admin/dashboard/heatmap?range=30d
```

---

### MODULE 2: POI MANAGEMENT (Points of Interest)

**Location:** `apps/admin/app/(panel)/content/pois/`

**List Page Features:**
```
✅ Data table with TanStack Table v8
✅ Columns: Checkbox, Title, City, Category, Status, Geo, Updated, Actions
✅ Global search with 300ms debounce
✅ Column filters (city, status, category)
✅ Column sorting (click headers)
✅ Bulk selection + bulk actions (publish, unpublish, delete)
✅ Pagination (20/50/100 per page)
✅ Row actions dropdown (Edit, View, Publish, Delete)
✅ Status badges with color coding
✅ Inline preview on hover (like izi.TRAVEL)
✅ Export selected/all to CSV
```

**Create/Edit Form Features (CRITICAL):**
```
TABS STRUCTURE:
├── Tab 1: "Basic Info"
│   ├── ✅ title_ru* (required, min 3 chars)
│   ├── ✅ title_en (optional)
│   ├── ✅ description_ru* (required, min 50 chars for publish)
│   ├── ✅ description_en
│   ├── ✅ city_slug* (dropdown from cities API)
│   ├── ✅ category* (museum, monument, park, church, etc.)
│   ├── ✅ address_ru (optional)
│   ├── ✅ opening_hours (JSON editor)
│   └── ✅ external_links[] (array of URLs)
│
├── Tab 2: "Location"
│   ├── ✅ lat, lon number inputs
│   ├── ✅ Interactive map with draggable marker
│   ├── ✅ "Find by address" button (geocoding)
│   ├── ✅ Radius setting for geofence trigger
│   └── ✅ Map preview with current position
│
├── Tab 3: "Media Gallery"
│   ├── ✅ Cover image upload (required for publish)
│   ├── ✅ Gallery images (drag & drop reorder)
│   ├── ✅ Audio files (narrations)
│   ├── Video embeds (YouTube, Vimeo)
│   ├── 360° photo support
│   ├── ✅ License modal on each upload
│   │   ├── license_type (CC-BY, CC-BY-SA, CC0, Proprietary)
│   │   ├── author name
│   │   └── source URL
│   └── Audio waveform preview (wavesurfer.js)
│
├── Tab 4: "Narrations"
│   ├── ✅ Full narration audio upload
│   ├── ✅ Preview audio (30 sec clip)
│   ├── ✅ Transcript text
│   ├── ✅ Auto TTS generation button (AI-powered)
│   ├── ✅ Multi-language narrations
│   └── ✅ Audio duration display
│
├── Tab 5: "Sources"
│   ├── ✅ Source list (name + URL)
│   ├── ✅ Inline add/edit/delete
│   ├── Minimum 1 source required for publish
│   └── ✅ Wikipedia auto-import button
│
└── Tab 6: "Publishing"
    ├── ✅ Publish checklist (live validation)
    │   ├── ✅ Title filled
    │   ├── ✅ Description > 50 chars
    │   ├── ❌ No cover image → [Upload]
    │   ├── ❌ No sources → [Add source]
    │   └── ⚠️ No narration (warning, not blocker)
    ├── ✅ Publish/Unpublish button
    ├── Schedule publish (future date)
    └── Version history

VALIDATION (Zod schema):
const poiSchema = z.object({
  title_ru: z.string().min(3, "Minimum 3 characters"),
  description_ru: z.string().optional(),
  city_slug: z.string().min(1, "Select a city"),
  category: z.string().min(1, "Select a category"),
  lat: z.number().min(-90).max(90).optional(),
  lon: z.number().min(-180).max(180).optional(),
  // ... other fields
});

AUTOSAVE:
□ Debounced autosave every 5 seconds on changes
□ "Unsaved changes" indicator
✅ Optimistic updates to cache
```

**Backend Endpoints:**
```python
# CRUD
GET    /admin/pois                              # List with pagination
POST   /admin/pois                              # Create
GET    /admin/pois/{id}                         # Get with sources, media
PATCH  /admin/pois/{id}                         # Update
DELETE /admin/pois/{id}                         # Soft delete

# Sub-resources
POST   /admin/pois/{id}/media                   # Add media
DELETE /admin/pois/{id}/media/{media_id}        # Delete media
PATCH  /admin/pois/{id}/media                   # Reorder media
POST   /admin/pois/{id}/sources                 # Add source
DELETE /admin/pois/{id}/sources/{source_id}     # Delete source
POST   /admin/pois/{id}/narrations              # Add narration

# Publishing
GET    /admin/pois/{id}/publish_check           # Validation report
POST   /admin/pois/{id}/publish                 # Publish
POST   /admin/pois/{id}/unpublish               # Unpublish
POST   /admin/pois/bulk-publish                 # Bulk publish
POST   /admin/pois/bulk-unpublish               # Bulk unpublish

# AI Features
POST   /admin/pois/{id}/generate-tts            # Generate TTS narration
POST   /admin/pois/{id}/import-wikipedia        # Import from Wikipedia
```

---

### MODULE 3: TOURS MANAGEMENT

**Location:** `apps/admin/app/(panel)/content/tours/`

**Tour Editor Features (Complex):**
```
TABS STRUCTURE:
├── Tab 1: "Overview"
│   ├── ✅ title_ru*, title_en
│   ├── ✅ description_ru*, description_en
│   ├── ✅ city_slug*
│   ├── ✅ cover_image
│   ├── ✅ tour_type (walking, driving, cycling, boat)
│   ├── ✅ difficulty (easy, moderate, hard)
│   ├── ✅ estimated_duration (auto-calculated from route)
│   └── distance_km (auto-calculated)
│
├── Tab 2: "Route Builder" (CRITICAL - like VoiceMap Mapmaker)
│   ├── LEFT PANEL: Drag & Drop POI List
│   │   ├── ✅ Search POIs to add
│   │   ├── ✅ Drag to reorder
│   │   ├── ✅ Delete from route
│   │   ├── ✅ Duration per stop
│   │   └── ✅ Transition text between stops
│   │
│   ├── RIGHT PANEL: Interactive Map
│   │   ├── ✅ Route visualization (polyline)
│   │   ├── ✅ Numbered markers for each stop
│   │   ├── ✅ Click marker to see POI preview
│   │   ├── Auto-routing between points (walking/driving)
│   │   └── Total distance/time display
│   │
│   └── BOTTOM PANEL: Timeline View
│       ├── Horizontal scroll of stops
│       ├── Duration breakdown
│       └── Gap warnings (too short/long)
│
├── Tab 3: "Media" (same as POI media)
│
├── Tab 4: "Sources" (same as POI sources)
│
├── Tab 5: "Monetization"
│   ├── Price settings (free, paid, freemium)
│   ├── Preview content selection
│   ├── Voucher codes management
│   └── Revenue tracking
│
└── Tab 6: "Publishing" (same structure as POI)

ROUTE BUILDER TECHNICAL REQUIREMENTS:
✅ Use @dnd-kit for drag & drop
✅ Use Mapbox/MapLibre (Leaflet used) for map
□ Use OSRM or Mapbox Directions API for routing
✅ Real-time route recalculation on reorder
□ Support adding "waypoints" (non-POI route points)
□ Export route as GPX file
□ Import route from GPX file
```

**Backend Endpoints:**
```python
# CRUD
GET    /admin/tours
POST   /admin/tours
GET    /admin/tours/{id}                        # Includes items, sources, media
PATCH  /admin/tours/{id}
DELETE /admin/tours/{id}

# Route Items
POST   /admin/tours/{id}/items                  # Add POI to route
DELETE /admin/tours/{id}/items/{item_id}
PATCH  /admin/tours/{id}/items                  # Reorder items (array of IDs)

# Route Utilities
POST   /admin/tours/{id}/calculate-route        # Get distance/duration
POST   /admin/tours/{id}/duplicate              # Clone tour
GET    /admin/tours/{id}/export-gpx             # Export as GPX

# Publishing
GET    /admin/tours/{id}/publish_check
POST   /admin/tours/{id}/publish
POST   /admin/tours/{id}/unpublish
```

---

### ✅ MODULE 4: ANALYTICS DASHBOARD (SmartGuide-style)

**Location:** `apps/admin/app/(panel)/analytics/`

**Pages Structure:**
```
/analytics
├── /overview          # Main analytics dashboard
├── /visitors          # Visitor demographics & behavior
├── /content           # Content performance
├── /heatmap           # GPS heatmap (like SmartGuide)
├── /revenue           # Revenue & monetization
└── /reports           # Custom reports builder
```

**Key Features:**
```
OVERVIEW PAGE:
✅ Total app installs (iOS + Android)
✅ Active users (DAU, WAU, MAU)
□ Tour completions
□ Average session duration
✅ Top content (most played POIs/tours)
□ User retention curve
□ Conversion funnel (install → register → purchase)

VISITORS PAGE:
□ Geographic distribution (world map)
□ Language preferences
□ Device breakdown (iOS vs Android)
□ Peak usage hours (heatmap by day/hour)
□ New vs returning users
□ User journey visualization

CONTENT PAGE:
□ POI rankings by plays
□ Tour rankings by completions
□ Audio completion rates
□ Skip points (where users stop listening)
□ Rating distribution
□ Content gaps analysis

GPS HEATMAP PAGE (CRITICAL - differentiator):
✅ Interactive map with visitor density overlay
✅ Filter by date range
□ Filter by tour/POI
□ Toggle between:
│   ├── Density heatmap
│   ├── Flow lines (movement patterns)
│   └── Dwell time (time spent at locations)
□ Export as image/PDF
□ Compare periods (this week vs last week)

REVENUE PAGE:
✅ Total revenue over time
□ Revenue by tour
□ Revenue by city
□ Average transaction value
□ Refund rate
□ Payment method breakdown
□ Forecast projections

REPORTS PAGE:
□ Custom report builder
□ Schedule automated reports
□ Export to PDF/Excel/CSV
□ Share reports via link
□ Report templates
```

**Backend Endpoints:**
```python
GET /admin/analytics/overview?range=30d
GET /admin/analytics/visitors?range=30d&city=all
GET /admin/analytics/content?range=30d&type=poi
GET /admin/analytics/heatmap?range=30d&bounds=lat1,lon1,lat2,lon2
GET /admin/analytics/revenue?range=30d
POST /admin/analytics/reports                   # Create report
GET /admin/analytics/reports/{id}               # Get report data
```

---

### MODULE 5: MEDIA LIBRARY

**Location:** `apps/admin/app/(panel)/media/`

**Features:**
```
✅ Central media management (all images, audio, video)
✅ Grid/List view toggle
✅ Filter by type (image, audio, video)
✅ Filter by entity (orphan, POI, Tour)
✅ Filter by license type
✅ Search by filename/alt text
□ Bulk upload with license assignment
□ Duplicate detection
□ Unused media cleanup
□ Storage usage analytics
✅ Presigned URL generation for direct upload
□ Image optimization pipeline (WebP conversion)
□ Audio transcoding (MP3, AAC, OGG)
□ Waveform preview for audio
✅ Preview modal with metadata (Overlay)
```

---

### MODULE 6: USER MANAGEMENT

**Location:** `apps/admin/app/(panel)/users/`

**Features:**
```
ADMIN USERS:
✅ List admins with role badges
□ Invite new admin (email invite)
✅ Role assignment:
│   ├── ✅ Super Admin (all access)
│   ├── ✅ Content Manager (POI/Tour CRUD)
│   ├── ✅ Analytics Viewer (read-only analytics)
│   └── ✅ Support (user management, no content)
□ Activity log per user
✅ Disable/enable accounts
□ 2FA enforcement settings

APP USERS (mobile app users):
✅ List registered users
□ Search by email/name
□ View user profile
│   ├── Purchase history
│   ├── Downloaded content
│   ├── Favorite POIs/Tours
│   └── Activity timeline
□ Grant/revoke entitlements manually
□ User support tools:
│   ├── Refund purchase
│   ├── Reset password
│   └── Delete account (GDPR)
```

---

### MODULE 7: QR CODE MANAGEMENT

**Location:** `apps/admin/app/(panel)/qr-codes/`

**Features:**
```
✅ QR code table with scan statistics
✅ Generate QR for any POI/Tour/City
✅ Bulk generate QR codes (all POIs in city)
✅ Custom code naming (e.g., "SPB001")
□ Download QR as SVG/PNG
□ Print sheets (multiple QRs per page)
✅ Scan analytics (when, where, device)
□ Deactivate/reactivate codes
□ Short link management (qr.audiogid.app/SPB001)
□ Dynamic QR (change target without new code)
□ QR tracking pixel for engagement
```

---

### MODULE 8: JOBS MONITORING

**Location:** `apps/admin/app/(panel)/jobs/`

**Features:**
```
✅ Real-time job list (WebSocket updates)
✅ Job types:
│   ├── ingestion (OSM import)
│   ├── ✅ tts_generation (AI narration)
│   ├── offline_bundle (ZIP generation)
│   ├── billing_restore (purchase verification)
│   ├── media_processing (image/audio conversion)
│   └── deletion (GDPR cleanup)
✅ Status indicators (pending, running, completed, failed)
✅ Progress bars for running jobs
✅ Detailed error messages on failure
✅ Retry failed jobs
✅ Cancel running jobs
□ Job queue visualization
□ Historical job browser
□ Alerts/notifications on failure
```

---

### MODULE 9: CITIES & REGIONS

**Location:** `apps/admin/app/(panel)/cities/`

**Features:**
```
✅ City list with stats (POI count, tour count)
✅ Create/edit city
│   ├── ✅ slug (unique identifier)
│   ├── ✅ name_ru, name_en
│   ├── ✅ description
│   ├── ✅ cover_image
│   ├── ✅ bounding_box (lat/lon bounds)
│   ├── ✅ default_zoom_level
│   └── ✅ timezone
□ City map preview
□ POI assignment (which POIs belong to city)
□ Featured content selection
□ City-specific settings
✅ Publish/unpublish city
```

---

### MODULE 10: SETTINGS & CONFIGURATION

**Location:** `apps/admin/app/(panel)/settings/`

**Pages:**
```
/settings
├── ✅ /general           # App name, logo, contact info
├── /localization      # Languages, default language
├── /integrations      # API keys, webhooks
├── /notifications     # Email templates, push settings
├── /billing           # Payment provider config
├── /ai                # TTS provider, translation settings
└── /backup            # Database backup/restore
```

---

### ✅ MODULE 11: CONTENT VALIDATION

**Location:** `apps/admin/app/(panel)/content/validation/`

**Features:**
```
✅ Global content health check
✅ Table of all validation issues:
│   ├── ✅ Entity (POI/Tour)
│   ├── ✅ Issue type (missing source, no media, etc.)
│   ├── ✅ Severity (blocker, warning, info)
│   ├── ✅ Message
│   └── ✅ Quick fix link
✅ Filter by severity
✅ Filter by entity type
□ Bulk fix suggestions
□ Schedule periodic validation
□ Validation history
```

---

## 🔗 MOBILE APP INTEGRATION

### Sync Architecture
```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Admin Panel    │ ──API── │  FastAPI        │ ──API── │  Flutter App    │
│  (Next.js)      │         │  Backend        │         │  (Mobile)       │
└─────────────────┘         └─────────────────┘         └─────────────────┘
                                   │
                                   │ WebSocket
                                   ▼
                            ┌─────────────────┐
                            │  Redis PubSub   │
                            │  (Real-time)    │
                            └─────────────────┘
```

### Sync Endpoints Required
```python
# Mobile sync endpoints
GET /public/cities                              # City catalog
GET /public/cities/{slug}                       # City detail
GET /public/cities/{slug}/pois                  # POIs for city
GET /public/cities/{slug}/tours                 # Tours for city
GET /public/pois/{id}                           # POI detail
GET /public/tours/{id}                          # Tour detail with items
GET /public/helpers                             # App configuration

# Offline bundle
POST /offline/bundles:build                     # Request bundle generation
GET /offline/bundles/{job_id}                   # Check status, get download URL

# Billing
✅ POST /billing/apple/verify                      # Verify iOS receipt
✅ POST /billing/google/verify                     # Verify Android purchase
✅ GET /billing/entitlements                       # User's unlocked content
✅ POST /billing/restore                           # Restore purchases

# User actions
POST /public/qr/{code}/scan                     # Record QR scan
POST /analytics/event                           # Track user event
```

### Real-time Sync Requirements
```
□ Content updates push to mobile (via Firebase/OneSignal)
✅ Entitlement changes sync immediately
✅ QR scan events visible in admin within 5 seconds (via WebSocket)
□ Analytics events batched and sent every 30 seconds
□ Offline queue persisted, processed on reconnect
```

---

## 🎨 UI/UX REQUIREMENTS

### Design System
```
COLOR PALETTE:
Primary: #3B82F6 (Blue)
Secondary: #10B981 (Green)
Warning: #F59E0B (Amber)
Error: #EF4444 (Red)
Background: #F8FAFC (Light) / #0F172A (Dark)

TYPOGRAPHY:
Font Family: Inter (Google Fonts)
Headers: 600-700 weight
Body: 400-500 weight

SPACING:
Base unit: 4px
Padding: 16px (cards), 24px (sections)
Margin: 24px between sections

SHADOWS:
Cards: shadow-sm
Modals: shadow-lg
Dropdowns: shadow-md

ANIMATION:
Transitions: 200ms ease
Skeleton loaders on data fetch
Smooth page transitions
Micro-interactions on buttons/inputs
```

### Responsive Requirements
```
□ Desktop-first design (primary use case)
□ Tablet support (iPad landscape/portrait)
□ Mobile support for emergency access
□ Minimum width: 320px
□ Maximum content width: 1440px
□ Sidebar collapsible on tablet/mobile
```

### Accessibility Requirements
```
□ WCAG 2.1 AA compliance
□ Keyboard navigation (all actions)
□ Screen reader compatibility
□ Color contrast ratios (4.5:1 minimum)
□ Focus indicators
□ Alt text for all images
□ ARIA labels where needed
□ Reduced motion support
```

### Dark Mode
```
□ System preference detection
□ Manual toggle in header
□ Persistent preference in localStorage
□ All components styled for both modes
□ Proper contrast in dark mode
```

---

## ⚡ PERFORMANCE REQUIREMENTS

### Frontend Metrics
```
□ Lighthouse Performance: 90+
□ First Contentful Paint: < 1.5s
□ Time to Interactive: < 3s
□ Bundle size: < 500KB (initial)
□ Code splitting by route
□ Image lazy loading
□ Virtual scrolling for long lists (1000+ items)
```

### Backend Metrics
```
□ API response time: < 200ms (p95)
□ Database queries: < 50ms (p95)
□ WebSocket latency: < 100ms
□ Job processing: < 30s for most jobs
□ Concurrent users: Support 100+ admins
```

### Caching Strategy
```
□ TanStack Query: staleTime 30s, cacheTime 5min
□ API: Redis cache for list endpoints
□ CDN: Static assets on Vercel Edge
□ Images: Vercel Image Optimization
□ Presigned URLs: 15 minute expiry
```

---

## 🔒 SECURITY REQUIREMENTS

### Authentication
```
□ JWT-based auth (access + refresh tokens)
□ Access token expiry: 15 minutes
□ Refresh token expiry: 7 days
□ Token rotation on refresh
□ Secure cookie storage (httpOnly, sameSite)
□ CSRF protection
□ Rate limiting (100 req/min per user)
```

### Authorization
```
□ Role-based access control (RBAC)
□ Permission checks on API endpoints
□ Frontend route guards
□ Sensitive actions require re-auth
□ Audit log for admin actions
```

### Data Protection
```
□ HTTPS everywhere
□ Input validation (Zod/Pydantic)
□ SQL injection prevention (parameterized queries)
□ XSS prevention (React auto-escaping)
□ CORS configuration (allowed origins only)
□ File upload validation (type, size, content)
□ GDPR compliance (data export, deletion)
```

---

## 🧪 TESTING REQUIREMENTS

### Test Coverage
```
□ Unit tests: 80%+ coverage
□ Integration tests: Critical paths
□ E2E tests: User flows (Playwright)
□ Visual regression: Storybook + Chromatic
□ API tests: All endpoints (pytest)
□ Load tests: 100 concurrent users
```

### CI/CD Pipeline
```
□ Lint on PR (ESLint, Prettier)
□ Type check on PR (tsc)
□ Unit tests on PR
□ E2E tests on merge to main
□ Preview deployments on PR
□ Auto-deploy to staging on main
□ Manual promote to production
```

---

## 📋 IMPLEMENTATION PHASES

### Phase 1: Foundation (Week 1-2)
```
☑ Audit existing codebase
☑ Fix all TypeScript errors
☑ Fix all broken routes/navigation
☑ Implement proper error boundaries
☑ Add loading states everywhere
☑ Set up TanStack Query provider
☑ Implement dark mode
☑ Set up i18n (Russian + English)
```

### Phase 2: Core CRUD (Week 3-4)
```
☑ Complete POI management
☑ Complete Tour management with Route Builder
☑ Complete Media Library
☑ Complete Sources management
☑ Implement Publish Gates
☑ Real-time validation
```

### Phase 3: Analytics & Monitoring (Week 5-6)
```
☑ Implement Dashboard
☑ GPS Heatmap integration
☑ Visitor analytics
☑ Content performance
☑ Jobs monitoring
☑ QR code management
```

### Phase 4: Advanced Features (Week 7-8)
```
☑ AI TTS generation
☑ Wikipedia import
☑ User management
☑ Settings pages
☑ Bulk operations
☑ Export/import functionality
```

### Phase 5: Mobile Integration (Week 9-10)
```
☑ Complete sync API
☑ Offline bundle generation
☑ Push notifications
☑ Real-time updates
☑ QR scanner integration
☑ Performance optimization
```

### Phase 6: Polish & Launch (Week 11-12)
```
☑ UI/UX refinement
☑ Performance optimization
☑ Security audit
☑ Documentation
☑ User training materials
□ Production deployment
```

---

## 📚 REFERENCE IMPLEMENTATIONS

When implementing features, refer to these industry examples:

| Feature | Reference Platform | Notes |
|---------|-------------------|-------|
| Route Builder | VoiceMap Mapmaker | GPS-triggered, drag & drop |
| GPS Heatmap | SmartGuide | Big data dashboard |
| Content CMS | izi.TRAVEL | Multi-project support |
| Analytics | STQRY | Comprehensive dashboards |
| QR Tracking | Nubart | Unique code statistics |
| Accessibility | Orpheo | WCAG compliance |
| Mobile Sync | SmartGuide | Offline-first |
| AI Features | Cortina | DeepL + TTS |

---

## ✅ QUALITY CHECKLIST

Before marking any feature as complete, verify:

```
□ No TypeScript errors
□ No console errors/warnings
□ Loading states implemented
□ Error handling implemented
□ Empty states designed
□ Mobile responsive
□ Dark mode works
□ Keyboard accessible
□ Form validation complete
□ Optimistic updates work
□ Cache invalidation correct
□ Unit tests written
□ E2E test for critical path
□ Documentation updated
```

---

## 🚀 SUCCESS METRICS

The admin panel is considered complete when:

1. **Zero Crashes** — 0 unhandled errors in production for 7 days
2. **Fast** — All pages load in < 2 seconds
3. **Complete** — All modules implemented and functional
4. **Synced** — Mobile app receives updates within 5 seconds
5. **Loved** — Admin team gives 4.5+ satisfaction rating

---

**Document Author:** Antigravity AI  
**Created:** 29 January 2026  
**Status:** Ready for Agent Execution  
**Priority:** HIGH — Execute all phases sequentially  
