#!/bin/bash

echo "🦀 Installing CRAMP..."

# Function to show error and exit
function error_exit {
    echo "❌ Error: $1" >&2
    exit 1
}

# Check for npm
command -v npm >/dev/null 2>&1 || error_exit "npm is required but not installed."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR || error_exit "Failed to create temporary directory"

# Clone the repository
echo "📦 Downloading CRAMP..."
git clone --depth 1 https://github.com/wansatya/cramp.git . || error_exit "Failed to download CRAMP"

# Install dependencies and build packages
echo "🔨 Building CRAMP..."
npm install || error_exit "Failed to install dependencies"
npm run build || error_exit "Failed to build packages"

# Install CLI globally
echo "🔧 Installing CRAMP CLI..."
npm install -g packages/cli || error_exit "Failed to install CLI"

# Create new project if name provided
if [ "$1" ]; then
    echo "🎯 Creating new project: $1"
    cramp create "$1" || error_exit "Failed to create project"
    cd "$1" || error_exit "Failed to enter project directory"
    npm install || error_exit "Failed to install project dependencies"
fi

# Cleanup
cd - > /dev/null
rm -rf $TEMP_DIR

echo "
✨ CRAMP installed successfully!

Quick start:
  cramp create my-app
  cd my-app
  npm run dev

For more information, visit: https://github.com/wansatya/cramp
"