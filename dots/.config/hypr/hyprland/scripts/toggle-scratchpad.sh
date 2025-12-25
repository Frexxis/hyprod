#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <name> <launch_cmd...>" >&2
  exit 2
fi

name="$1"
shift

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "Error: hyprctl not found in PATH" >&2
  exit 127
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq not found in PATH" >&2
  exit 127
fi

clients_json="$(hyprctl clients -j || true)"

window_id="$(
  jq -r --arg cls "$name" '.[]
    | select((.class // "" | ascii_downcase) == ($cls | ascii_downcase))
    | .address' <<<"$clients_json" | head -n 1
)"

if [[ -z "$window_id" || "$window_id" == "null" ]]; then
  # Spawn on the special workspace (hidden), then toggle it visible.
  hyprctl dispatch exec "[workspace special:${name} silent] $*" >/dev/null
fi

hyprctl dispatch togglespecialworkspace "$name" >/dev/null
