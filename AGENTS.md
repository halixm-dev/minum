# Agent Instructions for Minum

> **Purpose:** Single source of truth for AI agents working on the Minum codebase.
> This file acts as the project's table of contents — start here, then consult
> `README.md` for setup instructions and `.agent/rules/` for domain-specific guides.

---

## 1. Project Overview

**Minum** is a smart water reminder app that helps users stay hydrated. It syncs
with Google Account, Google Fit, and Health Connect to calculate ideal water
intake based on weather, calories burned, and weight data. Features include
smart intake calculation, intake logging, progress tracking, customizable
reminders, and offline-first data sync.

| Attribute       | Value                           |
| --------------- | ------------------------------- |
| Package name    | `com.halixm.minum`              |
| Min Flutter SDK | `>=3.5.0 <4.0.0`                |
| Firebase ID     | `halixm-minum`                  |
| License         | MIT                             |
| CI/CD           | GitHub Actions (`.github/workflows/main.yml`) |

---

## 2. Tech Stack

### Core

| Category           | Technology                                                   |
| ------------------ | ------------------------------------------------------------ |
| **Framework**      | Flutter (stable channel, `>=3.5.0`)                          |
| **Language**       | Dart                                                         |
| **State Mgmt**     | `flutter_bloc` (BLoC/Cubit) + `provider` (DI & simple state)|
| **Backend**        | Firebase (Authentication, Cloud Firestore)                   |
| **Networking**     | `dio`                                                        |
| **Local Storage**  | `sqflite`, `shared_preferences`                              |
| **DI**             | `get_it` (service locator) + `provider` (widget-tree DI)     |

### UI & Design

| Package                    | Purpose                              |
| -------------------------- | ------------------------------------ |
| `flutter_screenutil`       | Responsive sizing (`.w`, `.h`, `.sp`)|
| `google_fonts`             | Typography                           |
| `material_symbols_icons`   | Material Symbols icon set            |
| `cupertino_icons`          | iOS-style icons                      |
| `dynamic_color`            | Material You dynamic color theming   |
| `flex_color_picker`        | Color picker widget                  |
| `fl_chart`                 | Charts and graphs                    |

### Services & Utilities

| Package                 | Purpose                                     |
| ----------------------- | ------------------------------------------- |
| `firebase_auth`         | Firebase Authentication                     |
| `cloud_firestore`       | Cloud Firestore database                    |
| `google_sign_in`        | Google Sign-In                              |
| `health`                | Health Connect / Google Fit integration      |
| `awesome_notifications`  | Local notifications / reminders             |
| `connectivity_plus`     | Network connectivity detection              |
| `permission_handler`    | Runtime permissions                         |
| `equatable`             | Value equality for BLoC states/events       |
| `logger`                | Structured logging                          |
| `intl`                  | Date/time formatting & i18n                 |
| `package_info_plus`     | App version info                            |
| `device_info_plus`      | Device info                                 |
| `path_provider`         | File system paths                           |

### Dev Dependencies

| Package              | Purpose                      |
| -------------------- | -----------------------------|
| `flutter_lints`      | Lint rules                   |
| `build_runner`       | Code generation              |
| `mockito`            | Mocking for tests            |
| `integration_test`   | Integration test support     |
| `flutter_driver`     | Driver-based testing         |
| `test`               | Dart test framework          |

---

## 3. Architecture

The project uses a **hybrid architecture**: feature-first modules with BLoC
pattern, combined with a shared `presentation/` layer for cross-cutting UI
and a `services/` layer for domain logic that spans multiple features.

### 3.1 Project Structure

