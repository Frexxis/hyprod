#!/usr/bin/env bash
# hyprod installer - Developer-focused Hyprland rice
# Usage: bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)
#
# This script:
# 1. Checks if your system is compatible (Arch-based + Hyprland)
# 2. Clones hyprod to ~/.local/share/hyprod
# 3. Runs the setup script
# 4. Verifies installation

set -euo pipefail

# Configuration
REPO_URL="https://github.com/Frexxis/hyprod"
INSTALL_DIR="${HYPROD_DIR:-$HOME/.local/share/hyprod}"
BRANCH="${HYPROD_BRANCH:-main}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Logging functions
info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
fatal()   { error "$*"; exit 1; }
step()    { echo -e "${BLUE}[STEP]${NC} ${BOLD}$*${NC}"; }

# Banner
show_banner() {
    echo -e "${BOLD}"
    cat << 'EOF'
    __                               __
   / /_  __  ______  _________  ____/ /
  / __ \/ / / / __ \/ ___/ __ \/ __  /
 / / / / /_/ / /_/ / /  / /_/ / /_/ /
/_/ /_/\__, / .___/_/   \____/\__,_/
      /____/_/

    Developer-Focused Hyprland Rice
EOF
    echo -e "${NC}"
    echo "Repository: $REPO_URL"
    echo "Install to: $INSTALL_DIR"
    echo
}

# Pre-flight checks
preflight() {
    step "Running pre-flight checks..."

    # Check distro (Arch-only for now)
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        case "${ID:-unknown}" in
            arch|endeavouros|cachyos|manjaro|garuda|arcolinux)
                info "Detected Arch-based distro: $ID"
                ;;
            *)
                fatal "Unsupported distro: ${ID:-unknown}. hyprod currently supports Arch-based distros only.

Supported: Arch Linux, EndeavourOS, CachyOS, Manjaro, Garuda, ArcoLinux

For other distros, manual installation is possible:
  git clone $REPO_URL
  cd hyprod
  ./setup install"
                ;;
        esac
    else
        fatal "Cannot detect distribution (/etc/os-release not found)"
    fi

    # Check Hyprland
    if command -v hyprctl &>/dev/null; then
        local hypr_version
        hypr_version=$(hyprctl version 2>/dev/null | grep -oP 'Tag: v?\K[0-9.]+' | head -1 || echo "unknown")
        info "Hyprland found (version: $hypr_version)"
    elif command -v Hyprland &>/dev/null; then
        info "Hyprland found"
    else
        fatal "Hyprland not found. Please install Hyprland first:

  yay -S hyprland

See: https://wiki.hyprland.org/Getting-Started/Installation/"
    fi

    # Check git
    if ! command -v git &>/dev/null; then
        fatal "git not found. Please install git:

  sudo pacman -S git"
    fi
    info "git found"

    # Check curl (needed for online install)
    if ! command -v curl &>/dev/null; then
        warn "curl not found (optional, but recommended)"
    fi

    # Check if running in Wayland session
    if [[ -z "${WAYLAND_DISPLAY:-}" ]] && [[ -z "${XDG_SESSION_TYPE:-}" || "${XDG_SESSION_TYPE}" != "wayland" ]]; then
        warn "Not running in a Wayland session. Some features may not work until you log into Hyprland."
    fi

    info "All pre-flight checks passed!"
    echo
}

# Clone or update repository
clone_repo() {
    step "Setting up repository..."

    if [[ -d "$INSTALL_DIR/.git" ]]; then
        info "Existing installation found at $INSTALL_DIR"
        echo -n "Update to latest version? [Y/n] "
        read -r response
        if [[ "${response,,}" != "n" ]]; then
            info "Updating..."
            git -C "$INSTALL_DIR" fetch origin "$BRANCH"
            git -C "$INSTALL_DIR" reset --hard "origin/$BRANCH"
            info "Updated to latest version"
        else
            info "Skipping update, using existing version"
        fi
    else
        # Create parent directory if needed
        mkdir -p "$(dirname "$INSTALL_DIR")"

        info "Cloning hyprod..."
        git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        info "Cloned successfully"
    fi

    # Initialize submodules
    if [[ -f "$INSTALL_DIR/.gitmodules" ]]; then
        info "Initializing submodules..."
        git -C "$INSTALL_DIR" submodule update --init --recursive
    fi

    echo
}

