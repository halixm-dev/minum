// lib/src/core/constants/app_strings.dart

/// A utility class that holds all the strings used throughout the application.
///
/// This class is not meant to be instantiated. It provides static constants
/// for strings, which helps in managing and localizing the app's text content.
class AppStrings {
  /// Private constructor to prevent instantiation.
  AppStrings._();

  // --- General ---
  /// The name of the application.
  static const String appName = "Minum";

  /// Text shown during loading states.
  static const String loading = "Loading...";

  /// Generic error text.
  static const String error = "Error";

  /// Generic success text.
  static const String success = "Success";

  /// Message for unexpected errors.
  static const String anErrorOccurred =
      "An unexpected error occurred. Please try again.";

  /// Text for a retry button.
  static const String tryAgain = "Try Again";

  /// Text for an OK button.
  static const String ok = "OK";

  /// Text for a cancel button.
  static const String cancel = "Cancel";

  /// Text for a save button.
  static const String save = "Save";

  /// Text for a delete button.
  static const String delete = "Delete";

  /// Text for an edit button.
  static const String edit = "Edit";

  /// Text for an add button.
  static const String add = "Add";

  /// Text for a done button.
  static const String done = "Done";

  /// Text for a skip button.
  static const String skip = "Skip";

  /// Text for a next button.
  static const String next = "Next";

  /// Text for a previous button.
  static const String previous = "Previous";

  /// Text for a submit button.
  static const String submit = "Submit";

  /// Placeholder text for search fields.
  static const String search = "Search...";

  // --- Authentication ---
  /// Title for the login screen.
  static const String login = "Login";

  /// Text for a logout action.
  static const String logout = "Logout";

  /// Title for the registration screen.
  static const String register = "Register";

  /// Label for email input fields.
  static const String email = "Email";

  /// Label for password input fields.
  static const String password = "Password";

  /// Label for confirm password input fields.
  static const String confirmPassword = "Confirm Password";

  /// Text for the forgot password link.
  static const String forgotPassword = "Forgot Password?";

  /// Prompt for users who don't have an account.
  static const String dontHaveAccount = "Don't have an account? ";

  /// Prompt for users who already have an account.
  static const String alreadyHaveAccount = "Already have an account? ";

  /// Link text to navigate to the sign-up screen.
  static const String signUpHere = "Sign up here";

  /// Link text to navigate to the sign-in screen.
  static const String signInHere = "Sign in here";

  /// Text for the Google Sign-In button.
  static const String loginWithGoogle = "Sign in with Google";

  /// Text for the Google Sign-Up button.
  static const String registerWithGoogle = "Sign up with Google";

  /// Confirmation message after sending a password reset email.
  static const String passwordResetEmailSent =
      "Password reset email sent. Check your inbox.";

  /// Error message for weak passwords.
  static const String weakPassword = "Password is too weak.";

  /// Error message when an email is already in use.
  static const String emailAlreadyInUse = "This email is already in use.";

  /// Error message for invalid email formats.
  static const String invalidEmail = "Invalid email address.";

  /// Error message when a user is not found during login.
  static const String userNotFound = "User not found.";

  /// Error message for an incorrect password.
  static const String wrongPassword = "Incorrect password.";

  /// Error message when passwords do not match.
  static const String passwordsDoNotMatch = "Passwords do not match.";

  // --- Home Screen ---
  /// Title for the home screen.
  static const String homeTitle = "Today's Hydration";

  /// Label for the daily hydration goal.
  static const String dailyGoal = "Daily Goal";

  /// Label for the amount of water consumed.
  static const String consumed = "Consumed";

  /// Label for the remaining amount of water to drink.
  static const String remaining = "Remaining";

  /// Button text to add a water log.
  static const String addWater = "Add Water";

  /// Abbreviation for milliliters.
  static const String ml = "mL";

  /// Abbreviation for ounces.
  static const String oz = "oz";

  /// Example motivational quote on the home screen.
  static const String motivationalQuote = "Drink water, stay refreshed!";

  // --- Hydration Log ---
  /// Title for the screen where users log water intake.
  static const String logWaterTitle = "Log Water Intake";

  /// Prompt asking the user how much water they drank.
  static const String howMuchWater = "How much did you drink?";

  /// Placeholder for the amount input field.
  static const String enterAmount = "Enter amount";

  /// Label for a custom amount input.
  static const String customAmount = "Custom Amount";

  /// Title for the quick add section.
  static const String quickAdd = "Quick Add";

  /// Success message after logging water intake.
  static const String waterLoggedSuccessfully = "Water intake logged!";

  // --- Progress & History ---
  /// Title for the progress screen.
  static const String progressTitle = "Hydration Progress";

  /// Title for the history screen.
  static const String historyTitle = "Hydration History";

  /// Label for the daily average intake.
  static const String dailyAverage = "Daily Average";

  /// Text for the weekly view.
  static const String weekly = "Weekly";

  /// Text for the monthly view.
  static const String monthly = "Monthly";

