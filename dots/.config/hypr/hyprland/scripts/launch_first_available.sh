#!/usr/bin/env bash
set -euo pipefail

for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue

    # Parse command into array
    read -r -a tokens <<<"$cmd"
    [[ ${#tokens[@]} -eq 0 ]] && continue

    # Check if first token (command) exists
    command -v "${tokens[0]}" >/dev/null 2>&1 || continue

    # Use array execution for safety instead of eval
    if [[ "$cmd" == *'&&'* || "$cmd" == *'||'* || "$cmd" == *'|'* || "$cmd" == *';'* ]]; then
        # Complex command with shell operators - use explicit bash -c
        bash -c "$cmd" &
    else
        # Simple command - use direct array execution (safer)
        "${tokens[@]}" &
    fi
    exit 0
done

exit 1
