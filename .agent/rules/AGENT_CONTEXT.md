---
trigger: always_on
---

# AGENT_CONTEXT

## PROJECT OVERVIEW

- **Project Name:** HypeGrid
- **Repository:** hype_grid
- **Purpose:** A "Mind Refresh" app that shows a curated, high-hype list of Football, F1, and MotoGP events for the next 7 days, localized for broadcasting in Indonesia (WIB).
- **Core Functionality:** Grid-based visualization of sports events, hype-score calculation, and local broadcast localization.
- **Architecture:** Flutter application using BLoC for state management, powered by a Python backend for data synchronization and Supabase for persistence.

---

## TECH STACK

| Layer              | Technology                                              |
|--------------------|--------------------------------------------------------|
| **Framework**      | Flutter                                                |
| **Language**       | Dart, Python (Sync Script)                             |
| **State Management**| flutter_bloc                                           |
| **Database**       | Supabase (PostgreSQL)                                  |
| **Automation**     | GitHub Actions                                         |
| **Styling**        | Custom `AppTheme` with Google Fonts (Outfit & Inter)   |
| **Icons**          | Material Icons, Cupertino Icons                        |

---

## PROJECT STRUCTURE

### `/lib/pages/` — Screens & Modules
Organized by feature name.
- `/home/` — The main grid showcase module.
    - `/bloc/` — BLoC logic for the home screen.
    - `/widget/` — Home-specific UI components.
- `/splash/` — Initial loading and branding screen.

### `/lib/widget/` — Reusable UI Components
Common widgets used across multiple features.

### `/lib/bloc/` — Global Logic
Generic BLoCs that manage global app state.

### `/lib/utils/` — Resources & Utilities
- `app_colors.dart` — Design tokens (colors).
- `app_theme.dart` — Global theme configuration.

---

## COMMON TASK LOCATIONS

| Task                      | Location                                                  |
|---------------------------|-----------------------------------------------------------|
| Main App Entry            | `lib/main.dart`                                           |
| Theme/Color Edits         | `lib/utils/app_theme.dart`, `lib/utils/app_colors.dart`   |
| Home Logic & State        | `lib/pages/home/bloc/`                                    |
| New Screen Addition       | `lib/pages/[feature_name]/`                               |
| Data Models               | `lib/model/`                                               |

---

## ROUTING MAP

| Path (Screen)             | Component          | Type         |
|---------------------------|--------------------|--------------|
| `SplashScreen`            | `SplashScreen`     | Initial/Root |
| `HomeScreen`              | `HomeScreen`       | Main Grid    |

---

## DATA FLOW

```
[User Interaction] → [BLoC Event] → [BLoC State Mapping] → [Service Call (if needed)] → [State Update] → [Widget Re-build]
```

**Authentication Flow:** [TBD]

---

## FLUTTER SCRIPTS

| Script             | Command                                              |
|--------------------|------------------------------------------------------|
| `flutter run`      | Start development app                                |
| `flutter build`    | Build production binaries (apk, ipa, web)            |
| `flutter analyze`  | Run linter and static analysis                       |
| `flutter test`     | Run unit/widget tests                                |