# Run setup script
run_setup() {
    step "Running setup..."

    local setup_script="$INSTALL_DIR/setup"

    if [[ ! -x "$setup_script" ]]; then
        if [[ -f "$setup_script" ]]; then
            chmod +x "$setup_script"
        else
            fatal "Setup script not found at: $setup_script"
        fi
    fi

    cd "$INSTALL_DIR"

    info "Starting installation (this may take a while)..."
    echo

    # Run setup with install command
    if ! ./setup install; then
        fatal "Setup failed. Check the output above for errors.

For troubleshooting, see:
  $INSTALL_DIR/TROUBLESHOOTING.md
  https://github.com/Frexxis/hyprod/issues"
    fi

    echo
}

# Verify installation
verify() {
    step "Verifying installation..."

    local warnings=0

    # Check Hyprland config
    if [[ -d "$HOME/.config/hypr" ]]; then
        info "Hyprland config: OK"
    else
        warn "Hyprland config not found at ~/.config/hypr"
        ((warnings++))
    fi

    # Check Quickshell config
    if [[ -d "$HOME/.config/quickshell" ]]; then
        info "Quickshell config: OK"
    else
        warn "Quickshell config not found at ~/.config/quickshell"
        ((warnings++))
    fi

    # Check kitty config
    if [[ -d "$HOME/.config/kitty" ]]; then
        info "Kitty config: OK"
    else
        warn "Kitty config not found at ~/.config/kitty"
        ((warnings++))
    fi

    # Check for pyprland config
    if [[ -f "$HOME/.config/hypr/pyprland.toml" ]]; then
        info "Pyprland config: OK"
    else
        warn "Pyprland config not found (scratchpads may not work)"
        ((warnings++))
    fi

    echo

    if [[ $warnings -gt 0 ]]; then
        warn "Installation completed with $warnings warning(s)"
        warn "Some features may not work correctly"
    else
        info "All checks passed!"
    fi
}

# Show post-install instructions
post_install() {
    echo
    echo -e "${GREEN}${BOLD}Installation complete!${NC}"
    echo
    echo "Next steps:"
    echo "  1. Log out and log back in (or restart)"
    echo "  2. Select Hyprland at the login screen"
    echo
    echo "If already in Hyprland, reload with:"
    echo -e "  ${BOLD}hyprctl reload${NC}"
    echo
    echo "Quick reference:"
    echo "  Super + Return  - Terminal"
    echo "  Super + B       - Browser"
    echo "  Super + A       - Developer Sidebar"
    echo "  Super + Tab     - Workspace Overview"
    echo "  Super + Shift+G - lazygit (scratchpad)"
    echo
    echo "Documentation: $INSTALL_DIR/README.md"
    echo "Troubleshooting: $INSTALL_DIR/TROUBLESHOOTING.md"
    echo
}

# Cleanup on error
cleanup() {
    if [[ "${1:-}" != "0" ]]; then
        error "Installation failed!"
        error "For help, see: https://github.com/Frexxis/hyprod/issues"
    fi
}

# Main
main() {
    trap 'cleanup $?' EXIT

    show_banner
    preflight
    clone_repo
    run_setup
    verify
    post_install

    trap - EXIT
}

# Handle arguments
case "${1:-}" in
    -h|--help)
        echo "hyprod installer"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  -h, --help     Show this help"
        echo "  --uninstall    Remove hyprod installation"
        echo
        echo "Environment variables:"
        echo "  HYPROD_DIR     Installation directory (default: ~/.local/share/hyprod)"
        echo "  HYPROD_BRANCH  Git branch to install (default: main)"
        echo
        echo "Examples:"
        echo "  # Online install"
        echo "  bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)"
        echo
        echo "  # Custom install directory"
        echo "  HYPROD_DIR=~/hyprod $0"
        exit 0
        ;;
    --uninstall)
        step "Uninstalling hyprod..."
        if [[ -d "$INSTALL_DIR" ]]; then
            cd "$INSTALL_DIR"
            if [[ -x "./setup" ]]; then
                ./setup uninstall
            fi
        fi
        if [[ -d "$INSTALL_DIR" ]]; then
            echo -n "Remove $INSTALL_DIR? [y/N] "
            read -r response
            if [[ "${response,,}" == "y" ]]; then
                rm -rf "$INSTALL_DIR"
                info "Removed $INSTALL_DIR"
            fi
        fi
        info "Uninstall complete. Your configs in ~/.config remain untouched."
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
