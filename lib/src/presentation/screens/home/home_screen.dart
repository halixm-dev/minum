// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:minum/src/core/constants/app_colors.dart';
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
    if (userProvider.userProfile == null && userProvider.status != UserProfileStatus.loading) {
      final authUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (authUser != null) {
        logger.i("HomeScreen initState: User profile is null, UserProvider should fetch it via auth state changes.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final currentIndex = bottomNavProvider.currentIndex;
    final user = Provider.of<UserProvider>(context).userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[currentIndex]),
        centerTitle: true,
        actions: [
          // Removed the conditional add button from AppBar actions.
          // The FAB on the home screen is now the primary way to add water.
          // if (currentIndex != 0)
          //   IconButton(
          //     icon: Icon(Icons.add_circle_outline, size: 28.sp, color: Theme.of(context).appBarTheme.actionsIconTheme?.color ?? Theme.of(context).primaryColor),
          //     tooltip: "Add Water",
          //     onPressed: () {
          //       Navigator.of(context).pushNamed(AppRoutes.addWaterLog);
          //     },
          //   ),
          if (currentIndex == 2) // Profile icon still shown on Settings tab
            IconButton(
              icon: CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primaryColor.withAlpha(50),
                backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                    ? Icon(Icons.person_outline, size: 18.sp, color: AppColors.primaryColor)
                    : null,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
            ),
        ],
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: "Log Water Intake",
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 28.sp),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface,
        elevation: Theme.of(context).bottomAppBarTheme.elevation ?? 8.0,
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(context: context, icon: Icons.home_outlined, label: 'Home', index: 0),
              _buildNavItem(context: context, icon: Icons.bar_chart_outlined, label: 'History', index: 1),
              _buildNavItem(context: context, icon: Icons.settings_outlined, label: 'Settings', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required BuildContext context, required IconData icon, required String label, required int index}) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context, listen: false);
    final currentTab = Provider.of<BottomNavProvider>(context).currentIndex;
    final isSelected = currentTab == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).unselectedWidgetColor;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => bottomNavProvider.setCurrentIndex(index),
          splashColor: Theme.of(context).colorScheme.primary.withAlpha(30),
          highlightColor: Theme.of(context).colorScheme.primary.withAlpha(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 10.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
