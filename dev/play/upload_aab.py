#!/usr/bin/env python3
"""Upload a signed AAB to Google Play (internal track by default).

Requires:
  PLAY_SERVICE_ACCOUNT_JSON  path to Play Console API service-account JSON
  PLAY_AAB                   path to app-release.aab
  PLAY_PACKAGE_NAME          default com.eom.eom
  PLAY_TRACK                 default internal

Exits non-zero with a clear checklist when credentials are missing.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path


def die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def main() -> None:
    package = os.environ.get("PLAY_PACKAGE_NAME", "com.eom.eom")
    track = os.environ.get("PLAY_TRACK", "internal")
    sa = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "").strip()
    aab = os.environ.get("PLAY_AAB", "").strip()

    missing = []
    if not sa or not Path(sa).is_file():
        missing.append(
            "PLAY_SERVICE_ACCOUNT_JSON — path to a Play Console service-account JSON "
            "(Console → Users and permissions → API access)."
        )
    if not aab or not Path(aab).is_file():
        missing.append(
            "PLAY_AAB — path to a signed app-release.aab "
            "(flutter build appbundle --release with android/key.properties)."
        )

    if missing:
        die(
            "Cannot upload to Google Play from this environment.\n\n"
            "Missing:\n- "
            + "\n- ".join(missing)
            + "\n\nAlso required (human / Play Console):\n"
            "- Play Developer account + identity verification\n"
            "- App created in Console for package "
            + package
            + "\n"
            "- Hosted privacy policy URL\n"
            "- Phone screenshots (≥2)\n"
            "- Closed testing (≥12 testers / 14 days) before production on personal accounts\n"
            "\nSee docs/play_store.md.\n"
        )

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        die(
            "Missing Google API libraries. Install with:\n"
            "  pip install google-api-python-client google-auth\n"
        )

    scopes = ["https://www.googleapis.com/auth/androidpublisher"]
    creds = service_account.Credentials.from_service_account_file(sa, scopes=scopes)
    service = build("androidpublisher", "v3", credentials=creds, cache_discovery=False)

    print(f"Creating edit for {package}…")
    edit = service.edits().insert(body={}, packageName=package).execute()
    edit_id = edit["id"]
    print(f"Edit {edit_id}: uploading {aab}…")

    media = MediaFileUpload(aab, mimetype="application/octet-stream", resumable=True)
    bundle = (
        service.edits()
        .bundles()
        .upload(editId=edit_id, packageName=package, media_body=media)
        .execute()
    )
    version_code = bundle["versionCode"]
    print(f"Uploaded versionCode={version_code}")

    print(f"Assigning to track={track}…")
    service.edits().tracks().update(
        editId=edit_id,
        packageName=package,
        track=track,
        body={
            "track": track,
            "releases": [
                {
                    "name": f"{version_code}",
                    "status": "completed",
                    "versionCodes": [str(version_code)],
                }
            ],
        },
    ).execute()

    print("Committing edit…")
    commit = service.edits().commit(editId=edit_id, packageName=package).execute()
    print(json.dumps(commit, indent=2))
    print(f"Done. Package {package} → track {track}, versionCode {version_code}.")


if __name__ == "__main__":
    main()
