# Architecture

## Directory Structure
```
lib/
├── main.dart                    # Entry point, DI wiring
├── firebase_options.dart        # Generated Firebase config
└── src/
    ├── app.dart                 # MaterialApp, ScreenUtil, routing
    ├── core/                    # Constants, theme, utils, DI
    ├── features/                # Feature modules (data + presentation)
    │   ├── auth/
    │   ├── hydration/
    │   ├── settings/
    │   └── user/
    ├── services/                # Cross-feature business logic
    ├── data/                    # Shared data layer
    ├── presentation/            # Shared UI (providers, screens, widgets)
    └── navigation/              # Route definitions
```

## Feature Module Layout
```
lib/src/features/<name>/
├── data/
│   ├── datasources/    # Raw data access (Firebase, SQLite, APIs)
│   ├── models/         # Data classes with serialization
│   └── repositories/   # Abstract interface + concrete impl
└── presentation/
    ├── bloc/           # BLoC/Cubit + Event + State
    ├── pages/          # Full-screen widgets
    └── widgets/        # Feature-specific components
```

## Data Flow
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

## Dependency Injection
MultiProvider tree in `main.dart`:
- `Provider.value` — singleton services (`AuthService`, `HydrationService`, etc.)
- `BlocProvider` — BLoCs (`AuthBloc`, `UserBloc`, `HydrationBloc`)
- `ChangeNotifierProvider` — `ThemeProvider`, `BottomNavProvider`
- `get_it` — via `injection_container.dart` for service-locator access outside widget tree

## Adding a New Feature
1. Create directory: `lib/src/features/<feature_name>/data/` and `presentation/`
2. Register in `main.dart`: add Provider/BlocProvider to MultiProvider tree
3. Add routes: define in `app_routes.dart`, add case in `app_router.dart`
4. Add strings: UI text goes in `app_strings.dart`

## Key Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, DI wiring |
| `lib/src/app.dart` | MaterialApp shell |
| `lib/src/core/constants/app_strings.dart` | All UI strings |
| `lib/src/core/constants/app_assets.dart` | Asset path constants |
| `lib/src/core/theme/app_theme.dart` | Theme (light + dark) |
| `lib/src/navigation/app_router.dart` | Route generation |
| `lib/src/navigation/app_routes.dart` | Route name constants |
| `lib/src/services/hydration_service.dart` | Core hydration logic |
| `lib/src/services/notification_service.dart` | Notification scheduling |
| `lib/src/data/local/database_helper.dart` | SQLite schema |
| `pubspec.yaml` | Dependencies |
| `analysis_options.yaml` | Linter config |
| `firestore.rules` | Firestore security rules |
| `.github/workflows/main.yml` | CI pipeline |
