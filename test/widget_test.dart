// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// To potentially test MinumApp later
import 'package:minum/src/presentation/widgets/common/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // If widgets depend on it for sizing

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

void main() {
  // Default Flutter counter app test (commented out for our custom tests)
  /*
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Replace MinumApp() with your actual app widget if testing the whole app.
    // For isolated widget tests, you typically build just the widget under test.
    await tester.pumpWidget(const MinumApp()); // Assuming MinumApp is your root widget

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  */

  // Group for CustomButton tests
  group('CustomButton Widget Tests', () {
    // Test to verify that the CustomButton displays text correctly.
    testWidgets('CustomButton displays text and can be tapped',
        (WidgetTester tester) async {
      String buttonText = 'Tap Me';
      bool tapped = false;

      // Build the CustomButton widget.
      // We need to wrap it in a MaterialApp and Scaffold (or another Material ancestor)
      // to provide context for theming and directionality.
      // Also, ScreenUtilInit if your widget relies on ScreenUtil for sizing.
      await tester.pumpWidget(ScreenUtilInit(
          // Ensure ScreenUtil is initialized if CustomButton uses it
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              home: Scaffold(
                body: CustomButton(
                  text: buttonText,
                  onPressed: () {
                    tapped = true;
                  },
                ),
              ),
            );
          }));

      // Verify that the button displays the correct text.
      expect(find.text(buttonText), findsOneWidget);

      // Simulate a tap on the button.
      await tester.tap(find.widgetWithText(CustomButton, buttonText));
      await tester.pump(); // Rebuild the widget after the tap.

      // Verify that the onPressed callback was called.
      expect(tapped, isTrue);
    });

    // Test to verify the loading state of CustomButton.
    testWidgets('CustomButton shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      String buttonText = 'Loading Button';

      // Build the CustomButton in its loading state.
      await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, child) {
            return MaterialApp(
              home: Scaffold(
                body: CustomButton(
                  text: buttonText,
                  isLoading: true,
                  onPressed:
                      () {}, // onPressed can be null or empty for loading state
                ),
              ),
            );
          }));

      // Verify that the CircularProgressIndicator is present.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify that the button text is NOT directly visible when loading.
      // The CustomButton implementation replaces text with CircularProgressIndicator.
      expect(find.text(buttonText), findsNothing);

      // Verify the button is disabled (onPressed is effectively null when isLoading is true)
      final CustomButton button = tester.widget(find.byType(CustomButton));
      expect(button.onPressed, isNull);
    });

    // Test to verify the button is disabled when onPressed is null
    testWidgets('CustomButton is disabled when onPressed is null',
        (WidgetTester tester) async {
      String buttonText = 'Disabled Button';

      await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, child) {
            return MaterialApp(
              home: Scaffold(
                body: CustomButton(
                  text: buttonText,
                  onPressed: null, // Explicitly disabled
                ),
              ),
            );
          }));

      // Verify the button text is displayed.
      expect(find.text(buttonText), findsOneWidget);

      // Check if the ElevatedButton inside CustomButton is disabled.
      // We find the ElevatedButton and check its onPressed property.
      final ElevatedButton elevatedButton =
          tester.widget(find.byType(ElevatedButton));
      expect(elevatedButton.onPressed, isNull);

      // Attempt to tap and ensure no action happens (not easily verifiable without a callback state change)
      // But checking onPressed == null is a good indicator of disabled state.
    });
  });

  // You can add more test groups for other widgets here.
  // For example, testing MinumApp (the root widget) would require setting up mock providers.
  // testWidgets('MinumApp builds and shows initial screen', (WidgetTester tester) async {
  //   // TODO: Setup mock providers for AuthService, HydrationService, etc.
  //   // await tester.pumpWidget(
  //   //   MultiProvider(
  //   //     providers: [
  //   //       // Provide mock instances of your services/providers here
  //   //     ],
  //   //     child: const MinumApp(),
  //   //   ),
  //   // );
  //
  //   // Add expectations, e.g., find the SplashScreen or AuthGateScreen initially.
  //   // expect(find.byType(SplashScreen), findsOneWidget); // Or AuthGateScreen
  // });
}
