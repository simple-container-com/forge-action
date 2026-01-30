#!/bin/bash
set -e

# Install required dependencies based on platform

echo "Installing dependencies for platform: $PLATFORM_TYPE"

# Common required tools
REQUIRED_TOOLS="curl git jq"

install_ubuntu() {
    echo "Installing dependencies on Ubuntu/Debian..."
    sudo apt-get update -qq
    sudo apt-get install -y curl git jq ca-certificates ripgrep
}

install_rhel() {
    echo "Installing dependencies on RHEL/CentOS..."
    sudo yum install -y curl git jq ca-certificates
    # ripgrep may need EPEL
    if ! command -v rg >/dev/null 2>&1; then
        echo "Warning: ripgrep not available, will install if possible"
        sudo yum install -y ripgrep 2>/dev/null || echo "ripgrep not available via yum"
    fi
}

install_alpine() {
    echo "Installing dependencies on Alpine..."
    sudo apk add --no-cache curl git jq ca-certificates bash ripgrep
}

install_macos() {
    echo "Installing dependencies on macOS..."
    # Most tools are pre-installed on GitHub Actions macOS runners
    if ! command -v jq >/dev/null 2>&1; then
        brew install jq
    fi
    if ! command -v rg >/dev/null 2>&1; then
        brew install ripgrep
    fi
}

install_windows() {
    echo "Installing dependencies on Windows..."
    # Windows support is limited, assume WSL or PowerShell environment
    echo "Warning: Windows support is experimental"
    choco install -y git curl jq 2>/dev/null || echo "Please ensure git, curl, and jq are installed"
}

# Check if required tools are already available
all_tools_available=true
for tool in $REQUIRED_TOOLS; do
    if ! command -v $tool >/dev/null 2>&1; then
        all_tools_available=false
        echo "Missing tool: $tool"
    fi
done

if [ "$all_tools_available" = "true" ]; then
    echo "✅ All required tools are already available"
    exit 0
fi

# Install dependencies based on platform
case "$PLATFORM_TYPE" in
    ubuntu)
        install_ubuntu
        ;;
    rhel)
        install_rhel
        ;;
    alpine)
        install_alpine
        ;;
    macos)
        install_macos
        ;;
    windows)
        install_windows
        ;;
    *)
        echo "Warning: Unknown platform type: $PLATFORM_TYPE"
        echo "Please ensure curl, git, and jq are installed"
        ;;
esac

# Verify installation
echo "Verifying dependency installation..."
for tool in $REQUIRED_TOOLS; do
    if command -v $tool >/dev/null 2>&1; then
        echo "  ✅ $tool"
    else
        echo "  ❌ $tool (missing)"
    fi
done

echo "✅ Dependency installation complete"
