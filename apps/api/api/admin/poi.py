from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlmodel import Session, select
from pydantic import BaseModel
from geoalchemy2.elements import WKTElement
import uuid
# import vercel_blob

# ... (omitted)

# @router.post("/admin/pois/{poi_id}/media_upload")
# async def upload_poi_media(
#     poi_id: uuid.UUID,
#     file: UploadFile = File(...),
#     media_type: str = Query("image"), # image or audio
#     session: Session = Depends(get_session),
#     admin = Depends(get_current_admin)
# ):
#     # Check POI
#     poi = session.get(Poi, poi_id)
#     if not poi: raise HTTPException(404, "POI not found")
# 
#     # Upload to Vercel Blob
#     if not config.VERCEL_BLOB_READ_WRITE_TOKEN:
#         raise HTTPException(500, "Blob storage not configured")
#         
#     # filename = f"poi/{poi_id}/{media_type}/{file.filename}"
#     
#     # try:
#     #     # put returns { url, ... }
#     #     # file.file is SpooledTemporaryFile
#     #     blob = vercel_blob.put(filename, file.file, options={'access': 'public', 'token': config.VERCEL_BLOB_READ_WRITE_TOKEN})
#     # except Exception as e:
#     #      raise HTTPException(500, f"Upload failed: {e}")
#     
#     # media_entry = {
#     #      "url": blob['url'],
#     #      "media_type": media_type,
#     #      "license_type": "own",
#     #      "author": "admin", 
#     #      "source_page_url": ""
#     # }
#     
#     # # Update JSONB
#     # # Create new list to force update
#     # current_media = list(poi.media) if poi.media else []
#     # current_media.append(media_entry)
#     # poi.media = current_media
#     
#     # session.add(poi)
#     # session.commit()
#     
#     # return {"status": "uploaded", "url": blob['url'], "media": media_entry}
#     return {"status": "disabled", "detail": "blob upload temporarily disabled"}
