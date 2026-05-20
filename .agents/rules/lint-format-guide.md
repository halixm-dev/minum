# Lint & Format Guide

## Commands

```bash
flutter analyze                  # Static analysis
dart format .                    # Auto-format
dart format --output=none --set-exit-if-changed .  # Format check (CI)
```

## Configuration

See `analysis_options.yaml` at project root. Uses `flutter_lints`.

## Key Rules

- Strict mode enabled
- All recommended lints
- Flutter-specific lints

## Editor Integration

Dart extension automatically uses `analysis_options.yaml`.

## Pre-commit

Run before committing:
```bash
flutter analyze && dart format --output=none --set-exit-if-changed .
```
