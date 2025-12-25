# hyprod - Project Index & Knowledge Base

> **Version:** 1.0.0
> **Generated:** 2025-12-25
> **Base:** end-4/dots-hyprland (illogical-impulse)

---

## Quick Navigation

| Document | Purpose | Status |
|----------|---------|--------|
| [PRD.md](./PRD.md) | Product Requirements | Complete |
| [PHASES.md](./PHASES.md) | 8-Phase Implementation Roadmap | Complete |
| [DEVELOPER_HYPRLAND_PLAN.md](./DEVELOPER_HYPRLAND_PLAN.md) | Detailed Technical Plan | Complete |

---

## 1. Project Overview

### 1.1 What is hyprod?

**hyprod** is a developer-focused Hyprland rice (dotfiles collection) forked from end-4/dots-hyprland. It removes unnecessary features (Anime, Translator) and adds developer productivity tools.

### 1.2 Project Goals

| Goal | Description |
|------|-------------|
| Cleanup | Remove Anime booru browser, Translator modules |
| Bug Fixes | Fix 1ms timer, memory leaks |
| Developer Tools | Add Git widget, System monitor, Project switcher |
| AI Integration | Claude Code CLI support |
| Performance | <5% CPU idle, <200MB RAM |

---

## 2. Directory Structure

```
hyprod/
├── dots-hyprland/              # Main dotfiles (end-4 fork)
│   ├── dots/                   # Configuration files
│   │   └── .config/
│   │       ├── hypr/           # Hyprland configuration
│   │       ├── kitty/          # Terminal configuration
│   │       ├── quickshell/     # QML shell (UI)
│   │       └── matugen/        # Dynamic theming
│   ├── dots-extra/             # Additional configurations
│   ├── sdata/                  # Static data/assets
│   ├── setup                   # Installation script
│   └── diagnose                # Diagnostic tool
├── PRD.md                      # Product Requirements Document
├── PHASES.md                   # 8-Phase Implementation Plan
├── DEVELOPER_HYPRLAND_PLAN.md  # Detailed Technical Plan
└── INDEX.md                    # This file
```

---

## 3. Quickshell Architecture (QML/Qt6)

### 3.1 Module Structure

```
dots/.config/quickshell/ii/
├── GlobalStates.qml            # Global state management
├── ReloadPopup.qml             # Hot reload notification
├── killDialog.qml              # Process kill confirmation
├── modules/
│   ├── common/                 # Shared components
│   │   ├── Appearance.qml      # Theme/styling
│   │   ├── Config.qml          # User configuration
│   │   ├── functions/          # Utility functions
│   │   ├── models/             # Data models
│   │   ├── widgets/            # Reusable widgets
│   │   └── panels/             # Panel templates
│   ├── ii/                     # Main UI modules
│   │   ├── bar/                # Top/bottom bar
│   │   ├── sidebarLeft/        # LEFT SIDEBAR (modify this)
│   │   ├── sidebarRight/       # Right sidebar (keep)
│   │   ├── overview/           # Workspace overview
│   │   ├── cheatsheet/         # Keybind viewer
│   │   └── ...                 # Other modules
│   ├── waffle/                 # Alternative modules
│   └── settings/               # Settings UI
└── services/                   # Background services
```

### 3.2 Services (Background Processes)

| Service | File | Description |
|---------|------|-------------|
| AI | `Ai.qml` | AI chat integration (43KB) |
| Booru | `Booru.qml` | Anime image browser (REMOVE) |
| Cliphist | `Cliphist.qml` | Clipboard history |
| MPRIS | `MprisController.qml` | Media player control |
| Network | `Network.qml` | Network status |
| Notifications | `Notifications.qml` | Notification daemon |
| ResourceUsage | `ResourceUsage.qml` | System resources |
| Translation | `Translation.qml` | i18n support |
| Weather | `Weather.qml` | Weather data |

### 3.3 Left Sidebar (Primary Modification Target)

```
sidebarLeft/
├── SidebarLeft.qml             # Container
├── SidebarLeftContent.qml      # Tab switching logic
├── AiChat.qml                  # AI chat (keep, enhance)
├── Anime.qml                   # Anime browser (REMOVE)
├── Translator.qml              # Translator (REMOVE)
├── aiChat/                     # AI chat components
├── anime/                      # Anime components (REMOVE)
└── translator/                 # Translator components (REMOVE)
```

**Current Tabs:**
1. Intelligence (AI Chat) - Keep
2. Translator - Remove
3. Anime - Remove

