# Technical Summary

## Architecture
Feature-first clean architecture: `features/{auth,expenses,notifications}` each split into
`data` (Firebase access), `domain` (models) and `presentation` (providers + screens), plus a `core/`
folder for shared widgets, validators, formatters and config. Dependencies point inward:
screens read providers, providers use repositories, repositories talk to Firebase.

## State management (Riverpod 3)
- `StreamProvider` for live Firestore data (expenses, auth state, sync state).
- `Notifier` / `NotifierProvider` for UI state (category filter, search query, visible item count).
- Derived providers compute filtered lists, totals and the paged list, so widgets only rebuild
  when the data they show changes.
- Paging resets via `ref.listen` on the filter and search providers.

## Data and offline
- Firestore documents live under `users/{uid}/expenses/{id}`, so each user only reads their own data.
- Offline persistence is enabled with a 100 MB cache. `snapshots(includeMetadataChanges: true)`
  exposes `isFromCache` and `hasPendingWrites`, which feed `SyncState` and the sync banner.

## Performance
- Small `ConsumerWidget`s isolate rebuilds (summary, filter bar, list).
- `ValueKey` on list items; paging at 20 items with "Load more".
- Paging is client-side, because totals require the full list.

## Security
- Tokens in `flutter_secure_storage`, not plain preferences.
- Secrets (`key.properties`, keystores, `.env`) are git-ignored.
- `google-services.json` is tracked on purpose: it is public client config.
- Push deep links go through an allowlist (`/notification` only).
- See SECURITY.md for the open items.

## Testing
Unit tests (validators, formatters, models, config, sync state), provider tests (paging) and a
widget test (login screen). `flutter analyze` and `flutter test` run in CI on every pull request.

## Build and CI/CD
Android flavors `dev` and `prod`, selected with `--flavor` and `--dart-define=ENV=...`.
Release signing is read from `android/key.properties`, falling back to debug signing when absent.
GitHub Actions runs a test job, then builds the Android APK and uploads it as an artifact.

## Trade-offs and next steps
- Make applicationId unique per flavor and register each in Firebase.
- Add Firestore rules with field validation, plus App Check and API key restrictions.
- Move paging to the server (and compute totals with aggregation queries).
- Add iOS build and signing, and a Windows/desktop target once the toolchain is fixed.
- Replace the remaining legacy `lib/services/*` code with feature-based repositories.