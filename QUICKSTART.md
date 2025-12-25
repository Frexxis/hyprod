# hyprod - Quick Start Guide

Get up and running in 5 minutes.

## Prerequisites

Ensure you have:
- Arch Linux (or Arch-based distro)
- Hyprland installed and working
- AUR helper (yay or paru)

## Step 1: Install Dependencies

```bash
# Core packages
yay -S quickshell-git hyprland kitty rofi-wayland

# Developer tools
yay -S lazygit zoxide jq ripgrep btop

# Fonts (if not installed)
yay -S ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd
```

## Step 2: Clone Repository

```bash
cd ~/Projects  # or your preferred location
git clone https://github.com/USERNAME/hyprod.git
cd hyprod
```

## Step 3: Backup Existing Config

```bash
# Backup current configs
mkdir -p ~/.config-backup
cp -r ~/.config/hypr ~/.config-backup/
cp -r ~/.config/kitty ~/.config-backup/
cp -r ~/.config/quickshell ~/.config-backup/
```

## Step 4: Install Configurations

```bash
# Run the setup script
./dots-hyprland/setup

# Or manually copy
cp -r dots-hyprland/dots/.config/* ~/.config/
```

## Step 5: Initialize Tools

```bash
# Initialize zoxide
eval "$(zoxide init zsh)"

# Add to ~/.zshrc if not present
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
```

## Step 6: Reload Hyprland

```bash
# Reload configuration
hyprctl reload

# Or log out and log back in
```

## Verify Installation

### Check Quickshell
```bash
quickshell --version
```

### Check Sidebar
Press `Super + A` to open the developer sidebar.

### Check Scratchpads
Press `Super + Shift + G` for lazygit scratchpad.

## First Steps

1. **Open Terminal:** `Super + Return`
2. **Open Sidebar:** `Super + A`
3. **View Keybinds:** `Super + /`
4. **Change Wallpaper:** Right-click desktop

## Troubleshooting

### Quickshell not loading
```bash
# Check for errors
quickshell -c ~/.config/quickshell/ii/shell.qml
```

### Sidebar not appearing
```bash
# Check keybinds
hyprctl binds | grep sidebar
```

### Fonts missing
```bash
# Install missing fonts
yay -S ttf-material-symbols-variable-git
fc-cache -fv
```

## Next Steps

- Read [README.md](./README.md) for full feature list
- Check [PHASES.md](./PHASES.md) for development roadmap
- See [CONTRIBUTING.md](./CONTRIBUTING.md) to contribute

## Quick Reference

| Action | Keybind |
|--------|---------|
| Terminal | `Super + Return` |
| Browser | `Super + B` |
| File Manager | `Super + E` |
| App Launcher | `Super + Space` |
| Sidebar Left | `Super + A` |
| Sidebar Right | `Super + Shift + N` |
| Overview | `Super + Tab` |
| Close Window | `Super + Q` |
| lazygit | `Super + Shift + G` |
| btop | `Super + Shift + H` |
