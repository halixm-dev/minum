// lib/src/core/constants/app_assets.dart

/// A utility class that holds paths to all image assets in the application.
///
/// This class is not meant to be instantiated. It provides static constants
/// to avoid using hardcoded strings for asset paths, making them easy to
/// manage and preventing typos.
class AppAssets {
  /// Private constructor to prevent instantiation.
  AppAssets._();

  // --- Base Paths ---
  /// The base path for all image assets.
  static const String _imagesBasePath = "assets/images";

  // --- Images ---
  /// The path to the application logo image.
  static const String appLogo = "$_imagesBasePath/app_logo.png";

  /// The path to the first onboarding screen image.
  static const String onboarding1 = "$_imagesBasePath/onboarding_1.png";

  /// The path to the second onboarding screen image.
  static const String onboarding2 = "$_imagesBasePath/onboarding_2.png";

  /// The path to the third onboarding screen image.
  static const String onboarding3 = "$_imagesBasePath/onboarding_3.png";

  /// The path to the water drop image used in the UI.
  static const String waterDrop = "$_imagesBasePath/water_drop.png";

  // --- Icons ---
  // Example: if you have custom SVG icons not part of Material/Cupertino
  // static const String googleIcon = "$_iconsBasePath/google_icon.svg";

  // --- Fonts ---
  // Font family names are defined in pubspec.yaml and used directly in TextStyle.
  // This class is mainly for image/icon assets.
  // static const String interRegular = "$_fontsBasePath/Inter-Regular.ttf";
  // static const String interBold = "$_fontsBasePath/Inter-Bold.ttf";
}
