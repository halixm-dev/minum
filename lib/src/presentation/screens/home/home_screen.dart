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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

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
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOutBack,
    ));

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<BottomNavProvider>(context, listen: false).currentIndex ==
          0) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final currentIndex = bottomNavProvider.currentIndex;
    final theme = Theme.of(context);

    if (currentIndex == 0) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(
        title: Text(_appBarTitles[currentIndex]),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[currentIndex],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.addWaterLog);
          },
          tooltip: "Log Water Intake",
          child: Icon(Icons.add, size: 28.sp),
        ),
      ),
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
// _buildNavItem method is no longer needed as NavigationBar handles its items directly.
