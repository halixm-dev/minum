# Minum - Smart Water Reminder App

Stay hydrated and on track with Minum, your smart water reminder app! Sync with your Google Account, Google Fit, and Health Connect to automatically calculate your ideal intake using weather, calories burned, and weight data. Manually or automatically set targets, log and manage your water intake, track daily progress, and view long-term hydration trends and calendar. Customize reminders and even input health data manually—your hydration, your way.

## Features

-   **Smart Intake Calculation:** Integrates with health data (weight, age, activity level), and weather conditions to suggest an ideal daily water intake.
-   **Firebase Authentication:** Secure login and registration using Google Sign-In.
-   **Manual & Automatic Targets:** Set your daily hydration goals manually or use the app's smart suggestion.
-   **Intake Logging:** Easily log water consumption with quick-add buttons for your favorite volumes.
-   **Progress Tracking:** Monitor your daily and historical hydration levels with an interactive chart.
-   **Customizable Reminders:** Get timely notifications to drink water throughout the day.
-   **Health Data Input:** Manually add relevant health information to improve the accuracy of your suggested goal.
-   **Responsive UI:** Material Design interface that adapts to various screen sizes.
-   **State Management:** Using Provider for simple and effective state management.
-   **Offline Support:** All your data is saved locally and synced with the cloud when you're online.

## Project Structure

```
minum/
├── android/            # Android specific files
├── ios/                # iOS specific files
├── lib/                # Main application Dart code
│   ├── main.dart       # App entry point
│   ├── firebase_options.dart # Firebase configuration
│   ├── src/            # Core application logic
│       ├── app.dart    # MaterialApp and routing setup
│       ├── core/       # Constants, themes, utils
│       ├── data/       # Models, repositories, API providers
│       ├── presentation/ # UI (screens, widgets) and state management (providers)
│       ├── services/   # Business logic services
│       └── navigation/ # Navigation logic
├── linux/              # Linux specific files
├── macos/              # macOS specific files
├── web/                # Web specific files
├── windows/            # Windows specific files
├── .gitignore          # Specifies intentionally untracked files that Git should ignore
├── analysis_options.yaml # Dart analyzer configuration
├── pubspec.yaml        # Project dependencies and metadata
├── pubspec.lock        # Automatically generated file specifying exact dependency versions
└── README.md           # This file
```

## Prerequisites

-   Flutter SDK (version 3.0.0 or higher)
-   Dart SDK (version 3.0.0 or higher)
-   An IDE like Android Studio or VS Code with Flutter plugins.
-   Firebase account for Firebase Authentication and Firestore.
-   (Optional) Access to Google Fit and Health Connect APIs if you plan to implement full integration.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository_url>
cd minum
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

This project uses Firebase for authentication and potentially for data storage.

**IMPORTANT:** You need to configure Firebase for your project.

1.  **Create a Firebase Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Register your app:**
    *   Add an Android app to your Firebase project:
        *   Package name: `com.halixm.minum`
        *   Follow the instructions to download `google-services.json` and place it in `android/app/`.
    *   Add an iOS app to your Firebase project:
        *   Bundle ID: `com.halixm.minum`
        *   Follow the instructions to download `GoogleService-Info.plist` and place it in `ios/Runner/`.
3.  **Enable Authentication Methods:** In the Firebase console, go to "Authentication" -> "Sign-in method" and enable "Google".
    *   **For Google Sign-In on Android:** You'll need to add your SHA-1 fingerprint to the Firebase project settings. You can get it by running `cd android && ./gradlew signingReport`.
4.  **Initialize Firebase in Flutter:**
    *   Install the Firebase CLI: `npm install -g firebase-tools` (or other methods from Firebase docs).
    *   Login to Firebase: `firebase login`.
    *   Install FlutterFire CLI: `dart pub global activate flutterfire_cli`.
    *   Configure your project: `flutterfire configure`. This will autogenerate the `lib/firebase_options.dart` file. Make sure to select the Firebase project you created.

    *If `flutterfire configure` gives issues, you might need to manually create `lib/firebase_options.dart` based on the Firebase project settings (less recommended).*

### 4. (Conceptual) Google Fit & Health Connect Setup

Actual integration with Google Fit and Health Connect requires:
1.  Setting up projects in Google Cloud Console.
2.  Requesting necessary OAuth scopes.
3.  Handling API calls, likely through platform channels or dedicated plugins that manage native SDKs.
4.  Complying with Google's data privacy and API usage policies.

For this boilerplate, these services are mocked. To implement them fully, you would need to:
-   Find or create Flutter plugins that interface with the native Google Fit and Health Connect SDKs.
-   Add necessary permissions to `AndroidManifest.xml` (Android) and `Info.plist` (iOS).
-   Implement OAuth 2.0 flows for authorization.

### 5. (Optional) API Keys for Weather

If you integrate a weather API:
1.  Sign up for a weather API service (e.g., OpenWeatherMap).
2.  Obtain an API key.
3.  Store this key securely, preferably using environment variables or a configuration file not committed to version control. For this project, you might place it in a constants file initially, but for production, use a more secure method.
    *   Example: `lib/src/core/constants/api_keys.dart` (ensure this file is in `.gitignore` if it contains sensitive keys).

### 6. Run the App

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device_id>
```

## Building for Release

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```
Ensure you have set up signing configurations for Android in `android/app/build.gradle`.

### iOS

```bash
flutter build ios --release
```
Ensure you have set up your Apple Developer account and signing certificates in Xcode.

## Testing Strategy

This project includes a sample widget test in `test/widget_test.dart`.

-   **Widget Tests:** These test individual Flutter widgets. You can run widget tests using:
    ```bash
    flutter test test/widget_test.dart
    ```
    To run all tests in the `test` directory:
    ```bash
    flutter test
    ```
-   **Further Testing:** As the project grows, you can add:
    -   **Unit Tests:** For testing individual functions or classes. Typically placed in a `test/unit/` directory.
    -   **Integration Tests:** For testing complete app flows. Typically placed in an `integration_test/` directory using the `integration_test` package.

## CI/CD with GitHub Actions

CI/CD (Continuous Integration/Continuous Delivery) can be set up for this project using services like GitHub Actions. This would typically involve creating a workflow file in a `.github/workflows/` directory to automate testing, building, and deployment.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