**Target Tabs:**
1. Intelligence (AI Chat + Claude Code)
2. Git (Repository status)
3. Projects (Recent directories)
4. Commands (Quick actions)
5. System (Resource monitor)

---

## 4. Hyprland Configuration

### 4.1 Config Files

```
dots/.config/hypr/
├── hyprland.conf               # Main config (includes others)
├── monitors.conf               # Display configuration
├── workspaces.conf             # Workspace rules
├── hypridle.conf               # Idle behavior
├── hyprlock.conf               # Lock screen
├── hyprland/
│   ├── colors.conf             # Color definitions
│   ├── env.conf                # Environment variables
│   ├── execs.conf              # Auto-start apps
│   ├── general.conf            # General settings
│   ├── keybinds.conf           # Keyboard shortcuts (22KB)
│   ├── rules.conf              # Window rules
│   └── scripts/                # Helper scripts
└── custom/                     # User customizations
```

### 4.2 Key Keybinds (Current)

| Keybind | Action | File |
|---------|--------|------|
| `Super+Return` | Terminal (Kitty) | keybinds.conf |
| `Super+B` | Browser | keybinds.conf |
| `Super+E` | File Manager | keybinds.conf |
| `Super+Tab` | Overview | keybinds.conf |
| `Super+A` | Left Sidebar | keybinds.conf |
| `Super+N` | Right Sidebar | keybinds.conf |

### 4.3 New Keybinds (To Add)

| Keybind | Action | Phase |
|---------|--------|-------|
| `Super+Shift+G` | lazygit (scratchpad) | Phase 4 |
| `Super+Shift+H` | btop (scratchpad) | Phase 4 |
| `Super+Shift+D` | lazydocker (scratchpad) | Phase 7 |
| `Super+Shift+I` | Claude Code | Phase 6 |

---

## 5. Scripts & Utilities

### 5.1 Hyprland Scripts

```
dots/.config/hypr/hyprland/scripts/
├── ai/
│   ├── primary-buffer-query.sh     # AI buffer query
│   └── show-loaded-ollama-models.sh # Ollama status
├── fuzzel-emoji.sh                 # Emoji picker
├── launch_first_available.sh       # App launcher fallback
├── snip_to_search.sh              # Screenshot to search
├── workspace_action.sh            # Workspace operations
└── zoom.sh                        # Screen zoom
```

### 5.2 Quickshell Scripts

```
dots/.config/quickshell/ii/scripts/
├── ai/                            # AI-related scripts
├── colors/                        # Theme/color scripts
│   ├── applycolor.sh             # Apply matugen theme
│   ├── generate_colors_material.py
│   └── switchwall.sh             # Wallpaper switcher
├── hyprland/
│   └── get_keybinds.py           # Parse keybinds
├── images/                        # Image processing
└── keyring/                       # Secret management
```

---

## 6. Key Components Reference

### 6.1 Files to REMOVE (Phase 2)

| File | Lines | Purpose |
|------|-------|---------|
| `services/Booru.qml` | 620 | Anime image service |
| `sidebarLeft/Anime.qml` | 780 | Anime browser UI |
| `sidebarLeft/anime/` | ~200 | Anime components |
| `sidebarLeft/Translator.qml` | 252 | Translator UI |
| `sidebarLeft/translator/` | ~100 | Translator components |
| **Total** | ~1,950 | |

### 6.2 Files to MODIFY

| File | Modification | Phase |
|------|-------------|-------|
| `SidebarLeftContent.qml` | Remove Anime/Translator tabs | Phase 2 |
| `services/TimerService.qml` | Fix 1ms → 3000ms | Phase 2 |
| `Config.qml` | Add developer settings | Phase 4 |
| `keybinds.conf` | Add launch-or-focus | Phase 3 |
| `execs.conf` | Add pyprland startup | Phase 3 |

### 6.3 Files to CREATE

| File | Purpose | Phase |
|------|---------|-------|
| `sidebarLeft/GitWidget.qml` | Git status display | Phase 4 |
| `sidebarLeft/SystemMonitor.qml` | CPU/RAM/Disk | Phase 4 |
| `sidebarLeft/ProjectSwitcher.qml` | zoxide integration | Phase 5 |
| `sidebarLeft/QuickCommands.qml` | Custom commands | Phase 5 |
| `services/Git.qml` | Git service backend | Phase 4 |
| `~/.config/hypr/pyprland.toml` | Pyprland config | Phase 3 |

---

## 7. Dependencies

