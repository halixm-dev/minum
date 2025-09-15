// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/screens/home/main_hydration_view.dart';
import 'package:minum/src/presentation/screens/settings/settings_screen.dart';
import 'package:minum/src/presentation/screens/stats/hydration_history_screen.dart';
import 'package:minum/src/presentation/widgets/home/fab_menu.dart';
import 'package:provider/provider.dart';
import 'package:minum/main.dart'; // For logger

class HomeScreen extends StatefulWidget {
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

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitles[currentIndex]),
            // centerTitle and actions will be handled by appBarTheme from AppTheme
          ),
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              bottomNavProvider.setCurrentIndex(index);
            },
            // Styling for NavigationBar comes from navigationBarTheme in AppTheme
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Symbols.home,
                    weight: 600, fontFamily: MaterialSymbols.rounded),
                selectedIcon: Icon(Symbols.home,
                    fill: 1, weight: 600, fontFamily: MaterialSymbols.rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Symbols.bar_chart,
                    weight: 600, fontFamily: MaterialSymbols.rounded),
                selectedIcon: Icon(Symbols.bar_chart,
                    fill: 1, weight: 600, fontFamily: MaterialSymbols.rounded),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Symbols.settings,
                    weight: 600, fontFamily: MaterialSymbols.rounded),
                selectedIcon: Icon(Symbols.settings,
                    fill: 1, weight: 600, fontFamily: MaterialSymbols.rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
        if (currentIndex == 0) const FabMenu(),
      ],
    );
  }
}
// _buildNavItem method is no longer needed as NavigationBar handles its items directly.
