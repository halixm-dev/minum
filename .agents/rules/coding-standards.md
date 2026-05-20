# Coding Standards

## Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- BLoC files: `<feature>_bloc.dart`, `<feature>_event.dart`, `<feature>_state.dart`

## Dart/Flutter Conventions
- Use `const` constructors where possible
- Prefer `final` for local variables
- Use named parameters for functions with 3+ parameters
- Prefer `async/await` over raw Futures
- Use `mounted` check before `setState` in async gaps
- Prefer `CustomPainters` or `RenderObjectCustomPainter` over `Stack` for complex layouts

## Type Safety
- Enable strict analysis in `analysis_options.yaml`
- Avoid `dynamic` — use explicit types or generics
- Use `typedef` for complex function signatures
- Prefer `sealed` classes for exhaustive pattern matching (Dart 3+)

## Strings
All UI text in `lib/src/core/constants/app_strings.dart`. Never hardcode in widgets.

## Sizing
Use `flutter_screenutil` extensions: `.w`, `.h`, `.sp`, `.r`.

## State Management
- **BLoC/Cubit** (`flutter_bloc`) for feature state — Event → BLoC → State pattern
- **Provider** (`ChangeNotifier`) only for simple cross-cutting concerns (theme, nav)
- Avoid `setState` except trivial widget-local state
- Use `Equatable` for all BLoC events and states

## Error Handling
`try/catch` with `logger` for all async operations. Never silently swallow errors.

## Linting
Uses `flutter_lints` via `analysis_options.yaml`. Run `flutter analyze` before committing.

## Dependencies
- `get_it` for service-locator access outside widget tree (`injection_container.dart`)
- Always check `pubspec.yaml` before assuming a library is available
