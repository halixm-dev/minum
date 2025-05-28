// lib/src/core/constants/app_strings.dart

class AppStrings {
  AppStrings._(); // Private constructor

  // --- General ---
  static const String appName = "Minum";
  static const String loading = "Loading...";
  static const String error = "Error";
  static const String success = "Success";
  static const String anErrorOccurred = "An unexpected error occurred. Please try again.";
  static const String tryAgain = "Try Again";
  static const String ok = "OK";
  static const String cancel = "Cancel";
  static const String save = "Save";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String add = "Add";
  static const String done = "Done";
  static const String skip = "Skip";
  static const String next = "Next";
  static const String previous = "Previous";
  static const String submit = "Submit";
  static const String search = "Search...";

  // --- Authentication ---
  static const String login = "Login";
  static const String logout = "Logout";
  static const String register = "Register";
  static const String email = "Email";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String forgotPassword = "Forgot Password?";
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String signUpHere = "Sign up here";
  static const String signInHere = "Sign in here";
  static const String loginWithGoogle = "Sign in with Google";
  static const String registerWithGoogle = "Sign up with Google";
  static const String passwordResetEmailSent = "Password reset email sent. Check your inbox.";
  static const String weakPassword = "Password is too weak.";
  static const String emailAlreadyInUse = "This email is already in use.";
  static const String invalidEmail = "Invalid email address.";
  static const String userNotFound = "User not found.";
  static const String wrongPassword = "Incorrect password.";
  static const String passwordsDoNotMatch = "Passwords do not match.";

  // --- Home Screen ---
  static const String homeTitle = "Today's Hydration";
  static const String dailyGoal = "Daily Goal";
  static const String consumed = "Consumed";
  static const String remaining = "Remaining";
  static const String addWater = "Add Water";
  static const String ml = "mL";
  static const String oz = "oz"; // If you support ounces
  static const String motivationalQuote = "Drink water, stay refreshed!"; // Example

  // --- Hydration Log ---
  static const String logWaterTitle = "Log Water Intake";
  static const String howMuchWater = "How much did you drink?";
  static const String enterAmount = "Enter amount";
  static const String customAmount = "Custom Amount";
  static const String quickAdd = "Quick Add";
  static const String waterLoggedSuccessfully = "Water intake logged!";

  // --- Progress & History ---
  static const String progressTitle = "Hydration Progress";
  static const String historyTitle = "Hydration History";
  static const String dailyAverage = "Daily Average";
  static const String weekly = "Weekly";
  static const String monthly = "Monthly";
  static const String yearly = "Yearly";
  static const String noDataAvailable = "No data available for this period.";

  // --- Settings ---
  static const String settingsTitle = "Settings";
  static const String profile = "Profile";
  static const String general = "General";
  static const String notifications = "Notifications";
  static const String reminders = "Reminders";
  static const String dailyWaterGoal = "Daily Water Goal";
  static const String measurementUnit = "Measurement Unit";
  static const String reminderFrequency = "Reminder Frequency";
  static const String reminderSound = "Reminder Sound";
  static const String enableReminders = "Enable Reminders";
  static const String theme = "Theme";
  static const String lightTheme = "Light";
  static const String darkTheme = "Dark";
  static const String systemTheme = "System Default";
  static const String account = "Account";
  static const String connectToGoogleFit = "Connect to Google Fit";
  static const String connectToHealthConnect = "Connect to Health Connect";
  static const String syncData = "Sync Data";
  static const String about = "About";
  static const String appVersion = "App Version";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsOfService = "Terms of Service";
  static const String rateApp = "Rate App";
  static const String shareApp = "Share App";

  // --- Notifications ---
  static const String reminderTitle = "Stay Hydrated!";
  static const String reminderBody = "Time to drink some water. Your body will thank you!";
  static const String smartReminderBody = "It's a good time for {amount}ml of water!";

  // --- Validation ---
  static const String fieldRequired = "This field is required.";
  static const String invalidNumber = "Please enter a valid number.";
  static const String positiveNumberRequired = "Please enter a positive number.";

  // --- Onboarding ---
  static const String welcomeToMinum = "Welcome to Minum!";
  static const String onboarding1Title = "Track Your Hydration";
  static const String onboarding1Desc = "Easily log your water intake and monitor your daily progress towards your hydration goals.";
  static const String onboarding2Title = "Smart Reminders";
  static const String onboarding2Desc = "Get personalized reminders to drink water throughout the day, keeping you on track.";
  static const String onboarding3Title = "Sync & Analyze";
  static const String onboarding3Desc = "Connect with health apps and see your hydration trends over time. Let's get started!";
  static const String getStarted = "Get Started";

  // --- Health Data ---
  static const String weight = "Weight";
  static const String kg = "kg";
  static const String lbs = "lbs";
  static const String activityLevel = "Activity Level";
  static const String sedentary = "Sedentary (Little or no exercise)";
  static const String light = "Light (Exercise 1-3 days/week)";
  static const String moderate = "Moderate (Exercise 3-5 days/week)";
  static const String active = "Active (Exercise 6-7 days/week)";
  static const String veryActive = "Very Active (Hard exercise 6-7 days/week)";
  static const String weather = "Weather"; // Conceptual
  static const String caloriesBurned = "Calories Burned"; // Conceptual
}
