#!/bin/bash
# <xbar.title>Random Image Viewer</xbar.title>
# <xbar.version>1.2</xbar.version>
# <xbar.author>Harshal Shinde</xbar.author>
# <xbar.desc>Displays a random image from a specified folder, converting and resizing if necessary.</xbar.desc>
# <xbar.dependencies>exiftool, sips, base64</xbar.dependencies>

# Configuration
IMAGE_FOLDER="/Users/data/Downloads/DL Images"
TEMP_FOLDER="/tmp/xbar_image"
TEMP_IMAGE="$TEMP_FOLDER/temprandom.jpg"
ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNNTUyLTM4NGg3MnYtMzM2SDQ4MHY3Mmg3MnYyNjRaTTMxMi0yNDBxLTI5LjcgMC01MC44NS0yMS4xNVEyNDAtMjgyLjMgMjQwLTMxMnYtNDgwcTAtMjkuNyAyMS4xNS01MC44NVEyODIuMy04NjQgMzEyLTg2NGg0ODBxMjkuNyAwIDUwLjg1IDIxLjE1UTg2NC04MjEuNyA4NjQtNzkydjQ4MHEwIDI5LjctMjEuMTUgNTAuODVRODIxLjctMjQwIDc5Mi0yNDBIMzEyWm0wLTcyaDQ4MHYtNDgwSDMxMnY0ODBaTTE2OC05NnEtMjkuNyAwLTUwLjg1LTIxLjE1UTk2LTEzOC4zIDk2LTE2OHYtNTUyaDcydjU1Mmg1NTJ2NzJIMTY4Wm0xNDQtNjk2djQ4MC00ODBaIi8+PC9zdmc+"  # Icon for menu bar icon
mkdir -p "$TEMP_FOLDER"

# Select a random image (handling spaces and special characters)
RANDOM_IMAGE=$(find "$IMAGE_FOLDER" -type f | sort -R | head -n 1)

# Ensure the file exists
if [[ -z "$RANDOM_IMAGE" ]]; then
    echo "$ICON"
    echo "---"
    echo "No images found"
    exit 1
fi

# Convert to JPG if necessary and resize
cp "$RANDOM_IMAGE" "$TEMP_IMAGE"
# exiftool -overwrite_original -all= "$TEMP_IMAGE" >/dev/null 2>&1  # Remove metadata

# Get current dimensions
WIDTH=$(sips -g pixelWidth "$TEMP_IMAGE" | awk 'NR==2 {print $2}')
HEIGHT=$(sips -g pixelHeight "$TEMP_IMAGE" | awk 'NR==2 {print $2}')

# Resize only if needed
if [[ "$HEIGHT" -gt 900 ]]; then
    sips --resampleHeight 900 "$TEMP_IMAGE" >/dev/null 2>&1
fi

# Convert to base64
BASE64_IMAGE=$(base64 -i "$TEMP_IMAGE")

# Display in xBar (image directly in menu)
echo "$ICON"
echo "---"
echo "| image=$BASE64_IMAGE"
echo "---"
echo "Refresh | refresh=true"

# Cleanup
rm -f "$TEMP_IMAGE"
