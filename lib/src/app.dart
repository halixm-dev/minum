// lib/src/app.dart
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/presentation/screens/auth_gate_screen.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/navigation/app_router.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';

/// The root widget of the Minum application.
///
/// This widget sets up the `MaterialApp` and integrates providers,
/// screen utilities, and dynamic color theming.
class MinumApp extends StatefulWidget {
  /// Creates a `MinumApp`.
  const MinumApp({super.key});

  @override
  State<MinumApp> createState() => _MinumAppState();
}

class _MinumAppState extends State<MinumApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<HydrationProvider>(context, listen: false)
            .processPendingWaterAddition();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (screenUtilContext, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamicScheme,
              ColorScheme? darkDynamicScheme) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setDynamicColorSchemes(
                      lightDynamicScheme, darkDynamicScheme);
            });

            return MaterialApp(
              title: 'Minum - Water Reminder',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: themeProvider.currentLightThemeData,
              darkTheme: themeProvider.currentDarkThemeData,
              home: const AuthGateScreen(),
              onGenerateRoute: AppRouter.generateRoute,
              builder: (materialAppContext, widget) {
                return widget!;
              },
            );
          },
        );
      },
    );
  }
}
