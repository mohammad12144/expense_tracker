# Security Checklist – Expense Tracker

## Secrets and configuration
- [x] No private keys, `.env`, keystores (`*.jks`) or service-account files are tracked in git (checked with `git ls-files`).
- [x] `.gitignore` blocks `.env`, `*.jks`, `*.keystore`, `key.properties` and service-account files.
- [x] `android/app/google-services.json`, `firebase_options.dart` and `firebase-messaging-sw.js` are tracked on purpose: they hold public client identifiers only. Data access is protected by Firestore Security Rules, not by hiding them.
- [x] The VAPID key (`kVapidKey`) is a public key by design.
- [ ] Restrict the Firebase API keys in Google Cloud Console (HTTP referrer for web, package name + SHA-1 for Android) before release.

## Authentication and authorization
- [x] Login and registration use Firebase Authentication. The app never stores passwords.
- [x] Firestore rules limit `users/{uid}/expenses/*` to the signed-in owner (`request.auth.uid == uid`).
- [ ] Add field validation to the rules (title is a string, amount is a number greater than 0, date is a timestamp).
- [ ] Enable Firebase App Check before production.

## Data storage
- [x] Firebase Auth manages its own session tokens inside the SDK.
- [x] Legacy API tokens (`TokenStorage`) moved from plain SharedPreferences to `flutter_secure_storage` (Keychain / encrypted Android storage).
- Note: on web, secure storage is browser-based and weaker than on mobile. Do not treat web storage as a vault.

## Network
- [x] No cleartext `http://` URLs in `lib/` (checked by search). Firebase traffic uses HTTPS.
- [ ] Production APIs must use HTTPS only.

## Input validation
- [x] Validators for name, email, password, password confirmation and amount, covered by unit tests.
- [x] Notification deep links are validated against an allowlist (`kAllowedDeepLinks`); unknown routes fall back to `/notification`.

## Logging and error handling
- [x] `debugPrint` calls only log status messages, never passwords or tokens.
- [x] Firebase auth errors are mapped to friendly messages (`authErrorMessage`).
- [ ] The FCM token is shown shortened in the Profile screen for testing only. Remove before release.
- [ ] `lib/exercises/day1.dart` uses `print` (training exercise). Not part of the app flow.

## Permissions
- [x] The notification permission is requested only on an explicit user action.
- [x] No camera or location permissions are requested.

## Dependencies
- [ ] Review `flutter pub outdated` before release. Several Firebase packages have newer major versions.

## Tests
- Unit tests: validators, formatters, `Expense` model (JSON round trip, icons, date label), expenses/filters providers, `PushMessage` deep-link validation, `TokenStorage`.
- Widget test: login form (rendering and validation errors).
- Run: `flutter test` (37 tests).
- Not covered yet: integration test for the full login flow, Firestore security rules tests.