```
minum/
├── lib/
│   ├── main.dart                       # App entry point, DI wiring, provider tree
│   ├── firebase_options.dart           # Generated Firebase config (DO NOT EDIT)
│   └── src/
│       ├── app.dart                    # MaterialApp, ScreenUtil, DynamicColor, routing
│       │
│       ├── core/                       # Shared foundation
│       │   ├── constants/
│       │   │   ├── app_strings.dart    # All UI strings (single source of truth)
│       │   │   └── app_assets.dart     # Asset paths
│       │   ├── theme/
│       │   │   └── app_theme.dart      # ThemeData (light/dark), color schemes
│       │   ├── utils/
│       │   │   ├── app_utils.dart      # Shared utility functions
│       │   │   └── unit_converter.dart # Unit conversion helpers
│       │   └── di/
│       │       └── injection_container.dart  # get_it service locator setup
│       │
│       ├── features/                   # Feature-first modules (BLoC pattern)
│       │   ├── auth/
│       │   │   ├── data/
│       │   │   │   ├── datasources/    # FirebaseAuthDataSource
│       │   │   │   └── repositories/   # AuthRepository (abstract)
│       │   │   └── presentation/
│       │   │       ├── bloc/           # AuthBloc, AuthEvent, AuthState
│       │   │       ├── pages/          # AuthGateScreen, auth screens
│       │   │       └── widgets/        # SocialLoginButton
│       │   │
│       │   ├── hydration/
│       │   │   ├── data/
│       │   │   │   ├── datasources/    # FirebaseHydrationDataSource, LocalHydrationDataSource
│       │   │   │   ├── models/         # HydrationEntryModel
│       │   │   │   └── repositories/   # HydrationRepository, SyncableHydrationRepository
│       │   │   └── presentation/
│       │   │       ├── bloc/           # HydrationBloc, HydrationEvent, HydrationState
│       │   │       ├── pages/          # Home, stats pages
│       │   │       └── widgets/        # Hydration-specific widgets
│       │   │
│       │   ├── settings/
│       │   │   └── presentation/
│       │   │       ├── bloc/           # ReminderSettingsCubit
│       │   │       ├── pages/          # SettingsScreen
│       │   │       └── widgets/        # ThemeSelector
│       │   │
│       │   └── user/
│       │       ├── data/
│       │       │   ├── datasources/    # FirebaseUserDataSource
│       │       │   ├── models/         # UserModel
│       │       │   └── repositories/   # UserRepository (abstract)
│       │       └── presentation/
│       │           └── bloc/           # UserBloc, UserEvent, UserState
│       │
│       ├── data/                       # Shared data layer
│       │   ├── local/
│       │   │   └── database_helper.dart # SQLite database helper
│       │   ├── models/                 # (reserved for cross-feature models)
│       │   └── repositories/
│       │       ├── firebase/           # Shared Firebase repository impls
│       │       └── local/              # Shared local repository impls
│       │
│       ├── services/                   # Cross-feature business logic
│       │   ├── auth_service.dart       # Auth orchestration
│       │   ├── hydration_service.dart  # Hydration calculations & tracking
│       │   ├── health_service.dart     # Health Connect / Google Fit
│       │   └── notification_service.dart # Notification scheduling
│       │
│       ├── presentation/              # Shared / cross-feature UI
│       │   ├── providers/
│       │   │   ├── theme_provider.dart       # Theme state (ChangeNotifier)
│       │   │   └── bottom_nav_provider.dart  # Bottom navigation state
│       │   ├── screens/
│       │   │   ├── splash_screen.dart
│       │   │   ├── onboarding/        # OnboardingScreen
│       │   │   ├── home/              # (placeholder)
│       │   │   ├── profile/           # ProfileScreen
│       │   │   ├── settings/          # (placeholder)
│       │   │   ├── stats/             # (placeholder)
│       │   │   └── core/              # NotFoundScreen
│       │   └── widgets/
│       │       ├── common/            # Reusable widgets
│       │       ├── home/              # (placeholder)
│       │       └── settings/          # (placeholder)
│       │
│       └── navigation/
│           ├── app_router.dart         # Named route generation (onGenerateRoute)
│           └── app_routes.dart         # Route name constants
│
├── assets/
│   └── images/                         # App image assets
├── android/                            # Android platform code
├── ios/                                # iOS platform code
├── web/                                # Web platform code
├── firestore.rules                     # Firestore security rules
├── firebase.json                       # Firebase project config
├── analysis_options.yaml               # Dart analyzer config (flutter_lints)
├── pubspec.yaml                        # Dependencies and metadata
└── .github/workflows/main.yml         # CI: build, analyze, test, APK artifact
```

