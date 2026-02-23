import httpx
import logging
import json
from sqlmodel import Session
from ..config import config
from ..models import Poi

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

async def generate_preview_content(session: Session, poi_id: str):
    """
    Generates preview bullets (LLM) and preview audio (TTS).
    """
    poi = session.get(Poi, poi_id)
    if not poi:
        return {"error": "POI not found"}
        
    if not config.OPENAI_API_KEY:
        return {"error": "OPENAI_API_KEY missing"}
        
    # 1. Generate Bullets
    text_source = f"{poi.title_ru}\n{poi.description_ru or ''}"
    
    bullets = []
    # If bullets exist, skip generation (or force force?)
    if not poi.preview_bullets or len(poi.preview_bullets) == 0:
        bullets = await _generate_bullets_llm(text_source)
        poi.preview_bullets = bullets
        session.add(poi)
        session.commit()
    else:
        bullets = poi.preview_bullets

    if not bullets:
        return {"error": "Failed to generate bullets"}
    
    # 2. Generate Audio
    # Read the bullets as a short script
    script = f"{poi.title_ru}. Интересные факты. " + " ".join(bullets)
    
    audio_url = await _generate_audio_tts(script, f"previews/{poi_id}.mp3")
    if audio_url:
        poi.preview_audio_url = audio_url
        session.add(poi)
        session.commit()
        return {"status": "success", "bullets": bullets, "audio": audio_url}
    
    return {"status": "partial_success", "bullets": bullets, "audio": None}

async def _generate_bullets_llm(text_input: str) -> list[str]:
    prompt = f"""
    Проанализируй текст о достопримечательности и выдели 3 самых интересных факта.
    Формат: JSON массив строк. Длина каждого факта: одно короткое предложение (до 10 слов).
    Текст: {text_input[:2000]}
    """
    
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={"Authorization": f"Bearer {config.OPENAI_API_KEY}"},
                json={
                    "model": "gpt-4o-mini",
                    "messages": [{"role": "user", "content": prompt}],
                    "response_format": {"type": "json_object"}
                },
                timeout=20.0
            )
            resp.raise_for_status()
            data = resp.json()
            content = data["choices"][0]["message"]["content"]
            parsed = json.loads(content)
            # Try to find list under 'facts' or just list
            if isinstance(parsed, list): return parsed[:3]
            if "facts" in parsed and isinstance(parsed["facts"], list): return parsed["facts"][:3]
            if "items" in parsed and isinstance(parsed["items"], list): return parsed["items"][:3]
            return []
    except Exception as e:
        logger.error(f"LLM Bullet Gen Failed: {e}")
        return []

async def _generate_audio_tts(text_input: str, filename: str) -> str | None:
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.openai.com/v1/audio/speech",
                headers={"Authorization": f"Bearer {config.OPENAI_API_KEY}"},
                json={
                    "model": "tts-1",
                    "input": text_input[:500],
                    "voice": "nova", # Energetic voice for previews
                    "response_format": "mp3"
                },
                timeout=60.0
            )
            response.raise_for_status()
            audio_content = response.content
            
            # Upload to S3-compatible storage
            s3 = get_s3_client()
            if not s3:
                return None

            s3.put_object(
                Bucket=config.S3_BUCKET_NAME,
                Key=filename,
                Body=audio_content,
                ContentType='audio/mpeg'
            )
            
            # Build public URL
            if config.S3_PUBLIC_URL:
                return f"{config.S3_PUBLIC_URL.rstrip('/')}/{filename}"
            else:
                return f"{config.S3_ENDPOINT_URL.rstrip('/')}/{config.S3_BUCKET_NAME}/{filename}"
            
    except Exception as e:
        logger.error(f"TTS Failed: {e}")
        return None
