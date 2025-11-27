// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/screens/home/main_hydration_view.dart';
import 'package:minum/src/presentation/screens/settings/settings_screen.dart';
import 'package:minum/src/presentation/screens/stats/hydration_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/main.dart'; // For logger

/// The main screen of the application after the user is authenticated.
///
/// This screen contains the bottom navigation bar and displays the selected
/// view (`MainHydrationView`, `HydrationHistoryScreen`, or `SettingsScreen`).
class HomeScreen extends StatefulWidget {
  /// Creates a `HomeScreen`.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const MainHydrationView(),
    const HydrationHistoryScreen(),
    const SettingsScreen(),
  ];

  final List<String> _appBarTitles = [
    AppStrings.homeTitle,
    AppStrings.historyTitle,
    AppStrings.settingsTitle,
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile == null &&
        userProvider.status != UserProfileStatus.loading) {
      final authUser =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (authUser != null) {
        logger.i(
            "HomeScreen initState: User profile is null, UserProvider should fetch it via auth state changes.");
      }
    }

    // Trigger Health Connect Sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authUser =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (authUser != null) {
        Provider.of<HydrationService>(context, listen: false)
            .syncHealthConnectData(authUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final currentIndex = bottomNavProvider.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[currentIndex]),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.addWaterLog);
              },
              tooltip: "Log Water Intake",
              child: Icon(Symbols.add,
                  size: 28.sp), // Icon color will also be from theme
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          bottomNavProvider.setCurrentIndex(index);
        },
        // Styling for NavigationBar comes from navigationBarTheme in AppTheme:
        // - backgroundColor: colorScheme.surfaceContainer
        // - indicatorColor: colorScheme.secondaryContainer
        // - iconTheme: (selected: onSecondaryContainer, unselected: onSurfaceVariant)
        // - labelTextStyle: (selected: onSurface, unselected: onSurfaceVariant, using labelMedium)
        // - height: 80.h
        // - elevation: 2.0
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Symbols.home),
            selectedIcon: Icon(
                Symbols.home), // M3 often uses filled icons for selected state
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Symbols.bar_chart),
            selectedIcon: Icon(Symbols.bar_chart),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Symbols.settings),
            selectedIcon: Icon(Symbols.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
