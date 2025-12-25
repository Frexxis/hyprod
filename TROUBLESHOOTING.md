# Troubleshooting Guide

Common issues and solutions for hyprod.

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Quickshell Issues](#quickshell-issues)
- [Hyprland Issues](#hyprland-issues)
- [Developer Features](#developer-features)
- [AI Chat Issues](#ai-chat-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Issue: "Unsupported distro" error

**Symptoms**: Install script exits with "hyprod currently supports Arch-based distros only"

**Cause**: Your distribution is not detected as Arch-based

**Solution**:
1. Check your distro: `cat /etc/os-release | grep ^ID=`
2. If Arch-based but not detected, use manual install:
   ```bash
   git clone https://github.com/Frexxis/hyprod
   cd hyprod
   ./setup install
   ```

### Issue: "Hyprland not found" error

**Symptoms**: Install script exits before cloning

**Cause**: Hyprland is not installed or not in PATH

**Solution**:
```bash
# Install Hyprland
yay -S hyprland

# Verify installation
hyprctl version
```

### Issue: Setup script fails during package installation

**Symptoms**: Error during `./setup install`, packages fail to install

**Cause**: Network issues, AUR helper problems, or package conflicts

**Solution**:
1. Update system first: `sudo pacman -Syu`
2. Try with verbose output: `./setup install --ask`
3. Install failed packages manually, then re-run setup

---

## Quickshell Issues

### Issue: Quickshell won't start / Black screen

**Symptoms**: No bar, no sidebar, black screen after login

**Cause**: Missing Qt6 dependencies or shapes submodule not initialized

**Solution**:
```bash
# 1. Check Quickshell is installed
pacman -Qi quickshell-git

# 2. Initialize submodules
cd ~/.local/share/hyprod
git submodule update --init --recursive

# 3. Install Qt6 dependencies
sudo pacman -S qt6-declarative qt6-wayland qt6-svg

# 4. Check logs
journalctl -xe | grep -i quickshell

# 5. Try starting manually
qs -c ~/.config/quickshell/ii/shell.qml
```

### Issue: Quickshell crashes on startup

**Symptoms**: Shell starts but crashes immediately

**Cause**: QML syntax error or missing import

**Solution**:
```bash
# Check for syntax errors
qs --validate ~/.config/quickshell/ii/shell.qml

# Check recent changes
cd ~/.local/share/hyprod
git status
git diff

# Reset to clean state if needed
git checkout -- dots/.config/quickshell/
```

### Issue: Sidebar doesn't open

**Symptoms**: Super+A does nothing

**Cause**: Keybind not loaded or layer rules issue

**Solution**:
```bash
# 1. Reload Hyprland
hyprctl reload

# 2. Check keybinds
hyprctl binds | grep -i sidebar

# 3. Check if Quickshell is running
pgrep -a qs
```

---

## Hyprland Issues

### Issue: Keybinds not working

**Symptoms**: Custom keybinds don't respond

**Cause**: Config not reloaded or syntax error in keybinds.conf

**Solution**:
```bash
# 1. Reload Hyprland
hyprctl reload

# 2. Check for errors
hyprctl reload 2>&1 | grep -i error

# 3. Validate config syntax
hyprctl --config ~/.config/hypr/hyprland.conf

# 4. List active keybinds
hyprctl binds
```

### Issue: Windows rules not applying

**Symptoms**: Scratchpads not floating, windows not centered

**Cause**: Window class doesn't match rules

**Solution**:
```bash
# 1. Get window class
hyprctl clients | grep -i class

# 2. Check rules
hyprctl getoption windowrulev2

# 3. Test rule manually
hyprctl dispatch togglefloating
```

---

## Developer Features

### Issue: Scratchpads not working (lazygit, btop)

**Symptoms**: Super+Shift+G/H does nothing

**Cause**: pyprland not running or misconfigured

**Solution**:
```bash
# 1. Check if pyprland is installed
command -v pypr

# 2. Install if missing
pipx install pyprland

# 3. Check if running
pgrep -a pypr

# 4. Start manually
pypr &

# 5. Check config
cat ~/.config/hypr/pyprland.toml
```

### Issue: Git widget shows no data

**Symptoms**: Git tab in sidebar is empty

**Cause**: Not in a git repository or git not installed

**Solution**:
```bash
# 1. Check git is installed
git --version

# 2. Navigate to a git repo
cd ~/your-project
git status

# 3. Open sidebar (Super+A) and check Git tab
```

### Issue: Project switcher (zoxide) empty

**Symptoms**: Projects tab shows no projects

**Cause**: zoxide not installed or no history

**Solution**:
```bash
# 1. Install zoxide
yay -S zoxide

# 2. Add to shell config (~/.bashrc or ~/.zshrc)
eval "$(zoxide init bash)"  # or zsh

# 3. Build history by navigating to directories
z ~/Projects
z ~/Documents
z ~/code

# 4. Check zoxide database
zoxide query -l
```

---

## AI Chat Issues

### Issue: AI chat shows connection error

**Symptoms**: Error message in chat, no response

**Cause**: Missing API key or network issue

**Solution**:
1. Check you have an API key configured
2. For OpenAI: Export `OPENAI_API_KEY`
3. For Claude Code CLI: Ensure `claude` is in PATH

### Issue: Claude Code CLI not working

**Symptoms**: `/model claude-code` fails or no response

**Cause**: Claude CLI not installed or not authenticated

**Solution**:
```bash
# 1. Check Claude CLI is installed
claude --version

# 2. Install if missing
npm install -g @anthropic-ai/claude-code
# or
pipx install claude-code

# 3. Authenticate
claude auth login

# 4. Test CLI directly
claude -p "Hello"
```

### Issue: "Run in Terminal" button doesn't work

**Symptoms**: Play button on code blocks does nothing

**Cause**: Kitty terminal not installed

**Solution**:
```bash
# Install kitty
sudo pacman -S kitty

# Test
kitty -e echo "Hello"
```

---

## Fonts & Theming

### Issue: Icons showing as boxes/squares

**Symptoms**: Missing icons in bar or sidebar

**Cause**: Material Symbols font not installed

**Solution**:
```bash
# Install required fonts
yay -S ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd

# Rebuild font cache
fc-cache -fv

# Verify
fc-list | grep -i "Material Symbols"
```

### Issue: Theming not working (Material You)

**Symptoms**: No dynamic colors, default gray theme

**Cause**: Matugen not configured or wallpaper not set

**Solution**:
```bash
# 1. Check matugen is installed
command -v matugen

# 2. Set wallpaper (triggers theme generation)
# Use the wallpaper selector in the sidebar

# 3. Manual theme generation
matugen image /path/to/wallpaper.jpg
```

---

## Performance Issues

### Issue: High CPU usage at idle

**Symptoms**: CPU > 10% when doing nothing

**Cause**: Timer bug (should be fixed in hyprod) or animation loops

**Solution**:
```bash
# 1. Check what's using CPU
htop -p $(pgrep qs)

# 2. Disable animations temporarily
# Edit ~/.config/quickshell/ii/config.json
# Set "animations": false

# 3. Report issue with logs
journalctl -u hyprland --since "10 minutes ago"
```

### Issue: High memory usage

**Symptoms**: RAM > 500MB for shell

**Cause**: Memory leaks (should be fixed in hyprod)

**Solution**:
```bash
# 1. Check memory usage
ps aux | grep qs

# 2. Restart Quickshell
pkill qs && sleep 1 && qs -c ~/.config/quickshell/ii/shell.qml &

# 3. If persists, report with memory profile
valgrind --leak-check=full qs -c ~/.config/quickshell/ii/shell.qml
```

---

## Getting Help

### Before asking for help

1. Check this troubleshooting guide
2. Search [existing issues](https://github.com/Frexxis/hyprod/issues)
3. Gather diagnostic info:
   ```bash
   # Run diagnostics
   cd ~/.local/share/hyprod
   ./diagnose > ~/hyprod-diagnostics.txt
   ```

### Where to get help

- **GitHub Issues**: [Frexxis/hyprod/issues](https://github.com/Frexxis/hyprod/issues)
- **Upstream Docs**: [end-4 Wiki](https://github.com/end-4/dots-hyprland/wiki)
- **Hyprland Discord**: General Hyprland questions

### Reporting a bug

Include:
1. What you expected to happen
2. What actually happened
3. Steps to reproduce
4. Output of `./diagnose`
5. Relevant log snippets from `journalctl`

---

## Quick Commands Reference

```bash
# Reload Hyprland config
hyprctl reload

# Restart Quickshell
pkill qs && qs -c ~/.config/quickshell/ii/shell.qml &

# Check Quickshell logs
journalctl -xe | grep quickshell

# Check Hyprland logs
journalctl -u hyprland -f

# Reset to default config
cd ~/.local/share/hyprod
git checkout -- dots/.config/

# Full reinstall
./install.sh
```
