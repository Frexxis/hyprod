#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $(( $# % 2 )) -ne 0 ]]; then
  echo "Usage: $0 <class> <launch_cmd> [<class> <launch_cmd> ...]" >&2
  exit 2
fi

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "Error: hyprctl not found in PATH" >&2
  exit 127
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq not found in PATH" >&2
  exit 127
fi

clients_json="$(hyprctl clients -j || true)"

# 1) Prefer focusing an existing matching window.
for ((i = 1; i <= $#; i += 2)); do
  app_class="${!i}"

  [[ -z "$app_class" ]] && continue

  window_id="$(
    jq -r --arg cls "$app_class" '.[]
      | select((.class // "" | ascii_downcase) == ($cls | ascii_downcase))
      | .address' <<<"$clients_json" | head -n 1
  )"

  if [[ -n "$window_id" && "$window_id" != "null" ]]; then
    hyprctl dispatch focuswindow "address:$window_id" >/dev/null
    exit 0
  fi
done

# 2) Otherwise launch the first available command.
for ((i = 2; i <= $#; i += 2)); do
  launch_cmd="${!i}"

  [[ -z "$launch_cmd" ]] && continue

  read -r -a tokens <<<"$launch_cmd"
  [[ ${#tokens[@]} -eq 0 ]] && continue

  if [[ "${tokens[0]}" == "command" && "${tokens[1]:-}" == "-v" && -n "${tokens[2]:-}" ]]; then
    command -v "${tokens[2]}" >/dev/null 2>&1 || continue
  else
    command -v "${tokens[0]}" >/dev/null 2>&1 || continue
  fi

  # Use array execution for safety instead of eval
  # This handles simple commands properly without shell injection risk
  if [[ "$launch_cmd" == *'&&'* || "$launch_cmd" == *'||'* || "$launch_cmd" == *'|'* || "$launch_cmd" == *';'* ]]; then
    # Complex command with shell operators - use explicit bash -c
    bash -c "$launch_cmd" &
  else
    # Simple command - use direct array execution (safer)
    "${tokens[@]}" &
  fi
  exit 0
done

exit 1