### 7.1 Required (Core)

```bash
# Already installed with end-4
quickshell-git hyprland kitty rofi-wayland

# New requirements
lazygit                    # Git TUI
zoxide                     # Smart cd
jq                         # JSON processing
```

### 7.2 Optional (Enhanced Features)

```bash
# Phase 3
pyprland                   # Hyprland plugins

# Phase 4-5
btop                       # System monitor

# Phase 6
claude-code-cli            # AI assistant (npm)

# Phase 7
lazydocker                 # Docker TUI
1password-cli              # Password manager
```

---

## 8. Implementation Cross-Reference

### 8.1 Phase → Files Matrix

| Phase | Files Affected | Action |
|-------|---------------|--------|
| **Phase 2** | Booru.qml, Anime.qml, Translator.qml | Delete |
| **Phase 2** | SidebarLeftContent.qml | Modify |
| **Phase 2** | TimerService.qml | Fix bug |
| **Phase 3** | keybinds.conf | Add bindings |
| **Phase 3** | pyprland.toml | Create |
| **Phase 4** | GitWidget.qml, SystemMonitor.qml | Create |
| **Phase 4** | Git.qml (service) | Create |
| **Phase 5** | ProjectSwitcher.qml, QuickCommands.qml | Create |
| **Phase 6** | AiChat.qml | Enhance |

### 8.2 Feature → Document Matrix

| Feature | PRD Section | PHASES Section | PLAN Section |
|---------|-------------|----------------|--------------|
| Cleanup | 3.1.1 | Phase 2 | 4.1 |
| Bug Fixes | 3.1.1 | Phase 2 | 4.2 |
| Launch-or-Focus | 3.1.2 | Phase 3 | 5.1 |
| Git Widget | 3.2.1 | Phase 4 | 7.1 |
| System Monitor | 3.2.2 | Phase 4 | 7.2 |
| Project Switcher | 3.2.3 | Phase 5 | 8.1 |
| Claude Code | 3.3.1 | Phase 6 | 9.1 |

---

## 9. Useful Commands

### 9.1 Development

```bash
# Start Quickshell in development mode
quickshell -c ~/.config/quickshell/ii/shell.qml

# Watch for changes
inotifywait -mr ~/.config/quickshell/ii

# Reload Hyprland config
hyprctl reload

# Check Hyprland logs
journalctl -u hyprland -f
```

### 9.2 Testing

```bash
# Test Git service
cd ~/Projects/test-repo && lazygit

# Test zoxide
zoxide query -l | head -10

# Monitor system resources
btop

# Check memory usage
ps aux --sort=-%mem | head -10
```

### 9.3 Debugging

```bash
# Quickshell debug output
QT_LOGGING_RULES="*.debug=true" quickshell

# Check for memory leaks
valgrind --leak-check=full quickshell

# Profile CPU
perf record -g quickshell
perf report
```

---

## 10. API Reference

### 10.1 Quickshell Services

```qml
// Import services
import qs.services

// Access Git service (after creation)
Git.currentBranch
Git.changedFiles
Git.recentCommits

// Access existing services
ResourceUsage.cpuPercent
ResourceUsage.memPercent
Cliphist.items
MprisController.currentTrack
```

### 10.2 Hyprland IPC

```bash
# Get active window
hyprctl activewindow -j

# Get clients
hyprctl clients -j

# Execute dispatcher
hyprctl dispatch exec [app]

# Focus window by class
hyprctl dispatch focuswindow "class:^(kitty)$"
```

### 10.3 pyprland Commands

```bash
# Toggle scratchpad
pypr toggle lazygit

# Expose windows
pypr expose

# Shift monitors
pypr shift_monitors
```

---

## 11. Troubleshooting

| Issue | Solution |
|-------|----------|
| Quickshell not loading | Check `quickshell -c shell.qml` for errors |
| Timer bug (high CPU) | Ensure TimerService interval > 1000ms |
| Sidebar not opening | Check keybind in `hyprctl binds` |
| Git widget empty | Verify `git` command in PATH |
| pyprland not working | Check `systemctl --user status pyprland` |

---

## 12. Changelog

### [Unreleased]
- Initial project setup
- Documentation created (PRD, PHASES, PLAN, INDEX)

---

## 13. Contributors

- **Project Lead:** [Developer Name]
- **Base Project:** end-4 (illogical-impulse)

---

## 14. License

GPL-3.0 (inherited from end-4/dots-hyprland)

---

*Last updated: 2025-12-25*
