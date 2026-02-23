import httpx
import uuid
import logging
import json
from ..config import config
from ..models import Narration, Poi
from sqlmodel import Session, select

logger = logging.getLogger(__name__)

# S3 client singleton
_s3_client = None

def get_s3_client():
    global _s3_client
    if _s3_client is None:
        if not config.S3_ENDPOINT_URL:
            return None
        try:
            import boto3
            _s3_client = boto3.client(
                's3',
                endpoint_url=config.S3_ENDPOINT_URL,
                aws_access_key_id=config.S3_ACCESS_KEY,
                aws_secret_access_key=config.S3_SECRET_KEY,
            )
        except ImportError:
            return None
    return _s3_client

async def generate_narration_for_poi(session: Session, poi_id: uuid.UUID):
    """
    Generates AI Audio for a POI and saves to S3-compatible storage.
    Current Provider: OpenAI TTS.
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
    
    # Check for existing narration to avoid duplicates (MVP: one per POI/locale)
    existing = session.exec(select(Narration).where(Narration.poi_id == poi_id, Narration.locale == "ru")).first()
    if existing:
        return {"status": "already_exists", "url": existing.url}

    # 1. Generate Audio (AI Provider)
    if not config.OPENAI_API_KEY:
        logger.warning(f"OPENAI_API_KEY missing - skipping TTS for POI {poi_id}")
        return {"error": "TTS_PROVIDER_UNAVAILABLE"}
        
    try:
        async with httpx.AsyncClient() as client:
            logger.info(f"Requesting OpenAI TTS for POI {poi_id}...")
            # https://platform.openai.com/docs/api-reference/audio/createSpeech
            response = await client.post(
                "https://api.openai.com/v1/audio/speech",
                headers={"Authorization": f"Bearer {config.OPENAI_API_KEY}"},
                json={
                    "model": "tts-1",
                    "input": text_to_read[:4000], # OpenAI limit
                    "voice": "alloy",
                    "response_format": "mp3"
                },
                timeout=60.0
            )
            response.raise_for_status()
            audio_content = response.content
            
            # 2. Upload to S3-compatible storage
            s3 = get_s3_client()
            if not s3:
                logger.error("S3 storage not configured")
                return {"error": "BLOB_STORAGE_UNAVAILABLE"}

            filename = f"narrations/{poi_id}.mp3"
            
            # Upload to S3
            s3.put_object(
                Bucket=config.S3_BUCKET_NAME,
                Key=filename,
                Body=audio_content,
                ContentType='audio/mpeg'
            )
            
            # Build public URL
            if config.S3_PUBLIC_URL:
                audio_url = f"{config.S3_PUBLIC_URL.rstrip('/')}/{filename}"
            else:
                audio_url = f"{config.S3_ENDPOINT_URL.rstrip('/')}/{config.S3_BUCKET_NAME}/{filename}"
            
            # 3. Save Record
            narration = Narration(
                poi_id=poi_id,
                url=audio_url,
                locale="ru",
                duration_seconds=0.0, # Meta could be parsed from response if available
                voice_id="openai/alloy"
            )
            session.add(narration)
            session.commit()
            
            logger.info(f"Narration generated and saved for POI {poi_id}: {audio_url}")
            return {"status": "success", "url": audio_url}
            
    except Exception as e:
        logger.exception(f"Narration generation failed for POI {poi_id}: {e}")
        return {"error": str(e)}
