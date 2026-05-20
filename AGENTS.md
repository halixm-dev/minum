# Agent Instructions

## Project
Flutter water reminder app (`com.halixm.minum`), SDK >=3.5.0 <4.0.0.
BLoC pattern, feature-first modules, Firebase + SQLite.

## Non-Standard Commands
```bash
flutter analyze              # Static analysis
dart format --output=none --set-exit-if-changed .  # Format check
flutter test --coverage      # Tests with coverage
flutter build apk --debug    # Debug APK
flutter build appbundle --release  # Release bundle
```

## Guides
| Topic | File |
|-------|------|
| Architecture & structure | `.agents/rules/architecture.md` |
| Coding & naming standards | `.agents/rules/coding-standards.md` |
| Testing | `.agents/rules/test-guide.md` |
| Build & CI/CD | `.agents/rules/build-guide.md` |
| Lint & format | `.agents/rules/lint-format-guide.md` |
| Branching strategy | `.agents/rules/branching-strategy.md` |