### 3.2 Layer Responsibilities

| Layer          | Directory                     | Responsibility                                     |
| -------------- | ----------------------------- | -------------------------------------------------- |
| **Entry**      | `main.dart`                   | Bootstrap Firebase, init services, wire DI tree     |
| **App Shell**  | `src/app.dart`                | MaterialApp, ScreenUtil, DynamicColor, routing      |
| **Features**   | `src/features/<name>/`        | Self-contained feature modules (data + presentation)|
| **Data**       | `*/data/datasources/`         | Raw data access (Firebase, SQLite, APIs)            |
| **Models**     | `*/data/models/`              | Data classes with serialization                     |
| **Repository** | `*/data/repositories/`        | Abstract repo interfaces + concrete implementations |
| **BLoC**       | `*/presentation/bloc/`        | State management (Events → BLoC → States)           |
| **Pages**      | `*/presentation/pages/`       | Full-screen widgets                                 |
| **Widgets**    | `*/presentation/widgets/`     | Reusable, composable UI components                  |
| **Services**   | `src/services/`               | Cross-feature business logic orchestration          |
| **Core**       | `src/core/`                   | Constants, theme, utilities, DI                     |
| **Navigation** | `src/navigation/`             | Route definitions and generation                    |

### 3.3 Data Flow

```
UI (Page/Widget)
    ↓ dispatches Event
BLoC / Cubit
    ↓ calls
Service (cross-feature logic)
    ↓ delegates to
Repository (abstract interface)
    ↓ implemented by
DataSource (Firebase / SQLite / API)
```

### 3.4 Dependency Injection

DI is set up in `main.dart` using a `MultiProvider` tree:
- **`Provider.value`** — injects singleton services (`AuthService`, `HydrationService`, etc.)
- **`BlocProvider`** — creates and provides BLoCs (`AuthBloc`, `UserBloc`, `HydrationBloc`)
- **`ChangeNotifierProvider`** — provides `ThemeProvider`, `BottomNavProvider`
- **`get_it`** — available via `injection_container.dart` for service-locator access outside widget tree

### 3.5 Key Patterns

| Pattern                    | Where                                  | Notes                                          |
| -------------------------- | -------------------------------------- | ---------------------------------------------- |
| **Repository Pattern**     | `*/repositories/`                      | Abstract interfaces, concrete datasource impls |
| **BLoC Pattern**           | `*/bloc/`                              | Event-driven state with `flutter_bloc`         |
| **Cubit Pattern**          | `settings/bloc/`                       | Simplified BLoC for settings                   |
| **Syncable Repository**    | `hydration/data/repositories/`         | Local-first with Firebase sync                 |
| **Provider (legacy/DI)**   | `presentation/providers/`              | `ChangeNotifier` for theme & nav               |
| **Named Routing**          | `navigation/`                          | `onGenerateRoute` with `AppRoutes` constants   |

---

## 4. Key Files (Quick Reference)

| File                                         | Purpose                                    |
| -------------------------------------------- | ------------------------------------------ |
| `lib/main.dart`                              | Entry point, DI wiring                     |
| `lib/src/app.dart`                           | MaterialApp shell                          |
| `lib/src/core/constants/app_strings.dart`    | **All** UI strings                         |
| `lib/src/core/constants/app_assets.dart`     | Asset path constants                       |
| `lib/src/core/theme/app_theme.dart`          | Theme definitions (light + dark)           |
| `lib/src/navigation/app_router.dart`         | Route generation logic                     |
| `lib/src/navigation/app_routes.dart`         | Route name constants                       |
| `lib/src/services/hydration_service.dart`    | Core hydration business logic              |
| `lib/src/services/notification_service.dart` | Notification scheduling logic              |
| `lib/src/data/local/database_helper.dart`    | SQLite database schema & helpers           |
| `pubspec.yaml`                               | Dependencies                               |
| `analysis_options.yaml`                      | Linter config (`flutter_lints`)            |
| `firestore.rules`                            | Firestore security rules                   |
| `.github/workflows/main.yml`                 | CI pipeline                                |

