#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
  mkdir -p "$1"
}

install_from_github_release() {
  local repo="$1"          # e.g. ajeetdsouza/zoxide
  local asset_regex="$2"   # jq regex for the asset name
  local binary_name="$3"   # the binary inside tarball
  local target_path="$4"   # install path

  if [ -x "$target_path" ]; then
    return 0
  fi

  if ! has_cmd curl || ! has_cmd jq || ! has_cmd tar; then
    echo "Missing curl/jq/tar; cannot install $binary_name" >&2
    return 1
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"

  local api_json="$tmpdir/release.json"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" -o "$api_json"

  local url
  url="$(jq -r --arg re "$asset_regex" '.assets | map(select(.name|test($re))) | .[0].browser_download_url // empty' "$api_json")"
  if [ -z "$url" ]; then
    echo "Could not find a release asset matching $asset_regex for $repo" >&2
    return 1
  fi

  local tarball="$tmpdir/archive.tar.gz"
  curl -fsSL "$url" -o "$tarball"
  tar -xzf "$tarball" -C "$tmpdir"

  local bin_path="$tmpdir/$binary_name"
  if [ ! -f "$bin_path" ]; then
    # Some archives contain a top-level folder.
    bin_path="$(find "$tmpdir" -maxdepth 3 -type f -name "$binary_name" | head -n 1 || true)"
  fi

  if [ -z "$bin_path" ] || [ ! -f "$bin_path" ]; then
    echo "Could not locate $binary_name in downloaded archive" >&2
    return 1
  fi

  ensure_dir "$(dirname -- "$target_path")"
  install -m 0755 "$bin_path" "$target_path"
}

echo "[1/3] Doctor"
"$ROOT_DIR/tools/doctor.sh" || true

echo
echo "[2/3] Installing user-space tools (if missing)"

# pyprland (pipx)
if ! has_cmd pypr; then
  if ! has_cmd pipx; then
    echo "pipx is required to install pyprland without sudo" >&2
    exit 1
  fi
  pipx install pyprland
fi

# zoxide
if ! has_cmd zoxide; then
  install_from_github_release \
    "ajeetdsouza/zoxide" \
    "x86_64-unknown-linux-musl\\.tar\\.gz$" \
    "zoxide" \
    "/home/muhammetali/.local/bin/zoxide"
fi

# delta (git-delta)
if ! has_cmd delta; then
  # Prefer musl, fall back to gnu if needed.
  install_from_github_release \
    "dandavison/delta" \
    "x86_64-unknown-linux-musl\\.tar\\.gz$" \
    "delta" \
    "/home/muhammetali/.local/bin/delta" \
    || install_from_github_release \
      "dandavison/delta" \
      "x86_64-unknown-linux-gnu\\.tar\\.gz$" \
      "delta" \
      "/home/muhammetali/.local/bin/delta"
fi

# lazydocker
if ! has_cmd lazydocker; then
  install_from_github_release \
    "jesseduffield/lazydocker" \
    "_Linux_x86_64\\.tar\\.gz$" \
    "lazydocker" \
    "/home/muhammetali/.local/bin/lazydocker"
fi

echo
echo "[3/3] Done"
"$ROOT_DIR/tools/doctor.sh"
