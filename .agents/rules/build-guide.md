# Build Guide

## Commands

```bash
flutter pub get                        # Install dependencies
flutter analyze                        # Static analysis
dart format --output=none --set-exit-if-changed .  # Format check
flutter test --coverage                # Tests with coverage
flutter build apk --debug              # Debug APK
flutter build appbundle --release      # Release AAB
flutter build ios --release            # Release iOS
flutter clean                          # Clean build artifacts
```

## Build Runner (code generation)

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch            # Watch mode
```

## CI Pipeline

GitHub Actions on push to main/develop:

1. `flutter pub get`
2. `flutter analyze`
3. `dart format --output=none --set-exit-if-changed .`
4. `flutter test --coverage`
5. `flutter build apk --debug`

## Common Issues

```bash
# Dependency conflicts
flutter pub cache clean
flutter pub get

# Build cache issues
flutter clean && flutter pub get

# iOS pod issues
cd ios && pod install --repo-update
```

## Firebase

- `firebase_options.dart` — generated, do not edit
- `firestore.rules` — security rules
- Deploy rules: `firebase deploy --only firestore:rules`
