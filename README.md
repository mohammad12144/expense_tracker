# Expense Tracker

A small Flutter app for tracking personal expenses. Built as the Mini App v1
during the Grids Apps Training (Full Stack Mobile App Development, Flutter track).

## Features

- Splash, Login and Register screens with form validation
- Home dashboard: total and this-month summary cards
- Add expense form (title, amount, date picker, category) with validation
- Expense details screen
- Swipe to delete with Undo
- Local persistence with `shared_preferences` (expenses survive app restarts)
- Search by title, filter by category, list/grid toggle
- Loading and empty states
- Central app theme and reusable widgets
- Responsive layout (content is centered with a max width on wide windows)

> Login and Register are UI only for now. They use a simulated delay and no real backend.

## Getting started

```bash
flutter pub get
flutter run -d windows   # or any connected device / emulator
```

Analyze the code:

```bash
flutter analyze
```

## Project structure

```
lib/
  main.dart                 app entry, theme and routes
  models/
    expense.dart            Expense model (toJson / fromJson)
  screens/
    splash_screen.dart
    login_screen.dart
    register_screen.dart
    home_screen.dart
    add_expense_screen.dart
    expense_details_screen.dart
  services/
    expense_storage.dart    load/save expenses with shared_preferences
  utils/
    validators.dart         shared form validators
    formatters.dart         date and money formatting
    constants.dart          shared sizes
  widgets/
    app_logo.dart
    custom_text_field.dart
    loading_button.dart
    summary_card.dart
    expense_tile.dart       list tile and grid tile
    category_filter.dart
  exercises/
    day1.dart               Dart exercises (run with `dart run`)
```

## Known issues

- Login and Register do not talk to a backend yet (planned: REST API integration).
- Editing an existing expense is not implemented.
- Data is stored locally only and is not synced between devices.
- Resizing the window to an extremely narrow width (below roughly 72 px per tile)
  can trigger a ListTile layout exception on desktop.

## Roadmap

- REST API integration (loading / error states)
- Authentication with token handling
- State management (Riverpod or BLoC)
- Tests and release build