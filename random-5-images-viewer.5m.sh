#!/bin/bash
# <xbar.title>Random 5 Images Viewer</xbar.title>
# <xbar.version>1.0</xbar.version>
# <xbar.author>Harshal Shinde</xbar.author>
# <xbar.desc>Displays 5 random images from a specified folder, converting and resizing if necessary.</xbar.desc>
# <xbar.dependencies>exiftool, sips, base64</xbar.dependencies>

# Configuration
IMAGE_FOLDER="/Users/data/Downloads/DL Images"
TEMP_FOLDER="/tmp/xbar_image"
ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNNDMyLTM4NGgxNjhxMjkuNyAwIDUwLjg1LTIxLjE1UTY3Mi00MjYuMyA2NzItNDU2di02MHEwLTI5LjctMjEuMTUtNTAuODVRNjI5LjctNTg4IDYwMC01ODhoLTk2di02MGgxNjh2LTcySDQzMnYyMDRoMTY4djYwSDQzMnY3MlpNMzEyLTI0MHEtMjkuNyAwLTUwLjg1LTIxLjE1UTI0MC0yODIuMyAyNDAtMzEydi00ODBxMC0yOS43IDIxLjE1LTUwLjg1UTI4Mi4zLTg2NCAzMTItODY0aDQ4MHEyOS43IDAgNTAuODUgMjEuMTVRODY0LTgyMS43IDg2NC03OTJ2NDgwcTAgMjkuNy0yMS4xNSA1MC44NVE4MjEuNy0yNDAgNzkyLTI0MEgzMTJabTAtNzJoNDgwdi00ODBIMzEydjQ4MFpNMTY4LTk2cS0yOS43IDAtNTAuODUtMjEuMTVROTYtMTM4LjMgOTYtMTY4di01NTJoNzJ2NTUyaDU1MnY3MkgxNjhabTE0NC02OTZ2NDgwLTQ4MFoiLz48L3N2Zz4="  # menu bar icon
#ICON="📷"  # Camera emoji as menu bar icon
mkdir -p "$TEMP_FOLDER"

# Select 5 random unique images (handling spaces, special characters)
IFS=$'\n' IMAGE_FILES=($(find "$IMAGE_FOLDER" -type f | sort -R | head -n 5))

# Display in xBar menu
echo "$ICON"
echo "---"

for RANDOM_IMAGE in "${IMAGE_FILES[@]}"; do
    FILENAME=$(basename -- "$RANDOM_IMAGE")
    SAFE_FILENAME=$(echo "$FILENAME" | tr -d '[]') # Removing brackets to prevent parsing issues
    TEMP_IMAGE="$TEMP_FOLDER/$SAFE_FILENAME.jpg"
    
    # Convert to JPG if necessary
    cp "$RANDOM_IMAGE" "$TEMP_IMAGE"
    exiftool -overwrite_original -all= "$TEMP_IMAGE" >/dev/null 2>&1  # Remove metadata for privacy
    sips -s format jpeg "$TEMP_IMAGE" --out "$TEMP_IMAGE" >/dev/null 2>&1
    
    # Resize: Ensure height does not exceed 720px (width can be any value)
    HEIGHT=$(sips -g pixelHeight "$TEMP_IMAGE" | awk 'NR==2 {print $2}')
    if [ "$HEIGHT" -gt 720 ]; then
        sips --resampleHeight 720 "$TEMP_IMAGE" >/dev/null 2>&1
    fi
    
    # Convert to base64
    BASE64_IMAGE=$(base64 -i "$TEMP_IMAGE")
    
    # Display image under submenu
    echo "$FILENAME | submenu=true"
    echo "-- Image | image=$BASE64_IMAGE"
    
    # Cleanup
    rm -f "$TEMP_IMAGE"
done

echo "---"
echo "Refresh | refresh=true"
