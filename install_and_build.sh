#!/bin/bash
# install_flutter.sh - Install Flutter for Vercel build

set -e

echo "🚀 Installing Flutter for Vercel..."

# Install Flutter
export FLUTTER_VERSION=3.0.0
export FLUTTER_HOME=/tmp/flutter
export PATH="$FLUTTER_HOME/bin:$PATH"

# Download Flutter
cd /tmp
git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Precache
flutter precache --web

# Accept licenses
yes | flutter doctor --android-licenses || true

echo "✅ Flutter installed successfully!"
flutter --version

# Navigate back to project
cd /vercel/path0

# Build the app
echo "🏗️ Building Flutter web app..."
flutter build web --release

echo "✅ Build complete!"

