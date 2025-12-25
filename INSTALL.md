# Installation

## Supported Systems
- Arch Linux and Arch-based distros (EndeavourOS, CachyOS, Manjaro, Garuda)
- Wayland + Hyprland required

## Quick Install
```bash
bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)
```

## Manual Install
```bash
git clone https://github.com/Frexxis/hyprod.git
cd hyprod
./setup install
```

## Backup Existing Configs (Recommended)
```bash
cp -r ~/.config/quickshell ~/.config/quickshell.bak
cp -r ~/.config/hypr ~/.config/hypr.bak
```

## Optional Dependencies
```bash
paru -S pyprland lazygit lazydocker zoxide fzf jq btop glances
```

## Post-Install
- Log out and log back in
- If already in Hyprland: `hyprctl reload`
- Quickshell check: `quickshell -c ~/.config/quickshell/ii/shell.qml`

## Update
```bash
git pull
./setup install
```

## Uninstall
```bash
./setup uninstall
```

## Troubleshooting
See `TROUBLESHOOTING.md`.