  /// Text for the yearly view.
  static const String yearly = "Yearly";

  /// Message shown when there is no data for a selected period.
  static const String noDataAvailable = "No data available for this period.";

  // --- Settings ---
  /// Title for the settings screen.
  static const String settingsTitle = "Settings";

  /// Menu item for profile settings.
  static const String profile = "Profile";

  /// Section title for general settings.
  static const String general = "General";

  /// Menu item for notification settings.
  static const String notifications = "Notifications";

  /// Section title for reminder settings.
  static const String reminders = "Reminders";

  /// Setting for the daily water goal.
  static const String dailyWaterGoal = "Daily Water Goal";

  /// Setting for the measurement unit (e.g., mL, oz).
  static const String measurementUnit = "Measurement Unit";

  /// Setting for the reminder frequency.
  static const String reminderFrequency = "Reminder Frequency";

  /// Setting for the reminder sound.
  static const String reminderSound = "Reminder Sound";

  /// Setting to enable or disable reminders.
  static const String enableReminders = "Enable Reminders";

  /// Setting for the app theme.
  static const String theme = "Theme";

  /// Option for light theme.
  static const String lightTheme = "Light";

  /// Option for dark theme.
  static const String darkTheme = "Dark";

  /// Option for system default theme.
  static const String systemTheme = "System Default";

  /// Section title for account settings.
  static const String account = "Account";

  /// Setting to connect to Google Fit.
  static const String connectToGoogleFit = "Connect to Google Fit";

  /// Setting to connect to Health Connect.
  static const String connectToHealthConnect = "Connect to Health Connect";

  /// Action to sync data.
  static const String syncData = "Sync Data";

  /// Section title for "About" information.
  static const String about = "About";

  /// Information about the app version.
  static const String appVersion = "App Version";

  /// Link to the privacy policy.
  static const String privacyPolicy = "Privacy Policy";

  /// Link to the terms of service.
  static const String termsOfService = "Terms of Service";

  /// Action to rate the app.
  static const String rateApp = "Rate App";

  /// Action to share the app.
  static const String shareApp = "Share App";

  /// Label for reminder interval.
  static const String reminderInterval = "Reminder Interval";

  /// Label for start time.
  static const String startTime = "Start Time";

  /// Label for end time.
  static const String endTime = "End Time";

  // --- Notifications ---
  /// Title for hydration reminder notifications.
  static const String reminderTitle = "Stay Hydrated!";

  /// Body text for hydration reminder notifications.
  static const String reminderBody =
      "Time to drink some water. Your body will thank you!";

  /// Body text for smart reminders with a specific amount.
  static const String smartReminderBody =
      "It's a good time for {amount}ml of water!";

  // --- Validation ---
  /// Error message for required fields.
  static const String fieldRequired = "This field is required.";

  /// Error message for invalid number inputs.
  static const String invalidNumber = "Please enter a valid number.";

  /// Error message requiring a positive number.
  static const String positiveNumberRequired =
      "Please enter a positive number.";

  // --- Onboarding ---
  /// Welcome message on the onboarding screen.
  static const String welcomeToMinum = "Welcome to Minum!";

  /// Title for the first onboarding screen.
  static const String onboarding1Title = "Track Your Hydration";

  /// Description for the first onboarding screen.
  static const String onboarding1Desc =
      "Easily log your water intake and monitor your daily progress towards your hydration goals.";

  /// Title for the second onboarding screen.
  static const String onboarding2Title = "Smart Reminders";

  /// Description for the second onboarding screen.
  static const String onboarding2Desc =
      "Get personalized reminders to drink water throughout the day, keeping you on track.";

  /// Title for the third onboarding screen.
  static const String onboarding3Title = "Sync & Analyze";

  /// Description for the third onboarding screen.
  static const String onboarding3Desc =
      "Connect with health apps and see your hydration trends over time. Let's get started!";

  /// Text for the button to start using the app from onboarding.
  static const String getStarted = "Get Started";

  // --- Health Data ---
  /// Label for weight input.
  static const String weight = "Weight";

  /// Abbreviation for kilograms.
  static const String kg = "kg";

  /// Abbreviation for pounds.
  static const String lbs = "lbs";

  /// Label for activity level input.
  static const String activityLevel = "Activity Level";

  /// Option for sedentary activity level.
  static const String sedentary = "Sedentary (little or no exercise)";

  /// Option for light activity level.
  static const String light = "Light (light exercise/sports 1-3 days/week)";

  /// Option for moderate activity level.
  static const String moderate =
      "Moderate (moderate exercise/sports 3-5 days/week)";

  /// Option for active activity level.
  static const String active = "Active (hard exercise/sports 6-7 days a week)";

  /// Option for very active activity level.
  static const String veryActive =
      "Very Active (very hard exercise/sports & physical job or 2x training)";

  /// Label for weather data (conceptual).
  static const String weather = "Weather";

  /// Label for calories burned data (conceptual).
  static const String caloriesBurned = "Calories Burned";
}
