#!/bin/bash
set -e

# Detect platform and set environment variables

echo "Detecting platform..."

# Detect OS type
case "$OSTYPE" in
    linux*)
        PLATFORM_OS="linux"
        if command -v apt-get >/dev/null 2>&1; then
            PLATFORM_TYPE="ubuntu"
            PACKAGE_MANAGER="apt-get"
        elif command -v yum >/dev/null 2>&1; then
            PLATFORM_TYPE="rhel"
            PACKAGE_MANAGER="yum"
        elif command -v apk >/dev/null 2>&1; then
            PLATFORM_TYPE="alpine"
            PACKAGE_MANAGER="apk"
        else
            PLATFORM_TYPE="linux-unknown"
            PACKAGE_MANAGER="unknown"
        fi
        ;;
    darwin*)
        PLATFORM_OS="macos"
        PLATFORM_TYPE="macos"
        PACKAGE_MANAGER="brew"
        ;;
    msys*|cygwin*|mingw*)
        PLATFORM_OS="windows"
        PLATFORM_TYPE="windows"
        PACKAGE_MANAGER="choco"
        ;;
    *)
        PLATFORM_OS="unknown"
        PLATFORM_TYPE="unknown"
        PACKAGE_MANAGER="unknown"
        ;;
esac

# Check for Docker availability
if command -v docker >/dev/null 2>&1; then
    DOCKER_AVAILABLE="true"
else
    DOCKER_AVAILABLE="false"
fi

# Export to GitHub environment
echo "PLATFORM_OS=$PLATFORM_OS" >> $GITHUB_ENV
echo "PLATFORM_TYPE=$PLATFORM_TYPE" >> $GITHUB_ENV
echo "PACKAGE_MANAGER=$PACKAGE_MANAGER" >> $GITHUB_ENV
echo "DOCKER_AVAILABLE=$DOCKER_AVAILABLE" >> $GITHUB_ENV

echo "✅ Platform detected:"
echo "  OS: $PLATFORM_OS"
echo "  Type: $PLATFORM_TYPE"
echo "  Package Manager: $PACKAGE_MANAGER"
echo "  Docker Available: $DOCKER_AVAILABLE"
