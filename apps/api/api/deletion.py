import logging
import uuid
import json
import hashlib
import hmac
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

def get_session():
    with Session(engine) as session:
        yield session

def generate_proof_token(subject_id: str) -> str:
    """Generates a signed token for the subject_id."""
    msg = f"{subject_id}:deletion-proof"
    return hmac.new(PROOF_SECRET.encode(), msg.encode(), hashlib.sha256).hexdigest()[:16]

def verify_proof(subject_id: str, proof: str) -> bool:
    expected = generate_proof_token(subject_id)
    return hmac.compare_digest(expected, proof)

# --- Input Models ---
class DeletionTokenReq(BaseModel):
    subject_id: str # Device/Account ID

class DeletionReqBody(BaseModel):
    subject_id: str
    proof: str # Token
    idempotency_key: str
    request_channel: str = "IN_APP" 

# --- Endpoints ---

@router.post("/public/account/delete/token")
def get_deletion_token(
    response: Response,
    req: DeletionTokenReq,
    # In a real app, we'd verify 'req' comes from a trusted app session (auth header).
    # For this offline-first MVP, we assume the ability to call this API with the correct ID implies possession/app-context.
):
    """
    Generates a proof token for deletion.
    User copies this to Web Form or App uses it internally.
    """
    response.headers["Cache-Control"] = "no-store"
    token = generate_proof_token(req.subject_id)
    return {"deletion_token": token}

@router.post("/public/account/delete/request", status_code=202)
def request_deletion(
    response: Response,
    req: DeletionReqBody,
    session: Session = Depends(get_session)
):
    """
    Initiates account/data deletion.
    Requires 'proof' (deletion_token).
    """
    response.headers["Cache-Control"] = "no-store"

    # 0. Security Proof
    if not verify_proof(req.subject_id, req.proof):
        # Log incident (redacted)
        logger.warning(f"Deletion failed: Invalid proof for subject ending in ...{req.subject_id[-4:]}")
        raise HTTPException(status_code=403, detail="Invalid Deletion Token/Proof")

    # 1. Idempotency Check
    existing = session.exec(select(DeletionRequest).where(DeletionRequest.idempotency_key == req.idempotency_key)).first()
    if existing:
        return {"id": str(existing.id), "status": existing.status}

    # 2. Limit Check
    recent = session.exec(select(DeletionRequest).where(
        DeletionRequest.subject_id == req.subject_id,
        DeletionRequest.status == "PENDING"
    )).all()
    if len(recent) > 0:
        return {"id": str(recent[0].id), "status": "PENDING (Existing)"}

    # 3. Create Request
    del_req = DeletionRequest(
        subject_id=req.subject_id,
        idempotency_key=req.idempotency_key,
        request_channel=req.request_channel,
        status="PENDING"
    )
    session.add(del_req)
    session.commit()
    
    # 4. Enqueue Async Job
    job_payload = json.dumps({
        "deletion_request_id": str(del_req.id),
        "subject_id": req.subject_id
    })
    
    job = Job(
        type="delete_user_data",
        payload=job_payload,
        status="PENDING",
        idempotency_key=f"del_job_{del_req.id}"
    )
    session.add(job)
    session.commit()
    
    if UPSTASH_CLIENT:
        try:
            UPSTASH_CLIENT.publish_json(
                url=f"{config.API_BASE_URL}/v1/internal/jobs/callback",
                body={"job_id": str(job.id)}
            )
        except Exception as e:
            logger.error(f"Failed to enqueue deletion job: {e}")

    return {"id": str(del_req.id), "status": "PENDING"}

@router.get("/public/account/delete/status")
def get_deletion_status(
    response: Response,
    deletion_request_id: uuid.UUID,
    session: Session = Depends(get_session)
):
    response.headers["Cache-Control"] = "no-store"
    req = session.get(DeletionRequest, deletion_request_id)
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")
    # Redact logs in public response? The log_json might contain counts.
    return {"id": str(req.id), "status": req.status, "completed_at": req.completed_at}

# --- Web Interface (Simple HTML) ---

@router.get("/delete", response_class=HTMLResponse)
def web_deletion_form(response: Response):
    response.headers["Cache-Control"] = "no-store"
    return """
    <html>
        <head>
            <title>Удаление аккаунта / Delete Account</title>
            <meta name="robots" content="noindex">
        </head>
        <body style="font-family: sans-serif; max-width: 600px; margin: 2rem auto; padding: 1rem;">
            <h1>Удаление данных / Data Deletion</h1>
            
            <div style="background: #fff3cd; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                <strong>Requirement:</strong> You need your <code>Deletion Token</code> from the App.
                <br>Go to <em>Settings > About > Delete Data</em> to view it.
            </div>

            <form action="/api/v1/delete/request/web" method="post">
                <label>User ID (Device ID):</label>
                <input type="text" name="subject_id" required style="width: 100%; padding: 8px; margin-bottom: 10px;" placeholder="e.g. 550e84...">
                
                <label>Deletion Token:</label>
                <input type="password" name="proof" required style="width: 100%; padding: 8px; margin-bottom: 10px;" placeholder="Get this from the App">
                
                <button type="submit" style="padding: 10px 20px; background: #d9534f; color: white; border: none; cursor: pointer;">Delete My Data</button>
            </form>
            
            <p style="color: gray; font-size: 0.9em; margin-top: 20px;">
                If you have already uninstalled the app and did not save your Deletion Token, your anonymous data is already orphaned and effectively inaccessible.
            </p>
        </body>
    </html>
    """

@router.post("/delete/request/web", response_class=HTMLResponse)
async def web_deletion_submit(
    request: Request,
    response: Response,
    session: Session = Depends(get_session)
):
    response.headers["Cache-Control"] = "no-store"
    form = await request.form()
    subject_id = form.get("subject_id")
    proof = form.get("proof")
    
    if not subject_id or not proof:
        return "Error: Missing ID or Token"
        
    body = DeletionReqBody(
        subject_id=subject_id, 
        proof=proof,
        idempotency_key=f"web_del_{subject_id}_{datetime.utcnow().timestamp()}",
        request_channel="WEB"
    )
    
    try:
        res = request_deletion(response, body, session)
        return f"""
        <html><body>
            <h1>Request Received</h1>
            <p style="color: green">Status: {res['status']}</p>
            <p>Request ID: {res['id']}</p>
            <p><a href="/api/v1/public/account/delete/status?deletion_request_id={res['id']}">Check Status</a></p>
        </body></html>
        """
    except HTTPException as e:
        return f"<html><body><h1 style='color:red'>Error: {e.detail}</h1></body></html>"
