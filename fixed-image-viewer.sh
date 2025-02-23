#!/usr/bin/env bash
# <xbar.title>Fixed Image Viewer</xbar.title>
# <xbar.version>1.1</xbar.version>
# <xbar.author>Harshal Shinde</xbar.author>
# <xbar.desc>Displays a selected image from Finder, converting and resizing if necessary.</xbar.desc>
# <xbar.dependencies>exiftool, sips, base64, osascript</xbar.dependencies>

# Configuration
IMAGE_STORAGE="$HOME/.xbar_selected_image.txt"  # Persistent storage for the selected image
TEMP_FOLDER="$HOME/.xbar_image_cache"           # Hidden folder for temp processing
TEMP_IMAGE="$TEMP_FOLDER/temp.jpg"
ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJtMjY0LTk2LTM2LTM2di0xNTZIOTZ2LTcybDQ4LTcydi0xMjBIOTZ2LTcyaDMzNnY3MmgtNDh2MTIwbDQ4IDcydjcySDMwMHYxNTZsLTM2IDM2Wm0yMTYtOTZ2LTcyaDMxMnYtNDMySDk2cTAtMzAgMjEuMTUtNTFUMTY4LTc2OGg2MjRxMzMgMCA1Mi41IDE5LjVUODY0LTY5NnY0MzJxMCAzMy0xOS41IDUyLjVUNzkyLTE5Mkg0ODBaTTE4Mi0zNjBoMTY0bC0zNC01MHYtMTQyaC05NnYxNDJsLTM0IDUwWm04MiAwWiIvPjwvc3ZnPg=="  # Icon for menu bar

mkdir -p "$TEMP_FOLDER"  # Ensure temp folder exists

# Read stored image path, if available
if [[ -f "$IMAGE_STORAGE" ]]; then
    SELECTED_IMAGE=$(cat "$IMAGE_STORAGE")
else
    SELECTED_IMAGE=""
fi

# Handle image selection
if [[ "$1" == "select" ]]; then
    NEW_IMAGE=$(osascript -e 'tell app "System Events" to activate' \
                         -e 'set selectedFile to choose file with prompt "Select an image" of type {"public.image"}' \
                         -e 'POSIX path of selectedFile')

    if [[ -n "$NEW_IMAGE" && -f "$NEW_IMAGE" ]]; then
        echo "$NEW_IMAGE" > "$IMAGE_STORAGE"
    fi

    PLUGIN_NAME=$(basename "$0")
    open "swiftbar://refreshplugin?name=$PLUGIN_NAME"

    exit 0
fi

# If no image is selected, show default message
if [[ -z "$SELECTED_IMAGE" || ! -f "$SELECTED_IMAGE" ]]; then
    echo "$ICON"
    echo "---"
    echo "No image selected"
    echo "Select Image | bash='$0' param1=select terminal=false refresh=true"
    exit 0
fi

# Copy to temp location and process
cp "$SELECTED_IMAGE" "$TEMP_IMAGE"

# Resize proportionally if needed
WIDTH=$(identify -format "%w" "$TEMP_IMAGE")
HEIGHT=$(identify -format "%h" "$TEMP_IMAGE")

if [[ "$WIDTH" -gt 720% || "$HEIGHT" -gt 720% ]]; then
    magick "$TEMP_IMAGE" -resize 700x700\> "$TEMP_IMAGE" 2>/dev/null
fi

# Convert to base64 for xBar display
BASE64_IMAGE=$(base64 -i "$TEMP_IMAGE")

# Display the selected image in xBar menu
echo "$ICON"
echo "---"
echo "| image=$BASE64_IMAGE"
echo "---"
echo "Select Image | bash='$0' param1=select terminal=false refresh=true"

