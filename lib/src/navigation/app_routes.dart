// lib/src/navigation/app_routes.dart

/// A utility class that holds the route names for the application.
///
/// This class is not meant to be instantiated. It provides static constants
/// for all the route names used in the app, which helps in avoiding typos
/// and managing routes centrally.
class AppRoutes {
  /// Private constructor to prevent instantiation.
  AppRoutes._();

  // --- Core Routes ---
  /// The route for the splash screen.
  static const String splash = '/splash';

  /// The route for the onboarding screen.
  static const String onboarding = '/onboarding';

  /// The route for the authentication gate, which determines whether to show
  /// the login screen or the home screen. This is the root route.
  static const String authGate = '/';

  // --- Authentication Routes ---
  /// The route for the login screen.
  static const String login = '/login';

  /// The route for the registration screen.
  static const String register = '/register';

  /// The route for the forgot password screen.
  static const String forgotPassword = '/forgot-password';

  // --- Main App Routes ---
  /// The route for the home screen.
  static const String home = '/home';

  /// The route for the hydration history screen.
  static const String history = '/history';

  /// The route for the progress screen.
  static const String progress = '/progress';

  /// The route for the settings screen.
  static const String settings = '/settings';

  /// The route for the user profile screen.
  static const String profile = '/profile';

  /// The route for the screen to add a new water log.
  static const String addWaterLog = '/add-water';

  // --- Settings Sub-Routes (Example) ---
  /// The route for the notification settings screen.
  static const String notificationSettings = '/settings/notifications';

  /// The route for the account settings screen.
  static const String accountSettings = '/settings/account';

  /// The route for the theme settings screen.
  static const String themeSettings = '/settings/theme';

  // --- Informational Routes ---
  /// The route for the "About App" screen.
  static const String aboutApp = '/about';

  /// The route for the privacy policy screen.
  static const String privacyPolicy = '/privacy-policy';

  /// The route for the terms of service screen.
  static const String termsOfService = '/terms-of-service';
}
