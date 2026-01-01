#!/usr/bin/env bash
set -euo pipefail

# Create temp file with secure random name
tmpfile=$(mktemp /tmp/snip_to_search.XXXXXX.png)

# Cleanup on exit (success or failure)
cleanup() {
    rm -f "$tmpfile"
}
trap cleanup EXIT

# Capture screenshot
grim -g "$(slurp)" "$tmpfile"

# Upload and get URL
imageLink=$(curl -sF "files[]=@${tmpfile}" 'https://uguu.se/upload' | jq -r '.files[0].url')

# Open in Google Lens
xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}"
