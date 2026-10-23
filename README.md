# Expense Tracker

A Flutter expense tracker built with Firebase (Auth + Cloud Firestore), Riverpod and Material 3.
Built as part of the Grids Apps Full Stack Mobile App Development training (Flutter track, Days 1-15).

## Features

- Register / login with Firebase Auth (token kept in secure storage)
- Add, view and delete expenses, stored per user in Firestore (`users/{uid}/expenses/{id}`)
- Search and category filter (Food, Transport, Bills, Shopping, Other)
- Summary cards: total and this-month spending
- Offline support: cached data stays available, with a sync banner ("Offline - showing saved data")
- Client-side paging (20 items per page with a "Load more" button)
- Push notifications (FCM web push) with a deep-link allowlist
- Dev / prod Android flavors with an `ENV` config

## Screenshots

| Home | Offline | Push |
|------|---------|------|
| ![Home](docs/screenshots/home.png) | ![Offline](docs/screenshots/offline.png) | ![Push](docs/screenshots/push.png) |

## Tech stack

Flutter (Material 3), Riverpod 3, Firebase Auth, Cloud Firestore, Firebase Cloud Messaging,
flutter_secure_storage, GitHub Actions.

## Project structure

```
lib/
  core/            shared screens, widgets, utils, config (AppConfig)
  features/
    auth/          domain / presentation (providers, screens)
    expenses/      data (repository) / domain / presentation (providers, screens, widgets)
    notifications/ data (NotificationService) / presentation
  services/        legacy services (token storage, API client)
test/              unit, provider and widget tests
```

Each feature is split into `data`, `domain` and `presentation`. Providers expose state to the UI;
the repository is the only class that talks to Firestore.

## Getting started

Requirements: Flutter SDK, a Firebase project (Auth + Firestore enabled).

```
flutter pub get
flutter run -d chrome
```

If Chrome fails to launch, use:

```
flutter run -d web-server --web-port 5000
```

Notes:
- Firebase config lives in `lib/firebase_options.dart` and `android/app/google-services.json`
  (public client config, not a secret).
- Web push needs the VAPID key in `lib/features/notifications/data/notification_service.dart`.

## Tests

```
flutter analyze
flutter test
```

## Build and release (Android)

```
flutter build apk --release --flavor prod --dart-define=ENV=prod
```

Release signing uses `android/key.properties` (never committed). See [RELEASE.md](RELEASE.md).
CI (`.github/workflows/ci.yml`) runs analyze, tests and an Android build on every pull request.

## Security

See [SECURITY.md](SECURITY.md) for the checklist (secure token storage, key restrictions, Firestore rules).

## Known limitations

- Tested mainly on web (Chrome); the Windows desktop build is blocked by a local C++ toolchain issue.
- Both Android flavors share one applicationId (Firebase is registered for one package).
- iOS is not covered.
- Paging is client-side because totals need the full list.

More details: [docs/TECHNICAL_SUMMARY.md](docs/TECHNICAL_SUMMARY.md)