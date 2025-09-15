// lib/src/presentation/screens/core/not_found_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';

/// A screen that is displayed when a route is not found.
class NotFoundScreen extends StatelessWidget {
  /// The name of the route that was not found.
  final String? routeName;

  /// Creates a `NotFoundScreen`.
  ///
  /// The [routeName] is optional and will be displayed in the error message.
  const NotFoundScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.error),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Symbols
                    .error,
                color: Theme.of(context).colorScheme.error,
                size: 80.sp,
              ),
              SizedBox(height: 20.h),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                routeName != null
                    ? "Sorry, the route '$routeName' could not be found."
                    : AppStrings.anErrorOccurred,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.authGate);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
