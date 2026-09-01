# Google Play — publish checklist

This repo can build a Play-shaped **Android App Bundle**. Creating the Play
Console app, closed testing, and production release still need a human with
a Google Play Developer account.

## Hard blockers (cannot be done from this agent VM)

1. **Play Developer account** — one-time registration + identity verification
   at [play.google.com/console](https://play.google.com/console).
2. **Create the app in Console** — the Publishing API cannot create a new
   listing; you create `com.eom.eom` once in the web UI.
3. **Upload keystore** — generate once, never commit:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   cp android/key.properties.example android/key.properties
   # fill passwords + storeFile=upload-keystore.jks
   ```
4. **Hosted privacy policy URL** — Play requires a public HTTPS page.
   `docs/privacy_policy.md` is the copy; publish it (GitHub Pages, your
   site, etc.) and paste the URL into Console → App content.
5. **Closed testing (personal accounts after 2023)** — before production,
   run a **closed test for 14 days with ≥12 opted-in testers**.
6. **Service account JSON** (optional, for CI upload) — Console → Users and
   permissions → API access → link a Cloud project → create a service
   account with *Release to production / testing* and save the JSON as
   `PLAY_SERVICE_ACCOUNT_JSON` (never commit it).

## Build a signed AAB

```bash
# after android/key.properties exists
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

Without `key.properties`, CI/local release builds still sign with the
**debug** key (sideload only — do not upload that AAB to Play).

## Attempt an API upload

```bash
export PLAY_SERVICE_ACCOUNT_JSON=/path/to/play-service-account.json
export PLAY_PACKAGE_NAME=com.eom.eom
export PLAY_AAB=build/app/outputs/bundle/release/app-release.aab
# optional: PLAY_TRACK=internal|alpha|beta|production  (default: internal)
python3 dev/play/upload_aab.py
```

## Store listing draft (paste into Console)

| Field | Copy |
| --- | --- |
| App name | EOM |
| Short description | A quiet vault for the mind — clarify, compress, map, reflect, and act on your thoughts. |
| Full description | See README “What EOM Helps You Do”. Lead with five intents; mention On this device / optional cloud Guides; no accounts, no ads, local history. |
| App icon | `android/play/icon-512.png` |
| Feature graphic | `android/play/feature-graphic.png` |
| Screenshots | Capture from a phone or emulator (Home empty, mid-session Clarify, Map, Settings). Play needs ≥2 phone screenshots. |
| Category | Productivity (or Lifestyle) |
| Contact email | Publisher email in Console |
| Privacy policy URL | Your hosted `docs/privacy_policy.md` |

## Data safety (suggested answers)

- **Collects / shares:** only when the user chooses a cloud Guide — text
  prompts go to that provider. On-device Guide: processed on device.
- **Ephemeral:** prompts are not stored by EOM servers (there are none).
- **Local storage:** thoughts, history, graph, API keys on device.
- **Encryption in transit:** HTTPS for cloud Guides.
- **Account creation:** no.
- **Ads / sale of data:** no.

## Target platform notes

- `minSdk` 26 (Android 8), `targetSdk` / `compileSdk` from Flutter (36 as of
  Flutter 3.47 — required for new Play apps after 2026-08-31).
- 16 KB page sizes: AGP 8.11 + `jniLibs.useLegacyPackaging = false`.
