#!/usr/bin/env bash
set -euo pipefail

backup_root="${XDG_CONFIG_HOME:-$HOME/.config-backup}"
timestamp="$(date +%Y%m%d-%H%M%S)"
dest="$backup_root/hyprod-$timestamp"

mkdir -p "$dest"

echo "Backing up current config to: $dest"

to_backup=(
  "${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
  "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
)

for path in "${to_backup[@]}"; do
  if [ -e "$path" ]; then
    cp -a "$path" "$dest/"
    echo "- backed up: $path"
  else
    echo "- skipped (not found): $path"
  fi
done
