#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Flutter environment setup..."

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install system dependencies
echo "Installing system dependencies (curl, git, unzip, xz-utils, zip, libglu1-mesa)..."
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download Flutter
FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.0-stable.tar.xz"
FLUTTER_TARBALL="flutter_linux_3.32.0-stable.tar.xz"
echo "Downloading Flutter SDK from $FLUTTER_SDK_URL..."
curl -O $FLUTTER_SDK_URL

# Extract Flutter
echo "Extracting Flutter SDK to ./flutter..."
tar xf $FLUTTER_TARBALL

# Add Flutter to PATH for the current session
echo "Adding Flutter to PATH for the current session..."
export PATH="$PATH:`pwd`/flutter/bin"
echo "Flutter PATH set for current session. To make it permanent, add the following line to your ~/.bashrc or ~/.zshrc:"
echo 'export PATH="$PATH:'`pwd`'/flutter/bin"'


# Enable Flutter web
echo "Enabling Flutter web..."
`pwd`/flutter/bin/flutter config --enable-web

# Run Flutter doctor
echo "Running Flutter doctor..."
`pwd`/flutter/bin/flutter doctor

# Placeholder for getting project dependencies
echo "---------------------------------------------------------------------"
echo "Flutter setup complete."
echo "To get project-specific dependencies, navigate to your Flutter project directory and run:"
echo "flutter pub get"
echo "---------------------------------------------------------------------"
