#!/bin/bash
# Alternative Ollama installation script (if setup.sh fails)
# Direct binary download from DioNanos/ollama-termux releases

set -e

echo "Installing Ollama directly from prebuilt releases..."

# Fetch latest release
echo "Fetching latest Ollama-Termux release..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/DioNanos/ollama-termux/releases/latest)
TAG=$(echo $RELEASE_INFO | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)

if [ -z "$TAG" ]; then
    echo "Error: Could not fetch latest release"
    echo "Visit: https://github.com/DioNanos/ollama-termux/releases"
    exit 1
fi

echo "Latest release: $TAG"

# Download ARM64 binary
DOWNLOAD_URL="https://github.com/DioNanos/ollama-termux/releases/download/${TAG}/ollama-android-arm64"

echo "Downloading from: $DOWNLOAD_URL"
curl -L -o /tmp/ollama $DOWNLOAD_URL

if [ -f /tmp/ollama ]; then
    chmod +x /tmp/ollama
    mv /tmp/ollama $PREFIX/bin/ollama
    echo "✓ Ollama installed to: $PREFIX/bin/ollama"
    ollama version
else
    echo "Download failed"
    exit 1
fi
