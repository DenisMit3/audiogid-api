# AudioGuide Admin Panel User Guide

## Overview
Welcome to the AudioGuide Administration Panel. This tool allows you to manage content (POIs, Tours, Cities), view analytics, and configure system settings.

## Content Management

### Points of Interest (POIs)
- **Navigation:** Go to **Content > POIs**.
- **Creating:** Click "Add POI". Fill in title, description (mandatory for TTS), and location.
- **Editing:** Click on any POI title or the "Edit" action.
- **Publishing:** 
  - To publish, a POI must have a valid description (>10 chars) and coordinates.
  - Use the "Publish" button in the editor.
  - **Bulk Publishing:** Select multiple rows in the list view and click the "Publish" button in the bottom bar.
- **Deletion:** You can soft-delete POIs. Deleted items are hidden from the app but preserved in the database.
- **AI Features:**
  - **Wikipedia Import:** Within the editor, use the "Import from Wikipedia" tool to auto-fill details.
  - **TTS Generation:** Use the "Generate Audio" button to create neural voice narrations from the description.

### Tours
- **Navigation:** Go to **Content > Tours**.
- **Route Builder:** Drag and drop POIs to reorder them in the tour.
- **Validation:** Tours must have at least one valid POI to be published.

### Media Library
- **Navigation:** Go to **Media**.
- **Uploads:** You can view all uploaded assets here.
- **Management:** Delete unused assets or find where they are used.

## Analytics

### Dashboard
- **Overview:** Real-time view of DAU, Revenue, and Active Sessions.
- **Heatmap:** Visualization of where users are interacting with content physically.
- **Funnels:** Track user conversion from "App Open" to "Purchase".
- **Cohorts:** Analyze user retention over time.

## Settings

### Backups
- **Direct Export:** Go to **Settings > Backup** to download a full CSV dump of your POI database.
- **Recovery:** Managed via Neon Console (Postgres PITR).

### System Jobs
- **Monitoring:** Go to **Jobs** to see background tasks (TTS generation, Offline Bundles).
- **Status:** Green = Completed, Red = Failed. You can retry failed jobs.

## Troubleshooting
- **Validation Issues:** Go to **Validation Report** to see granular errors preventing publication.
- **Support:** Contact the technical team for API or infrastructure issues.
