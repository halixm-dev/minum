# Test Guide

## Commands

```bash
flutter test                    # Run all tests
flutter test --coverage         # With coverage report
flutter test test/path/specific_test.dart  # Single file
```

## File Patterns

- Unit tests: `test/**/*_test.dart`
- Widget tests: `test/**/*_widget_test.dart`
- Integration tests: `integration_test/**/*_test.dart`

## Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minum/src/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email returns error for invalid input', () {
      expect(Validators.validateEmail('bad'), isNotNull);
    });

    test('email returns null for valid input', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });
  });
}
```

## Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minum/src/features/hydration/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage shows greeting', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );
    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

## Best Practices

- One test file per source file
- Group related tests with `group()`
- Mock external dependencies (Firebase, SQLite)
- Test behavior, not implementation
- Aim for 80%+ on critical paths
