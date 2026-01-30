
import requests
import os

API_URL = os.getenv("API_URL", "http://localhost:8000/v1")

def log(msg):
    print(f"[Monitoring] {msg}")

def check_health():
    try:
        res = requests.get(f"{API_URL}/ops/health")
        if res.status_code == 200:
            log(f"Health Check Passed: {res.json()}")
        else:
            log(f"Health Check Failed: {res.status_code}")
    except Exception as e:
        log(f"Health Check Error: {e}")

def check_diagnostics():
    try:
        res = requests.get(f"http://localhost:8000/api/diagnose-admin")
        log(f"Admin Diagnose: {res.status_code}")
    except Exception as e:
        log(f"Diagnose Error: {e}")

if __name__ == "__main__":
    log("Checking Monitoring Status...")
    check_health()
    check_diagnostics()
    
    # Sentry check is implicitly done if errors connect.
    # We can trigger a test error if we had a dedicated endpoint, but let's not break things.
    log("Monitoring Check Complete. Verify Sentry dashboard manually for error reports.")
