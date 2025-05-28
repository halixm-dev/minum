// lib/src/navigation/app_routes.dart

class AppRoutes {
  AppRoutes._();

  // --- Core Routes ---
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  // static const String welcome = '/welcome'; // Removed
  static const String authGate = '/';

  // --- Authentication Routes ---
  static const String login = '/login';
  static const String register =
      '/register'; // Still keep for potential future use or direct access
  static const String forgotPassword = '/forgot-password'; // Still keep

  // --- Main App Routes ---
  static const String home = '/home';
  static const String history = '/history';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String addWaterLog = '/add-water';

  // --- Settings Sub-Routes (Example) ---
  static const String notificationSettings = '/settings/notifications';
  static const String accountSettings = '/settings/account';
  static const String themeSettings = '/settings/theme';

  // --- Informational Routes ---
  static const String aboutApp = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
}
