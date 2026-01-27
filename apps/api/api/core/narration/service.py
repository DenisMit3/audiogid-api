import httpx
import uuid
import logging
from ..config import config
from ..models import Narration, Poi
from sqlmodel import Session, select
from .qwen import generate_audio_qwen

logger = logging.getLogger(__name__)

async def generate_narration_for_poi(session: Session, poi_id: uuid.UUID):
    """
    Generates AI Audio for a POI and saves to Vercel Blob.
    Provider determined by config.AUDIO_PROVIDER ('qwen' or 'openai').
    """
    poi = session.get(Poi, poi_id)
    if not poi:
        logger.error(f"POI {poi_id} not found")
        return {"error": "POI not found"}
    
    # We combine title and description for the narration
    text_to_read = f"{poi.title_ru}. {poi.description_ru or ''}"
    if not text_to_read.strip():
        logger.error(f"No text to generate narration for POI {poi_id}")
        return {"error": "Empty text"}
    
    # Check for existing narration to avoid duplicates (MVP)
    existing = session.exec(select(Narration).where(Narration.poi_id == poi_id, Narration.locale == "ru")).first()
    if existing:
        return {"status": "already_exists", "url": existing.url}

    # 1. Generate Audio (AI Provider)
    audio_content = None
    voice_id = "unknown"

    try:
        if config.AUDIO_PROVIDER == "qwen":
            logger.info(f"Generating audio via Qwen-TTS (Alibaba) for POI {poi_id}...")
            # Qwen adapter handles its own HTTP calls
            audio_content = await generate_audio_qwen(text_to_read[:4000])
            voice_id = "qwen/cosyvoice-v1"
            
        elif config.OPENAI_API_KEY:
            logger.info(f"Requesting OpenAI TTS for POI {poi_id}...")
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    "https://api.openai.com/v1/audio/speech",
                    headers={"Authorization": f"Bearer {config.OPENAI_API_KEY}"},
                    json={
                        "model": "tts-1",
                        "input": text_to_read[:4000],
                        "voice": "alloy",
                        "response_format": "mp3"
                    }
                )
                if response.status_code == 200:
                    audio_content = response.content
                    voice_id = "openai/alloy"
                else:
                    logger.error(f"OpenAI TTS failed: {response.text}")

        else:
             logger.error("No valid TTS configuration (Qwen or OpenAI)")
             return {"error": "TTS_PROVIDER_UNAVAILABLE"}

        if not audio_content:
            logger.error(f"TTS Generation failed for POI {poi_id} using {config.AUDIO_PROVIDER}")
            return {"error": "TTS_GENERATION_FAILED"}

        # 2. Upload to Vercel Blob
        if not config.VERCEL_BLOB_READ_WRITE_TOKEN:
              logger.error("VERCEL_BLOB_READ_WRITE_TOKEN missing")
              return {"error": "BLOB_STORAGE_UNAVAILABLE"}

        filename = f"narrations/{poi_id}.mp3"
        upload_url = f"https://blob.vercel-storage.com/{filename}"
        
        async with httpx.AsyncClient() as client:
            upload_resp = await client.put(
                upload_url,
                content=audio_content,
                headers={
                    "Authorization": f"Bearer {config.VERCEL_BLOB_READ_WRITE_TOKEN}",
                    "x-api-version": "1"
                }
            )
            upload_resp.raise_for_status()
            blob_data = upload_resp.json()
            audio_url = blob_data.get("url")
            
        # 3. Save Record
        narration = Narration(
            poi_id=poi_id,
            url=audio_url,
            locale="ru",
            duration_seconds=0.0, 
            voice_id=voice_id
        )
        session.add(narration)
        session.commit()
        
        logger.info(f"Narration generated ({voice_id}) and saved for POI {poi_id}: {audio_url}")
        return {"status": "success", "url": audio_url}

    except Exception as e:
        logger.exception(f"Narration process failed for POI {poi_id}: {e}")
        return {"error": str(e)}
