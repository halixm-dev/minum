// lib/src/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:minum/src/core/constants/app_assets.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/navigation/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To mark onboarding as completed
import 'package:minum/main.dart'; // For logger

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = [
    {
      'image': AppAssets.onboarding1,
      'title': AppStrings.onboarding1Title,
      'description': AppStrings.onboarding1Desc,
    },
    {
      'image': AppAssets.onboarding2,
      'title': AppStrings.onboarding2Title,
      'description': AppStrings.onboarding2Desc,
    },
    {
      'image': AppAssets.onboarding3,
      'title': AppStrings.onboarding3Title,
      'description': AppStrings.onboarding3Desc,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      logger.i("Onboarding marked as completed.");
      if (mounted) {
        // Navigate to the simplified LoginScreen
        Navigator.of(context).pushReplacementNamed(
            AppRoutes.login); // Changed from AppRoutes.welcome
        logger.i("OnboardingScreen: Navigating to LoginScreen.");
      }
    } catch (e) {
      logger.e("Error saving onboarding status or navigating: $e");
      if (mounted) {
        Navigator.of(context)
            .pushReplacementNamed(AppRoutes.login); // Fallback to LoginScreen
        logger.w(
            "OnboardingScreen: Fallback navigation to LoginScreen due to error.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use M3 surface color
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, right: 16.w),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  // TextButton style comes from TextButtonThemeData
                  child: Text(AppStrings.skip,
                      style: TextStyle(
                          fontSize:
                              16.sp)), // Color will be colorScheme.primary
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    context: context, // Pass context
                    imagePath: _onboardingPages[index]['image']!,
                    title: _onboardingPages[index]['title']!,
                    description: _onboardingPages[index]['description']!,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 32.h), // Adjusted vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingPages.length,
                      (idx) => _buildDot(
                          idx, context, colorScheme), // Pass colorScheme
                    ),
                  ),
                  SizedBox(
                    width: 150
                        .w, // Slightly wider for potentially longer "Get Started" text
                    height: 48.h, // M3 typical height for FilledButton
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required BuildContext context, // Added context
    required String imagePath,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context); // Get theme from context
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 280.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              logger.e("Onboarding image error: $error for path $imagePath");
              return Container(
                height: 280.h,
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3), // Use M3 color
                child: Center(
                    child: Icon(Symbols.image_not_supported,
                        size: 100.sp,
                        color: colorScheme.onSurfaceVariant)), // Use M3 color
              );
            },
          ),
          SizedBox(height: 40.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.primary, // Use M3 color
              // fontWeight removed, use M3 theme's definition
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, // Use M3 color
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, BuildContext context, ColorScheme colorScheme) {
    // Added colorScheme
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 8.w),
      height: 10.h,
      width: _currentPage == index ? 24.w : 10.w,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest, // Use M3 colors
        borderRadius: BorderRadius.circular(5.r),
      ),
    );
  }
}
