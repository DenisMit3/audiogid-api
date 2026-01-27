# ADR-005: Use Alibaba Qwen-TTS for Narration

## Status
Accepted

## Context
We need high-quality Russian speech synthesis for generating audio guides from text descriptions managed in the Admin Panel. The previous default was OpenAI TTS.

## Decision
We will use **Alibaba Cloud Model Studio (Qwen-TTS)** as the mandatory provider for audio narration.

Model details:
- **Reference**: https://www.alibabacloud.com/help/en/model-studio/qwen-tts-realtime
- **Target Language**: Russian.

## Technical Implementation Workflow
To comply with the **Offline-First** and **Vercel Serverless** architecture, the implementation must follow this strict flow:

1.  **Trigger**: Content update in Admin Panel -> Enqueues an Async Job via QStash.
2.  **Processing (Worker)**:
    -   The worker receives the text payload.
    -   Calls Alibaba Qwen-TTS API.
    -   **Constraint**: Must utilize a non-streaming (batch) endpoint if available, or robustly handle stream-to-buffer within the 10-60s Vercel execution window.
3.  **Storage (Critical)**:
    -   The generated audio binary MUST be uploaded to **Vercel Blob**.
    -   It MUST NOT be stored in the Postgres database (BLOBs in DB are forbidden).
    -   Only the public/protected **URL** is saved to the `access_url` or `media_url` field in Postgres.
4.  **Consumption**: The mobile app downloads the file from the URL for offline playback.

## Consequences
-   **Integration**: We need to implement a client for Alibaba Cloud Model Studio in `apps/api`.
-   **Configuration**: Requires Alibaba Cloud credentials (`ALIBABA_API_KEY`, etc.) added to Vercel Env Vars.
-   **Fail-Fast**: If Alibaba API provides `Realtime` (WebSocket) access only, we must implement a buffer mechanism to capture the stream into a file artifact before invalidating the Lambda execution context.