---

## 5. Development Guidelines

### 5.1 Coding Standards

1. **Strings:** Always use `AppStrings` in `lib/src/core/constants/app_strings.dart`. Never hardcode UI text in widgets.
2. **Responsiveness:** Use `flutter_screenutil` extensions (`.w`, `.h`, `.sp`, `.r`) for all sizing.
3. **State Management:**
   - Use **BLoC/Cubit** (`flutter_bloc`) for feature state. Follow the Event → BLoC → State pattern.
   - Use **Provider** (`ChangeNotifier`) only for simple cross-cutting concerns (theme, nav).
   - Avoid `setState` for anything beyond trivial, widget-local state.
4. **Architecture:**
   - New features go in `src/features/<feature_name>/` with `data/` and `presentation/` subdirectories.
   - Repositories must define an abstract interface; datasources implement them.
   - Services in `src/services/` orchestrate cross-feature logic.
5. **Error Handling:** Use `try/catch` with `logger` for all async operations. Never silently swallow errors.
6. **Equality:** Use `Equatable` for all BLoC events and states.
7. **Naming:**
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/functions: `camelCase`
   - BLoC files: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`

### 5.2 Adding a New Feature

```
1. Create feature directory:
   lib/src/features/<feature_name>/
   ├── data/
   │   ├── datasources/      # Firebase/Local data source
   │   ├── models/            # Data models
   │   └── repositories/     # Abstract repo + impl
   └── presentation/
       ├── bloc/              # BLoC/Cubit + Event + State
       ├── pages/             # Screens
       └── widgets/           # Feature-specific widgets

2. Register in main.dart:
   - Add Provider/BlocProvider to the MultiProvider tree

3. Add routes:
   - Define route name in app_routes.dart
   - Add case in app_router.dart

4. Add strings:
   - Add UI text to app_strings.dart
```

### 5.3 Testing

| Type             | Location                 | Command                        |
| ---------------- | ------------------------ | ------------------------------ |
| Unit tests       | `test/unit/`             | `flutter test test/unit/`      |
| Widget tests     | `test/`                  | `flutter test`                 |
| Integration tests| `integration_test/`      | `flutter test integration_test`|
| All tests        | —                        | `flutter test`                 |
| With coverage    | —                        | `flutter test --coverage`      |

### 5.4 Building

| Target          | Command                                    |
| --------------- | ------------------------------------------ |
| Android (debug) | `flutter build apk --debug`                |
| Android (release)| `flutter build apk --release`             |
| Android (bundle)| `flutter build appbundle --release`        |
| iOS (release)   | `flutter build ios --release`              |
| Analyze         | `flutter analyze`                          |
| Format check    | `dart format --output=none --set-exit-if-changed .` |

### 5.5 CI/CD

The GitHub Actions workflow (`.github/workflows/main.yml`) runs on push/PR to
`main` and `develop`:

1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test --coverage`
5. `flutter build apk --debug`
6. Upload debug APK artifact

---

## 6. Cross-References

| Topic               | Location                                    |
| -------------------- | ------------------------------------------ |
| Branching strategy   | `.agent/rules/branching-strategy.md`       |
| Build guide          | `.agent/rules/build-guide.md`              |
| Design tokens/theming| `.agent/rules/design-tokens-guide.md`      |
| i18n/l10n            | `.agent/rules/i18n-guide.md`               |
| Lint & format        | `.agent/rules/lint-format-guide.md`        |
| Test guide           | `.agent/rules/test-guide.md`               |
| Editing tools        | `.agent/rules/preferred-editing-tools.md`  |
| README (setup)       | `README.md`                                |
| Firestore rules      | `firestore.rules`                          |
