#!/bin/bash
set -e

# Docker-only script acquisition

SCRIPT_VERSION="$1"

echo "Acquiring workflow scripts (version: $SCRIPT_VERSION)..."

# Determine script version
if [ "$SCRIPT_VERSION" = "latest" ] || [ -z "$SCRIPT_VERSION" ]; then
    echo "Resolving latest version..."
    SCRIPT_VERSION=$(curl -s https://api.github.com/repos/simple-container-com/simple-forge-action/releases/latest | jq -r .tag_name 2>/dev/null || echo "")
    if [ -z "$SCRIPT_VERSION" ] || [ "$SCRIPT_VERSION" = "null" ]; then
        echo "Warning: Could not determine latest version, using 'main' branch"
        SCRIPT_VERSION="main"
    fi
    echo "Resolved version: $SCRIPT_VERSION"
fi

# Create scripts directory
SCRIPTS_DIR="$SIMPLE_FORGE_WORK_DIR/scripts"
mkdir -p "$SCRIPTS_DIR"

# Verify Docker is available
if [ "$DOCKER_AVAILABLE" != "true" ]; then
    echo "❌ Error: Docker is required for script acquisition"
    exit 1
fi

echo "Extracting scripts from Docker image..."

# Determine Docker image tag
DOCKER_TAG="$SCRIPT_VERSION"
if [ "$DOCKER_TAG" = "main" ]; then
    DOCKER_TAG="latest"
fi

# Pull Docker image
if ! docker pull "simplecontainer/forge-action:$DOCKER_TAG"; then
    echo "❌ Error: Failed to pull Docker image"
    exit 1
fi

echo "Docker image pulled successfully"

# Create container and extract scripts
CONTAINER_ID=$(docker create "simplecontainer/forge-action:$DOCKER_TAG" 2>/dev/null || echo "")

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ Error: Failed to create Docker container"
    exit 1
fi

# Extract scripts from container
if docker cp "$CONTAINER_ID:/app/scripts" "$SIMPLE_FORGE_WORK_DIR/"; then
    docker rm "$CONTAINER_ID" >/dev/null 2>&1 || true
    chmod +x "$SCRIPTS_DIR"/*.sh
    echo "✅ Scripts extracted from Docker image successfully"
else
    echo "❌ Error: Failed to copy scripts from Docker container"
    docker rm "$CONTAINER_ID" >/dev/null 2>&1 || true
    exit 1
fi

# Verify scripts are available
if [ ! -f "$SCRIPTS_DIR/setup-claude.sh" ] || [ ! -f "$SCRIPTS_DIR/execute-claude.sh" ]; then
    echo "❌ Error: Critical scripts are missing!"
    ls -la "$SCRIPTS_DIR" || echo "Scripts directory is empty"
    exit 1
fi

echo "✅ Script acquisition complete"
ls -la "$SCRIPTS_DIR"
