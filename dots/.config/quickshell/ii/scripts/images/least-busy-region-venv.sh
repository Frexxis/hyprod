#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Expand tilde if present (safer than eval)
VENV_PATH="${ILLOGICAL_IMPULSE_VIRTUAL_ENV/#\~/$HOME}"
source "$VENV_PATH/bin/activate"
"$SCRIPT_DIR/least_busy_region.py" "$@"
deactivate
