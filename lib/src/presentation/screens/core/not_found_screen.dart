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
                Icons
                    .error, // Changed from Icons.error_outline to filled version for M3 emphasis
                color: Theme.of(context).colorScheme.error,
                size: 80.sp,
              ),
              SizedBox(height: 20.h),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight
                          .bold, // fontWeight will be removed in text style audit if not M3 standard
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h), // Changed from 10.h to 12.h
              Text(
                routeName != null
                    ? "Sorry, the route '$routeName' could not be found."
                    : AppStrings
                        .anErrorOccurred, // Generic message if routeName is null
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h), // Changed from 30.h to 32.h
              ElevatedButton(
                onPressed: () {
                  // Navigate to a safe route, like home or auth gate
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
