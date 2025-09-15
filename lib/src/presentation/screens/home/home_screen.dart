// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/screens/home/main_hydration_view.dart';
import 'package:minum/src/presentation/screens/settings/settings_screen.dart';
import 'package:minum/src/presentation/screens/stats/hydration_history_screen.dart';
import 'package:provider/provider.dart';
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
              child: Icon(Icons.add, size: 28.sp),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          bottomNavProvider.setCurrentIndex(index);
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
