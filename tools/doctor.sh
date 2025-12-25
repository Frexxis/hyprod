#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DOTS_DIR="$ROOT_DIR/dots-hyprland"

print_kv() {
  local key="$1"
  local value="$2"
  printf '%-22s %s\n' "$key" "$value"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

version_line() {
  local cmd="$1"
  local args="$2"
  if ! has_cmd "$cmd"; then
    echo "missing"
    return 0
  fi

  # shellcheck disable=SC2086
  "$cmd" $args 2>/dev/null | head -n 1 || true
}

missing_required=0

echo "hyprod doctor"
echo

print_kv "root" "$ROOT_DIR"
print_kv "dots-hyprland" "$DOTS_DIR"
echo

for required in quickshell qs hyprctl jq rg kitty; do
  if has_cmd "$required"; then
    print_kv "$required" "OK"
  else
    print_kv "$required" "MISSING"
    missing_required=1
  fi
done

echo
print_kv "quickshell" "$(version_line quickshell --version)"
print_kv "hyprctl" "$(version_line hyprctl version)"
print_kv "jq" "$(version_line jq --version)"
print_kv "rg" "$(version_line rg --version)"
print_kv "kitty" "$(version_line kitty --version)"
print_kv "lazygit" "$(version_line lazygit --version)"
print_kv "lazydocker" "$(version_line lazydocker --version)"
print_kv "btop" "$(version_line btop --version)"
print_kv "zoxide" "$(version_line zoxide --version)"
print_kv "delta" "$(version_line delta --version)"
print_kv "pipx" "$(version_line pipx --version)"
if has_cmd pypr; then
  print_kv "pypr" "$(command -v pypr)"
else
  print_kv "pypr" "missing"
fi

if [ -d "$DOTS_DIR/.git" ]; then
  echo
  echo "dots-hyprland git"
  git -C "$DOTS_DIR" status -sb
fi

if [ "$missing_required" -ne 0 ]; then
  echo
  echo "ERROR: Missing required tools. See output above." >&2
  exit 1
fi
