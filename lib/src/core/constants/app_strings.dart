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

  // --- Home / Hydration View ---
  /// Label for the next reminder card.
  static const String nextReminder = "Next Reminder:";

  /// Title for today's log section.
  static const String todaysLog = "Today's Log";

  /// Title prefix for a log on a specific date.
  static const String logFor = "Log for";

  /// Message when no water has been logged.
  static const String noWaterLoggedYet = "No water logged yet for today.";

  /// Hint to tap the (+) button to add a drink.
  static const String tapToAddFirstDrink =
      "Tap the (+) button to add your first drink!";

  /// Loading message for user data.
  static const String loadingUserData = "Loading user data...";

  /// Label for "Your Daily Goal" on progress card.
  static const String yourDailyGoal = "Your Daily Goal";

  /// Suffix for "left" (e.g., "500 mL left").
  static const String left = "left";

  /// Suffix for "completed" percentage (e.g., "75% completed").
  static const String completed = "completed";

  /// Text for "added!" snackbar (e.g., "250 mL added!").
  static const String added = "added!";

  // --- Hydration Entry Sources ---
  /// Label for a manual entry source.
  static const String manualEntry = "Manual Entry";

  /// Label for a Google Fit source.
  static const String googleFit = "Google Fit";

  /// Label for a Health Connect source.
  static const String healthConnect = "Health Connect";

  // --- History Screen ---
  /// Label for "Daily Totals" section heading.
  static const String dailyTotals = "Daily Totals";

  /// Label for "Weekly Totals" section heading.
  static const String weeklyTotals = "Weekly Totals";

  /// Message shown when not enough data to plot.
  static const String notEnoughData =
      "Not enough data to plot for this period.";

  /// Label for login to sync prompt.
  static const String loginToSync = "Login to Sync";

  /// Prompt text for syncing data after login.
  static const String loginToSyncPrompt =
      "You have local data. Log in to sync and backup your history!";

  /// Prompt for logged out empty state.
  static const String noLoggedOutHistory =
      "Log some water to see your history here. Log in to sync across devices!";

  /// Prompt for logged in empty state.
  static const String noLoggedInHistory =
      "No hydration logs found for the selected period.";

  // --- Settings Screen ---
  /// Section title for integrations.
  static const String integrations = "Integrations";

  /// Label for Google Fit Sync toggle.
  static const String googleFitSync = "Google Fit Sync";

  /// Subtitle for Google Fit Sync toggle.
  static const String syncWaterIntakeData = "Sync water intake data";

  /// Label for favorite volumes setting.
  static const String favoriteVolumes = "Favorite Volumes";

  /// Subtitle for favorite volumes setting.
  static const String customizeQuickAdd = "Customize quick add buttons";

  /// Subtitle for profile setting.
  static const String managePersonalDetails = "Manage your personal details";

  /// Snackbar message after saving reminder settings.
  static const String reminderSettingsSaved = "Reminder settings saved!";

  /// Snackbar message after updating measurement unit.
  static const String measurementUnitUpdated = "Measurement unit updated!";

  /// Snackbar message after updating favorite volumes.
  static const String favoriteVolumesUpdated = "Favorite volumes updated!";

  /// Snackbar message for Google Fit enabled.
  static const String googleFitEnabled = "Google Fit Sync enabled!";

  /// Snackbar message for Google Fit disabled.
  static const String googleFitDisabled = "Google Fit Sync disabled.";

  /// Snackbar message for Google Fit permissions denied.
  static const String googleFitPermissionsDenied =
      "Google Fit permissions denied.";

  /// Snackbar message for minimum interval.
  static const String minimumIntervalMessage =
      "Minimum reminder interval is 15 minutes. Setting to 15m.";

  /// Help text for selecting reminder start time.
  static const String selectReminderStartTime = "Select Reminder Start Time";

  /// Help text for selecting reminder end time.
  static const String selectReminderEndTime = "Select Reminder End Time";

  /// Error for start time before end time.
  static const String startTimeBeforeEndTime =
      "Start time must be before end time for a same-day schedule.";

  /// Error for end time after start time.
  static const String endTimeAfterStartTime =
      "End time must be after start time for a same-day schedule.";

  /// Title for select interval duration dialog.
  static const String selectIntervalDuration = "Select Reminder Interval";

  /// Label for minutes unit.
  static const String minutes = "minutes";

  /// Label for hour(s) unit.
  static const String hour = "hour";

  /// Label for hours unit.
  static const String hours = "hours";

  /// Label for hour abbreviation.
  static const String hrAbbr = "hr";

  /// Label for minute abbreviation.
  static const String minAbbr = "min";

  // --- Add/Edit Water Log Screen ---
  /// Title for editing a water log.
  static const String editWaterLog = "Edit Water Log";

  /// Tooltip for deleting a log entry.
  static const String deleteLog = "Delete Log";

  /// Label for amount field.
  static const String amount = "Amount";

  /// Label for date & time field.
  static const String dateAndTime = "Date & Time";

  /// Label for notes field.
  static const String notesOptional = "Notes (Optional)";

  /// Placeholder for notes input.
  static const String addANote = "Add a note";

  /// Hint text for notes.
  static const String notesHint = "e.g., After workout";

  /// Button text for updating a log.
  static const String updateLog = "Update Log";

  /// Loading message for logging water.
  static const String loggingWater = "Logging water...";

  /// Loading message for updating a log.
  static const String updatingLog = "Updating log...";

  /// Loading message for deleting a log.
  static const String deletingLog = "Deleting log...";

  /// Confirmation message for deleting a log.
  static const String deleteLogConfirmation =
      "Are you sure you want to delete this log entry?";

  /// Error message for invalid amount.
  static const String pleaseEnterValidAmount = "Please enter a valid amount.";

  /// Amount hint text (e.g., "e.g., 250 or 8").
  static const String amountHint = "e.g., 250 or 8";

  // --- Welcome / Login Screen ---
  /// Subtitle for the welcome screen.
  static const String personalHydrationCompanion =
      "Your personal hydration companion.";

  /// Button text to start now (guest mode).
  static const String startNow = "Start Now";

  /// Subtitle for the login screen.
  static const String stayHydratedEffortlessly =
      "Stay hydrated, effortlessly.";

  /// Text for skip login button.
  static const String skipLoginForNow = "Skip login for now";

  /// Hint about logging in later.
  static const String loginLaterHint =
      "You can log in later from settings to sync your data.";

  /// Guest mode limitations disclaimer.
  static const String guestModeLimitations =
      "Guest mode: Data is stored locally only and won't sync across devices.";

  // --- Swipe Delete ---
  /// Message shown after deleting an entry (with undo).
  static const String entryDeleted = "Entry deleted";

  /// Label for the undo action.
  static const String undo = "Undo";

  // --- Logout ---
  /// Confirmation message for logging out.
  static const String logoutConfirmation =
      "Are you sure you want to log out?";

  /// Tooltip for FAB on home.
  static const String logWaterIntakeTooltip = "Log Water Intake";

  // --- Formats ---
  /// Format label for "Week N" (used in charts).
  static String weekNumber(int n) => "Week $n";

  /// Format label for "Edit Favorite Volumes (unit)".
  static String editFavoriteVolumesTitle(String unitName) =>
      "Edit Favorite Volumes ($unitName)";
}
