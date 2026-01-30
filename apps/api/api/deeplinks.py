from fastapi import APIRouter, Response
import os

router = APIRouter()

APPLE_APP_ID = os.getenv("APPLE_APP_ID", "TEAM_ID.app.audiogid.mobileFlutter")
ANDROID_PACKAGE_NAME = os.getenv("ANDROID_PACKAGE_NAME", "app.audiogid.mobile_flutter")
ANDROID_SHA256_FINGERPRINTS = os.getenv("ANDROID_SHA256_FINGERPRINTS", "YOUR_SHA256_FINGERPRINT").split(",")

@router.get("/.well-known/apple-app-site-association")
def apple_app_site_association(response: Response):
    response.headers["Content-Type"] = "application/json"
    return {
        "applinks": {
            "apps": [],
            "details": [
                {
                    "appID": APPLE_APP_ID,
                    "paths": ["/dl/*"]
                }
            ]
        }
    }

@router.get("/.well-known/assetlinks.json")
def assetlinks_json(response: Response):
    response.headers["Content-Type"] = "application/json"
    return [{
        "relation": ["delegate_permission/common.handle_all_urls"],
        "target": {
            "namespace": "android_app",
            "package_name": ANDROID_PACKAGE_NAME,
            "sha256_cert_fingerprints": [f.strip() for f in ANDROID_SHA256_FINGERPRINTS]
        }
    }]
