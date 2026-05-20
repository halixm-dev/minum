# Minum - Smart Water Reminder App 💧

![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.5.0-blue)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Stay hydrated and on track with Minum, your smart water reminder app! Sync with your Google Account, Google Fit, and Health Connect to automatically calculate your ideal intake using weather, calories burned, and weight data. Manually or automatically set targets, log and manage your water intake, track daily progress, and view long-term hydration trends.

> **🤖 Note for Developers & AI Agents**: Start with [AGENTS.md](./agents/AGENTS.md) for project architecture, coding standards, and domain guides.

## ✨ Features

- **Smart Intake Calculation:** Integrates with health data (weight, age, activity level) and weather conditions to suggest an ideal daily water intake.
- **Offline-First Sync:** All data is saved locally (`sqflite`) and synced with the cloud (Firestore) when online.
- **Firebase Authentication:** Secure login and registration using Google Sign-In.
- **Manual & Automatic Targets:** Set your daily hydration goals manually or use the app's smart suggestion.
- **Progress Tracking:** Monitor your daily and historical hydration levels with interactive charts.
- **Customizable Reminders:** Get timely local notifications to drink water throughout the day.
- **Material You Design:** Beautiful, responsive UI using Material 3 dynamic colors that adapt to the user's system preferences.

## 🛠 Tech Stack

- **Framework:** Flutter (>=3.5.0)
- **State Management:** `flutter_bloc` (BLoC/Cubit) & `provider` (DI / App State)
- **Backend:** Firebase (Auth, Cloud Firestore)
- **Local Storage:** `sqflite`, `shared_preferences`
- **Architecture:** Feature-first modules with BLoC and Repository pattern

*For a full architectural overview, see [AGENTS.md](./agents/AGENTS.md).*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version `>=3.5.0 <4.0.0`)
- Dart SDK
- IDE: VS Code, Android Studio, or IntelliJ
- Firebase account

### 1. Clone & Install

```bash
git clone <repository_url>
cd minum
flutter pub get
```

### 2. Firebase Setup

This project requires Firebase Authentication (Google Sign-In) and Cloud Firestore.

1. **Create Project**: Go to the [Firebase Console](https://console.firebase.google.com/) and create `halixm-minum` (or your own project).
2. **Enable Services**:
   - **Authentication** -> Enable **Google** sign-in method.
   - **Firestore Database** -> Create database.
3. **Configure FlutterFire**:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=halixm-minum
   ```
   *This will generate `lib/firebase_options.dart`.*
4. **Android Google Sign-In**: Add your debug SHA-1 fingerprint to the Firebase Android app settings.
   ```bash
   cd android && ./gradlew signingReport
   ```

### 3. Google Fit & Health Connect (Optional)

Actual integration requires:
1. Setting up projects in Google Cloud Console.
2. Requesting necessary OAuth scopes and health permissions.
3. Adding necessary permissions to `AndroidManifest.xml` (Android) and `Info.plist` (iOS).

### 4. Run the App

```bash
flutter run
```

## 🧪 Testing

The project uses a mix of unit, widget, and integration tests.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

*For detailed testing guidelines, refer to `.agent/rules/test-guide.md`.*

## 📦 Building for Release

**Android**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 🤝 Contributing

We follow a structured development workflow. Please refer to our agent rules in `.agent/rules/` for coding standards, branch strategies, and PR guidelines.

1. Create a feature branch (`git checkout -b feature/my-feature`)
2. Commit changes (`git commit -m "feat: my feature"`)
3. Push to branch (`git push origin feature/my-feature`)
4. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
