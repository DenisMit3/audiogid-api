import logging
import uuid
import json
import hashlib
import hmac
import time # Added for exp
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Body, Response, Request
from fastapi.responses import HTMLResponse
from sqlmodel import Session, select
from pydantic import BaseModel

from ..core.database import engine
from ..core.models import DeletionRequest, PurchaseIntent, Purchase, Entitlement, Job
from ..core.config import config
from ..core.worker import UPSTASH_CLIENT

logger = logging.getLogger(__name__)
router = APIRouter()

# Secret helper for tokens (In real app, load from env)
PROOF_SECRET = config.ADMIN_API_TOKEN or "change_me_in_prod_secret_key"
PROOF_TTL_SEC = 3600 # 1 Hour

def get_session():
    with Session(engine) as session:
        yield session

def generate_proof_token(subject_id: str) -> str:
    """Generates a signed token with Expiry."""
    ts = int(time.time())
    exp = ts + PROOF_TTL_SEC
    # Payload: subject_id|exp
    msg = f"{subject_id}|{exp}"
    sig = hmac.new(PROOF_SECRET.encode(), msg.encode(), hashlib.sha256).hexdigest()[:16]
    # Return format: sig.exp
    return f"{sig}.{exp}"

def verify_proof(subject_id: str, token: str) -> bool:
    try:
        if "." not in token: return False
        sig, exp_str = token.split(".", 1)
        exp = int(exp_str)
        
        # Check Expiry
        if time.time() > exp:
            return False
            
        # Verify Signature
        msg = f"{subject_id}|{exp}"
        expected_sig = hmac.new(PROOF_SECRET.encode(), msg.encode(), hashlib.sha256).hexdigest()[:16]
        return hmac.compare_digest(expected_sig, sig)
    except Exception:
        return False

# ... (Input Models Identical) ...
class DeletionTokenReq(BaseModel):
    subject_id: str

class DeletionReqBody(BaseModel):
    subject_id: str
    proof: str 
    idempotency_key: str
    request_channel: str = "IN_APP" 

# ... (Endpoints Updated with Expiry Logic implicitly via verify_proof) ...

@router.post("/public/account/delete/token")
def get_deletion_token(
    response: Response,
    req: DeletionTokenReq
):
    """
    Generates a generic short-lived proof token.
    """
    response.headers["Cache-Control"] = "no-store"
    token = generate_proof_token(req.subject_id)
    return {"deletion_token": token, "expires_in_seconds": PROOF_TTL_SEC}

@router.post("/public/account/delete/request", status_code=202)
def request_deletion(
    response: Response,
    req: DeletionReqBody,
    session: Session = Depends(get_session)
):
    response.headers["Cache-Control"] = "no-store"

    # 0. Security Proof (Updated with Exp check)
    if not verify_proof(req.subject_id, req.proof):
        logger.warning(f"Deletion failed: Invalid/Expired proof for ...{req.subject_id[-4:]}")
        raise HTTPException(status_code=403, detail="Invalid or Expired Deletion Token")

    # ... (Rest of logic identical to PR-10) ...
    existing = session.exec(select(DeletionRequest).where(DeletionRequest.idempotency_key == req.idempotency_key)).first()
    if existing: return {"id": str(existing.id), "status": existing.status}

    recent = session.exec(select(DeletionRequest).where(DeletionRequest.subject_id == req.subject_id, DeletionRequest.status == "PENDING")).all()
    if len(recent) > 0: return {"id": str(recent[0].id), "status": "PENDING (Existing)"}

    del_req = DeletionRequest(subject_id=req.subject_id, idempotency_key=req.idempotency_key, request_channel=req.request_channel, status="PENDING")
    session.add(del_req)
    session.commit()
    
    job_payload = json.dumps({"deletion_request_id": str(del_req.id), "subject_id": req.subject_id})
    job = Job(type="delete_user_data", payload=job_payload, status="PENDING", idempotency_key=f"del_job_{del_req.id}")
    session.add(job)
    session.commit()
    
    if UPSTASH_CLIENT:
        try:
            UPSTASH_CLIENT.publish_json(url=f"{config.API_BASE_URL}/v1/internal/jobs/callback", body={"job_id": str(job.id)})
        except Exception:
            pass

    return {"id": str(del_req.id), "status": "PENDING"}

@router.get("/public/account/delete/status")
def get_deletion_status(
    response: Response,
    deletion_request_id: uuid.UUID,
    session: Session = Depends(get_session)
):
    response.headers["Cache-Control"] = "no-store"
    req = session.get(DeletionRequest, deletion_request_id)
    if not req: raise HTTPException(status_code=404, detail="Request not found")
    return {"id": str(req.id), "status": req.status, "completed_at": req.completed_at}

# ... (Web Form Identical) ...
@router.get("/delete", response_class=HTMLResponse)
def web_deletion_form(response: Response):
    response.headers["Cache-Control"] = "no-store"
    return """
    <html>
        <head><title>Delete Account</title><meta name="robots" content="noindex"></head>
        <body style="font-family: sans-serif; max-width: 600px; margin: 2rem auto; padding: 1rem;">
            <h1>Удаление данных / Data Deletion</h1>
            <div style="background: #fff3cd; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                <strong>Requirement:</strong> Valid Deletion Token (expires in 1 hour).
                <br>Go to <em>Settings > About > Delete Data</em> in the App.
            </div>
            <form action="/api/v1/delete/request/web" method="post">
                <label>User ID:</label><input type="text" name="subject_id" required style="width: 100%; margin-bottom: 10px;">
                <label>Token:</label><input type="password" name="proof" required style="width: 100%; margin-bottom: 10px;">
                <button type="submit" style="background: #d9534f; color: white; border: none; padding: 10px;">Delete</button>
            </form>
        </body>
    </html>
    """

@router.post("/delete/request/web", response_class=HTMLResponse)
async def web_deletion_submit(request: Request, response: Response, session: Session = Depends(get_session)):
    response.headers["Cache-Control"] = "no-store"
    form = await request.form()
    subject_id = form.get("subject_id")
    proof = form.get("proof")
    if not subject_id or not proof: return "Error: Missing Data"
    body = DeletionReqBody(subject_id=subject_id, proof=proof, idempotency_key=f"web_del_{subject_id}_{datetime.utcnow().timestamp()}", request_channel="WEB")
    try:
        res = request_deletion(response, body, session)
        return f"<html><body><h1 style='color:green'>Status: {res['status']}</h1></body></html>"
    except HTTPException as e:
        return f"<html><body><h1 style='color:red'>Error: {e.detail}</h1></body></html>"
