#!/bin/bash
# <bitbar.title>QuickFolders</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Harshal and Alex</bitbar.author>
# <bitbar.author.github>alexrockt</bitbar.author.github>
# <bitbar.desc>Quick access to folders, that have files with certain suffix in it. Modified to exclude certain folders (and its subfolders) and avoid searching within specific file types (like .numbers|pages|app|zip, etc.). The script now includes an array PATH_TO_FOLDERS that searches top-down from multiple root-folders
# <bitbar.image>https://raw.githubusercontent.com/alexrockt/misc/master/quickfolders-screenshot.png</bitbar.image>
# <bitbar.dependencies>bash</bitbar.dependencies>
# <bitbar.abouturl>https://blog.aruehe.io/quickfolders-a-bitbar-plugin/</bitbar.abouturl>

# Directories to search
PATH_TO_FOLDERS=("/Users/data/Downloads" "/Users/data/Documents")

# FILETYPES TO NOTE (e.g. pdf|doc) this will be put into grep for filtering
FILETYPES="pdf|dwg|skp|jpeg|jpg|png|webp|gif|svg|tiff|psd|HEIC"
# FILETYPES TO EXCLUDE (e.g. .app, .zip, etc.)
EXCLUDE_FILETYPES="app|zip|numbers|pages"
# Regular expression, to filter during the find operation. E.g. to exclude hidden files and folders
REX=".*/\..*"
# Exclude folder named "support" and its subfolders
EXCLUDE_FOLDERS="*/support/*"
# EXCLUDE_FOLDERS="*/support/*|*/folder\ with\ spaces/*"
# To exclude folders with spaces or other special characters (like "folder with spaces"), you need to ensure the pattern is correctly quoted or escaped so the shell can interpret it correctly.

# Category Icon for menu bar
#ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNOTYtMTY4di0yODhoMjg4djI4OEg5NlptNzItNzJoMTQ0di0xNDRIMTY4djE0NFptNjAtMzM2IDIwNC0zMzYgMjA0IDMzNkgyMjhabTEyOC03MmgxNTJsLTc2LTEyNS03NiAxMjVaTTg0Ny02MiA3MzktMTcwcS0xOS42NiAxMy00Mi41OSAxOS41LTIyLjkzIDYuNS00OC4yMSA2LjUtNzAuMiAwLTExOS4yLTQ5dC00OS0xMTlxMC03MCA0OS0xMTl0MTE5LTQ5cTcwIDAgMTE5IDQ5dDQ5IDExOXEwIDI0LjY1LTYuNzQgNDcuODdUNzkwLTIyMWwxMDggMTA4LTUxIDUxWk02NDcuNzctMjE2UTY4OC0yMTYgNzE2LTI0My43N3EyOC0yNy43OCAyOC02OFE3NDQtMzUyIDcxNi4yMy0zODBxLTI3Ljc4LTI4LTY4LTI4UTYwOC00MDggNTgwLTM4MC4yM3EtMjggMjcuNzgtMjggNjhRNTUyLTI3MiA1NzkuNzctMjQ0cTI3Ljc4IDI4IDY4IDI4Wk0zMTItMzg0Wm0xMjAtMjY0WiIvPjwvc3ZnPg==" 
# Files Icon for menu bar
#ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNMTY4LTE5MnEtMjkuNyAwLTUwLjg1LTIxLjVROTYtMjM1IDk2LTI2NHYtMzg0cTAtMjkuNyAyMS4xNS01MC44NVExMzguMy03MjAgMTY4LTcyMGgyMTZsNDgtNDhoMzYwcTI5LjcgMCA1MC44NSAyMS4xNVE4NjQtNzI1LjcgODY0LTY5NnY0MzJxMCAyOS0yMS4xNSA1MC41VDc5Mi0xOTJIMTY4Wm01NC0yNjRoMTg2di0xODZMMjIyLTQ1NlptLTU0LTQ4IDE0NC0xNDRIMTY4djE0NFptMCAxMjB2MTIwaDYyNHYtNDMySDQ4MHYyNDBxMCAyOS0yMS4xNSA1MC41VDQwOC0zODRIMTY4Wm0yNDAtMTQ0WiIvPjwvc3ZnPg=="
# This variable stores the result
ALLFOLDERS=""

# Loop over both directories
for DIR in "${PATH_TO_FOLDERS[@]}"; do
    ALLFOLDERS+=$(find "${DIR}" \( ! -regex "$REX" \) -type f \( ! -path "$EXCLUDE_FOLDERS" \) | grep -E "($FILETYPES)" | grep -Ev "($EXCLUDE_FILETYPES)" | sed -E 's|/[^/]+$||' | uniq | sort)
done

IFS=$'\n'
#echo "$ICON"
echo "⑆ | color=green size=24"
echo "---"

LASTFOLDER=""
LASTSUBFOLDER=""

for l in $ALLFOLDERS
do
    FOLDER=$(echo "$l" | awk -F/ '{print $(NF-1)}')
    SUBFOLDER=$(echo "$l" | awk -F/ '{print $(NF)}')
    # same folder as before, check if same subfolder
    if [ "$LASTFOLDER" = "$FOLDER" ]; then
        # new folder - print
        if [ "$LASTSUBFOLDER" != "$SUBFOLDER" ]; then
            printf "┗━━ %s | terminal=false refresh=true bash=/usr/bin/open param1='%s' size=14 color=green\n" "$SUBFOLDER" "$l"
            LASTSUBFOLDER=$SUBFOLDER
        fi
    else
        printf "%s | size=14 color=white\n" "$FOLDER"
        printf "┗━━ %s | terminal=false refresh=true bash=/usr/bin/open param1='%s' size=14 color=green\n" "$SUBFOLDER" "$l"
        LASTFOLDER=$FOLDER
        LASTSUBFOLDER=$SUBFOLDER
    fi
done
