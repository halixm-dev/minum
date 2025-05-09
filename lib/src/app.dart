// lib/src/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/presentation/screens/auth_gate_screen.dart'; // Default home screen
import 'package:provider/provider.dart';

import 'package:minum/src/core/theme/app_theme.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/navigation/app_router.dart'; // Import your AppRouter
// Import your AppRoutes for initialRoute if needed

class MinumApp extends StatelessWidget {
  const MinumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Minum - Water Reminder',
          debugShowCheckedModeBanner: false,

          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Option 1: Keep `home` and add `onGenerateRoute` for other routes.
          // `AuthGateScreen` will be the initial screen loaded by MaterialApp.
          // Any `pushNamed` calls will then use `AppRouter.generateRoute`.
          home: const AuthGateScreen(),
          onGenerateRoute: AppRouter.generateRoute, // <-- ENSURE THIS LINE IS PRESENT AND UNCOMMENTED

          // Option 2: Use `initialRoute` with `onGenerateRoute` (more common for fully named routing)
          // If you use this, make sure AppRoutes.authGate (or your intended initial route like AppRoutes.splash)
          // is handled correctly by AppRouter.generateRoute.
          // initialRoute: AppRoutes.splash, // Or AppRoutes.authGate if that's your true entry point for routing
          // onGenerateRoute: AppRouter.generateRoute,

          builder: (context, widget) {
            return widget!;
          },
        );
      },
    );
  }
}
