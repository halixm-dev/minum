# Agent Instructions for Minum

This document provides instructions for AI agents working on the Minum codebase.

## Project Overview

Minum is a smart water reminder app that helps users stay hydrated. It syncs with Google Account, Google Fit, and Health Connect to calculate ideal water intake based on weather, calories burned, and weight data.

## Key Technologies

-   **Frontend:** Flutter
-   **State Management:** Provider
-   **Backend:** Firebase (Authentication, Firestore)
-   **API:** Dio (for network requests)

## Getting Started

### Prerequisites

-   Flutter SDK (version 3.0.0 or higher)
-   Dart SDK (version 3.0.0 or higher)
-   Firebase account
-   (Optional) Google Fit and Health Connect APIs access

### Setup

1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Firebase Setup:**
    -   Place `google-services.json` in `android/app/`.
    -   Place `GoogleService-Info.plist` in `ios/Runner/`.
    -   Enable "Email/Password" and "Google" authentication in the Firebase console.
    -   For Google Sign-In on Android, add your SHA-1 fingerprint to the Firebase project settings.
    -   Run `flutterfire configure` to generate `lib/firebase_options.dart`.

## Development Guidelines

### Project Structure

The target project structure is as follows:

```
minum/
├── lib/
│   ├── src/
│   │   ├── app.dart
│   │   ├── core/
│   │   ├── data/
│   │   ├── presentation/
│   │   ├── services/
│   │   └── navigation/
│   └── config/
```

-   **`main.dart`:** App entry point.
-   **`src/app.dart`:** MaterialApp and routing setup.
-   **`src/core/`:** Constants, themes, utils.
-   **`src/data/`:** Models, repositories, API providers.
-   **`src/presentation/`:** UI (screens, widgets) and state management (providers).
-   **`src/services/`:** Business logic services.
-   **`src/navigation/`:** Navigation logic.
-   **`config/`:** Firebase configuration.

### Testing

-   Run all tests with:
    ```bash
    flutter test
    ```
-   Widget tests are in `test/`.
-   Unit tests should be placed in `test/unit/`.
-   Integration tests should be placed in `integration_test/`.

### Building for Release

-   **Android:**
    ```bash
    flutter build apk --release
    flutter build appbundle --release
    ```
-   **iOS:**
    ```bash
    flutter build ios --release
    ```

### Committing and Contributing

-   Pull requests are welcome.
-   Open an issue to discuss major changes.
-   Update tests as appropriate.
-   Follow standard git commit message conventions.
-   The `AGENTS.md` file is a guide for the agent's interactions with the repository. Do not modify the file.
-   The agent is responsible for creating and maintaining its own `AGENTS.md` file.
-   The agent is expected to follow the instructions in the `AGENTS.md` file.
-   The agent is expected to use the tools provided to it to complete the task.
-   The agent is expected to be resourceful and to use the tools at its disposal to accomplish its goals.
-   The agent is expected to be a helpful software engineer for the user.
-   The agent is expected to understand the problem, research the scope of work and the codebase, make a plan, and begin working on changes (and verify them as you go) using the tools available to you.
-   The agent is expected to always verify its work.
-   The agent is expected to edit source, not artifacts.
-   The agent is expected to practice proactive testing.
-   The agent is expected to diagnose before changing the environment.
-   The agent is expected to strive to solve problems autonomously.
-   The agent is expected to ask for help using `request_user_input` in the following situations:
    1) The user's request is ambiguous and you need clarification.
    2) You have tried multiple approaches to solve a problem and are still stuck.
    3) You need to make a decision that would significantly alter the scope of the original request.
-   The agent is expected to remember that it is resourceful, and will use the tools available to it to perform its work and subtasks.

### Agent Instructions

1.  **Understand the Goal:** Read the user's request carefully to understand the desired outcome.
2.  **Explore the Codebase:** Use `ls` and `read_files` to understand the project structure and existing code.
3.  **Formulate a Plan:** Create a step-by-step plan using `set_plan`. The plan should include:
    -   What you will do.
    -   Where you will make changes.
    -   How you will verify the changes.
4.  **Execute the Plan:** Follow your plan, using the available tools to modify the code.
5.  **Verify Your Work:** After each change, use `read_files` or `flutter test` to ensure the code is correct.
6.  **Submit:** Once the task is complete and verified, use `submit` to create a pull request.
