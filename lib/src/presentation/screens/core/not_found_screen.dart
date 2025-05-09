// lib/src/presentation/screens/core/not_found_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart'; // For home route

class NotFoundScreen extends StatelessWidget {
  final String? routeName;
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
                Icons.error_outline,
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
              SizedBox(height: 10.h),
              Text(
                routeName != null
                    ? "Sorry, the route '$routeName' could not be found."
                    : AppStrings.anErrorOccurred, // Generic message if routeName is null
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () {
                  // Navigate to a safe route, like home or auth gate
                  Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
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
