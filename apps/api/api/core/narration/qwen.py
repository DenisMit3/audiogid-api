import httpx
import logging
import json
from ..config import config

logger = logging.getLogger("api.narration.qwen")

async def generate_audio_qwen(text: str) -> bytes | None:
    """
    Generates audio using Alibaba Cloud Qwen-TTS (Model Studio).
    Uses 'cosyvoice-v1' model which supports high-quality multilingual synthesis.
    
    Ref: https://www.alibabacloud.com/help/en/model-studio/developer-reference/cosyvoice-api-reference
    
    Note: Returns MP3 bytes.
    """
    if not config.ALIBABA_API_KEY:
        logger.error("ALIBABA_API_KEY missing - skipping Qwen TTS")
        return None

    # Standard DashScope Synthesis Endpoint (Configurable for Region: Intl vs CN)
    url = config.ALIBABA_API_URL
    
    headers = {
        "Authorization": f"Bearer {config.ALIBABA_API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Payload for CosyVoice
    # Note: If 'qwen-tts-realtime' was requested, it usually implies WebSocket.
    # We use REST API here for Vercel compatibility.
    payload = {
        "model": "cosyvoice-v1",
        "input": {
            "text": text
        },
        "parameters": {
            "text_type": "PlainText",
            "format": "mp3",
            # Optional: Specify voice trigger or style if needed.
            # "voice": "..." 
        }
    }

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(url, json=payload, headers=headers)
            
            if resp.status_code != 200:
                logger.error(f"Qwen TTS Error ({resp.status_code}): {resp.text}")
                return None
                
            data = resp.json()
            
            # Helper to debug response structure
            if "output" not in data:
                 logger.error(f"Qwen TTS Unexpected format: {data}")
                 return None

            # DashScope usually returns a URL to the generated audio file
            if "url" in data["output"]:
                audio_url = data["output"]["url"]
                # Must download it immediately
                file_resp = await client.get(audio_url)
                if file_resp.status_code == 200:
                    return file_resp.content
                else:
                    logger.error(f"Failed to download audio from {audio_url}")
                    return None
            
            logger.error(f"No audio URL in Qwen response: {data}")
            return None

    except Exception as e:
        logger.error(f"Qwen TTS Exception: {e}")
        return None
