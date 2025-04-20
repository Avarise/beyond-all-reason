#!/bin/bash

# Path setup
APPIMAGE_NAME="Launcher.AppImage"
DATA_DIR="/opt/bar/data"
INSTALL_DIR="/opt/bar"
NO_NVIDIA=false

# Parse arguments
for arg in "$@"; do
    if [[ "$arg" == "--no-nvidia" ]]; then
        NO_NVIDIA=true
        shift
    fi
done

# Enable NVIDIA variables unless --no-nvidia is used
if [ "$NO_NVIDIA" = false ]; then
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
fi

# Find AppImage in current directory
if ! ls ./*.AppImage &>/dev/null; then
    echo "No .AppImage found, attempting to fetch the latest release..."

    API_URL="https://api.github.com/repos/beyond-all-reason/BYAR-Chobby/releases/latest"
    DOWNLOAD_URL=$(curl -s "$API_URL" | grep browser_download_url | grep AppImage | cut -d '"' -f 4)

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Could not find AppImage download URL from GitHub API."
        exit 1
    fi

    echo "Downloading AppImage from: $DOWNLOAD_URL"
    curl -L -o "$APPIMAGE_NAME" "$DOWNLOAD_URL"
    chmod +x "$APPIMAGE_NAME"
else
    APPIMAGE_NAME=$(ls ./*.AppImage | head -n 1)
    echo "Found AppImage: $APPIMAGE_NAME"
fi

# Ensure data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "Creating data directory at $DATA_DIR"
    mkdir -p "$DATA_DIR"
fi

# Run the AppImage
echo "Launching $APPIMAGE_NAME with write path $DATA_DIR"
exec ./"$APPIMAGE_NAME" --write-path "$DATA_DIR" "$@"
