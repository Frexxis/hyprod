#!/usr/bin/env bash
# rofi-pass.sh - Password manager launcher with 1Password/Bitwarden support
# Usage: rofi-pass.sh
# Requires: rofi, wl-copy, notify-send
# Optional: op (1Password CLI) or bw (Bitwarden CLI)

set -euo pipefail

notify_error() {
    notify-send -u critical "Password Manager" "$1"
    exit 1
}

notify_success() {
    notify-send -t 3000 "$1" "$2"
}

# Check for 1Password CLI
if command -v op &>/dev/null; then
    # Check if signed in
    if ! op account list &>/dev/null; then
        notify_error "1Password: Please sign in first with 'op signin'"
    fi

    # Get items list
    ITEMS=$(op item list --format=json 2>/dev/null | jq -r '.[].title' 2>/dev/null) || notify_error "Failed to list 1Password items"

    if [[ -z "$ITEMS" ]]; then
        notify_error "No items found in 1Password"
    fi

    # Show rofi menu
    SELECTED=$(echo "$ITEMS" | rofi -dmenu -i -p "1Password" -theme-str 'window {width: 400px;}') || exit 0

    if [[ -n "$SELECTED" ]]; then
        PASSWORD=$(op item get "$SELECTED" --fields password 2>/dev/null) || notify_error "Failed to get password"
        printf '%s' "$PASSWORD" | wl-copy
        notify_success "1Password" "Password copied to clipboard"
    fi
    exit 0
fi

# Check for Bitwarden CLI
if command -v bw &>/dev/null; then
    # Check vault status
    STATUS=$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null) || STATUS="unauthenticated"

    if [[ "$STATUS" != "unlocked" ]]; then
        notify_error "Bitwarden: Vault is locked. Run 'bw unlock' first."
    fi

    # Get items list
    ITEMS=$(bw list items 2>/dev/null | jq -r '.[].name' 2>/dev/null) || notify_error "Failed to list Bitwarden items"

    if [[ -z "$ITEMS" ]]; then
        notify_error "No items found in Bitwarden"
    fi

    # Show rofi menu
    SELECTED=$(echo "$ITEMS" | rofi -dmenu -i -p "Bitwarden" -theme-str 'window {width: 400px;}') || exit 0

    if [[ -n "$SELECTED" ]]; then
        PASSWORD=$(bw list items --search "$SELECTED" 2>/dev/null | jq -r '.[0].login.password' 2>/dev/null) || notify_error "Failed to get password"
        printf '%s' "$PASSWORD" | wl-copy
        notify_success "Bitwarden" "Password copied to clipboard"
    fi
    exit 0
fi

# No password manager found
notify_error "No password manager found.\nInstall 1password-cli or bitwarden-cli"
