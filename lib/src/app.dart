// lib/src/app.dart
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/presentation/screens/auth_gate_screen.dart'; // Default home screen
import 'package:provider/provider.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/navigation/app_router.dart';

class MinumApp extends StatelessWidget {
  const MinumApp({super.key});

  @override
  Widget build(BuildContext context) {
    // listen: true is important here so MaterialApp rebuilds on theme changes
    final themeProvider = Provider.of<ThemeProvider>(context); 

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (screenUtilContext, child) { // Renamed context to avoid conflict, though not strictly necessary here
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamicScheme, ColorScheme? darkDynamicScheme) {
            // Update ThemeProvider with the dynamic palettes after the build frame.
            // Use the 'context' from MinumApp's build method, which has ThemeProvider in its widget tree.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<ThemeProvider>(context, listen: false) 
                  .setDynamicColorSchemes(lightDynamicScheme, darkDynamicScheme);
            });

            return MaterialApp(
              title: 'Minum - Water Reminder',
              debugShowCheckedModeBanner: false,

              themeMode: themeProvider.themeMode,
              theme: themeProvider.currentLightThemeData, // Use new getter
              darkTheme: themeProvider.currentDarkThemeData, // Use new getter

              home: const AuthGateScreen(),
              onGenerateRoute: AppRouter.generateRoute,
              
              builder: (materialAppContext, widget) { // This builder is for MaterialApp
                return widget!;
              },
            );
          },
        );
      },
    );
  }
}
