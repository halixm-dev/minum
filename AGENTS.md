# Agent Instructions for Minum

This document provides instructions for AI agents working on the Minum codebase.

## Project Overview

Minum is a smart water reminder app that helps users stay hydrated. It syncs with Google Account, Google Fit, and Health Connect to calculate ideal water intake based on weather, calories burned, and weight data.

## Tech Stack

-   **Frontend:** Flutter (SDK >=3.5.0)
-   **State Management:** Provider
-   **Backend:** Firebase (Authentication, Firestore)
-   **Networking:** Dio
-   **Local Storage:** Shared Preferences, Sqflite
-   **UI/Design:**
    -   `flutter_screenutil` for responsive design.
    -   `google_fonts` for typography.
    -   `material_symbols_icons` and `cupertino_icons`.
-   **Charts:** `fl_chart`
-   **Notifications:** `awesome_notifications`

## Project Structure

The project follows a clean architecture approach:

```
minum/
├── lib/
│   ├── src/
│   │   ├── app.dart           # MaterialApp and routing setup
│   │   ├── core/              # Constants (AppStrings), themes, utils
│   │   ├── data/              # Models, repositories, API providers
│   │   ├── presentation/      # UI (screens, widgets) and state management (providers)
│   │   ├── services/          # Business logic services
│   │   └── navigation/        # Navigation logic
│   ├── config/                # Configuration files (e.g., Firebase)
│   ├── main.dart              # App entry point
│   └── firebase_options.dart  # Firebase configuration
```

## Development Guidelines

### Coding Standards

1.  **Strings:** Always use `AppStrings` class in `lib/src/core/constants/app_strings.dart` for UI text. Do not hardcode strings in widgets.
2.  **Responsiveness:** Use `flutter_screenutil` extensions (e.g., `.w`, `.h`, `.sp`) for sizing to ensure the UI adapts to different screen sizes.
3.  **State Management:** Use `Provider` for managing state. Avoid `setState` for complex state logic.
4.  **Async Operations:** Use `Dio` for network requests. Handle errors gracefully.

### Testing

-   **Run Tests:** `flutter test`
-   **Widget Tests:** Place in `test/`
-   **Unit Tests:** Place in `test/unit/`

### Building

-   **Android:** `flutter build apk --release`
-   **iOS:** `flutter build ios --release`

## Agent Workflow

1.  **Understand the Goal:** Read the user's request carefully. If ambiguous, use `notify_user` to ask for clarification.
2.  **Explore:** Use `list_dir` and `view_file` to understand the relevant parts of the codebase.
3.  **Plan:**
    -   Create a `task.md` or `implementation_plan.md` if the task is complex.
    -   Use `task_boundary` to define the current task and status.
4.  **Execute:**
    -   Make changes using `replace_file_content` or `multi_replace_file_content`.
    -   **Always** verify changes.
5.  **Verify:**
    -   Run tests using `run_command`.
    -   If UI changes are made, verify that they match the design guidelines.
6.  **Communicate:**
    -   Use `task_boundary` to keep the user updated on progress.
    -   Use `notify_user` when the task is complete or if you need user input.

### Key Behaviors

-   **Be Proactive:** Fix obvious bugs or improvements you see while working on the main task, but don't deviate significantly without asking.
-   **Be Resourceful:** Use the tools available. If a tool fails, try to understand why or use an alternative approach.
-   **Edit Source, Not Artifacts:** Focus on `lib/` and `test/` for code changes.
-   **Verify First:** Before declaring a task done, ensure the code compiles and tests pass (if applicable).
