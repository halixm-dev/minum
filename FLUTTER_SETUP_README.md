# Flutter Environment Setup Script

This repository contains a script to automate the setup of a Flutter development environment on Linux.

## Setup Script

The main script is `setup_flutter_env.sh`.

### Usage

1.  **Clone the repository or download the script:**
    If you've cloned the repository, navigate to its directory. If you've only downloaded `setup_flutter_env.sh`, make sure you're in the directory where you saved it.

2.  **Run the script:**
    Open your terminal and execute the script using the following command:
    ```bash
    ./setup_flutter_env.sh
    ```
    The script will:
    *   Update your system's package lists.
    *   Install necessary dependencies (like `curl`, `git`, `unzip`, etc.).
    *   Download the Flutter SDK (version 3.32.0-stable for Linux).
    *   Extract the Flutter SDK into a `flutter` directory in the current location.
    *   Temporarily add the Flutter `bin` directory to your system's PATH for the current terminal session.
    *   Enable Flutter web development.
    *   Run `flutter doctor` to verify the setup.

3.  **Permanent PATH Configuration (Important):**
    The script will print instructions on how to make the Flutter PATH modification permanent. This usually involves adding a line like `export PATH="$PATH:/path/to/your/flutter/bin"` to your shell's configuration file (e.g., `~/.bashrc`, `~/.zshrc`). Follow the instructions provided by the script to ensure Flutter commands are available in all future terminal sessions.

    For example, if you ran the script from `/home/user/dev/flutter_setup`, the line to add would be:
    `export PATH="$PATH:/home/user/dev/flutter_setup/flutter/bin"`

4.  **Project Dependencies:**
    After running the setup script, navigate to your specific Flutter project directory and run `flutter pub get` to fetch project-specific dependencies.

## Note

*   The script uses `sudo` for package installation, so it may ask for your password.
*   The Flutter SDK will be downloaded and extracted into a `flutter` subdirectory within the directory where you run the script.
