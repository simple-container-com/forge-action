#!/bin/bash

# Cleanup script for Simple Forge workflow

echo "🧹 Cleaning up Simple Forge workspace..."

# Remove temporary work directory if it exists
if [ -n "$SIMPLE_FORGE_WORK_DIR" ] && [ -d "$SIMPLE_FORGE_WORK_DIR" ]; then
    echo "Removing work directory: $SIMPLE_FORGE_WORK_DIR"

    # Remove any sensitive files first
    if [ -f "$SIMPLE_FORGE_WORK_DIR/context.json" ]; then
        echo "Removing context.json"
        rm -f "$SIMPLE_FORGE_WORK_DIR/context.json"
    fi

    if [ -f "$SIMPLE_FORGE_WORK_DIR/conversation.txt" ]; then
        echo "Removing conversation.txt"
        rm -f "$SIMPLE_FORGE_WORK_DIR/conversation.txt"
    fi

    if [ -f "$SIMPLE_FORGE_WORK_DIR/prompt.txt" ]; then
        echo "Removing prompt.txt"
        rm -f "$SIMPLE_FORGE_WORK_DIR/prompt.txt"
    fi

    # Remove checksums and tarballs
    rm -f "$SIMPLE_FORGE_WORK_DIR/checksums.sha256"
    rm -f "$SIMPLE_FORGE_WORK_DIR/scripts.tar.gz"

    # Remove the entire work directory
    rm -rf "$SIMPLE_FORGE_WORK_DIR"
    echo "✅ Work directory removed"
else
    echo "No work directory to clean up"
fi

# Clean up any Docker containers if they were created
if command -v docker >/dev/null 2>&1; then
    echo "Checking for orphaned Docker containers..."
    ORPHANED=$(docker ps -a -q --filter "ancestor=simplecontainer/forge-action" 2>/dev/null || echo "")
    if [ -n "$ORPHANED" ]; then
        echo "Removing orphaned containers..."
        docker rm -f $ORPHANED 2>/dev/null || true
        echo "✅ Orphaned containers removed"
    fi
fi

echo "✅ Cleanup complete"
