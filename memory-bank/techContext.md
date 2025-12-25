# Tech Context: hyprod

## Technologies Used

### Core Stack
| Technology | Version | Purpose |
|------------|---------|---------|
| Hyprland | 0.40+ | Wayland compositor |
| Quickshell | Latest | UI framework (QML/Qt6) |
| Qt6 | 6.x | UI toolkit |
| QML | 6.x | Declarative UI language |

### Developer Tools
| Tool | Purpose | Integration |
|------|---------|-------------|
| lazygit | Git TUI | Scratchpad |
| lazydocker | Docker TUI | Scratchpad |
| btop | System monitor TUI | Scratchpad |
| zoxide | Smart cd | Project switcher |
| fzf | Fuzzy finder | Search features |

### Theming
| Tool | Purpose |
|------|---------|
| Matugen | Dynamic Material You colors |
| hyprpicker | Color picker |
| swww | Wallpaper daemon |

### Shell & Terminal
| Tool | Purpose |
|------|---------|
| Kitty | Primary terminal |
| Zsh | Shell |
| Starship | Prompt |
| Rofi-wayland | App launcher |

## Development Setup

### Required Packages (Arch)
```bash
# Core
yay -S quickshell-git hyprland kitty rofi-wayland

# Developer tools
yay -S lazygit zoxide jq ripgrep btop

# Theming
yay -S matugen-bin swww hyprpicker

# Fonts
yay -S ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd

# Optional
yay -S pyprland lazydocker 1password-cli
```

### Development Environment
```bash
# IDE options
- VS Code with QML extension
- Qt Creator (full QML support)
- Neovim with QML syntax

# Recommended VS Code extensions
- QML (bbenoist.qml)
- Shell-check
- Material Icon Theme
```

### Project Setup
```bash
# Clone repository
git clone https://github.com/end-4/dots-hyprland.git hyprod
cd hyprod

# Create development branch
git checkout -b dev

# Run setup
./setup

# Link to ~/.config for testing
ln -sf $(pwd)/dots/.config/quickshell ~/.config/quickshell
```

## Technical Constraints

### QML/Quickshell Limitations
| Limitation | Workaround |
|------------|------------|
| No embedded terminal | Use scratchpad pattern |
| No native Git bindings | Shell out via Process |
| Limited async support | Use Timer + Process |
| Memory if not careful | Explicit object cleanup |

### Hyprland Constraints
| Constraint | Solution |
|------------|----------|
| Wayland only | No X11 apps (or use xwayland) |
| No global hotkeys in apps | Use Hyprland dispatchers |
| Window class detection | Use `hyprctl clients -j` |

### Performance Targets
| Metric | Target | Current (end-4) |
|--------|--------|-----------------|
| CPU Idle | <5% | ~10-15% (1ms timer bug) |
| RAM Idle | <200 MB | ~300 MB |
| Sidebar open | <100ms | ~100ms |
| Widget refresh | <50ms | Varies |

## Dependencies

### Runtime Dependencies
```
quickshell-git     # UI shell
hyprland           # Compositor
kitty              # Terminal
rofi-wayland       # Launcher
matugen-bin        # Theming
swww               # Wallpaper
```

### Optional Dependencies
```
pyprland           # Hyprland plugins
lazygit            # Git TUI
lazydocker         # Docker TUI
btop               # System monitor
zoxide             # Smart cd
fzf                # Fuzzy finder
jq                 # JSON processor
ripgrep            # Fast grep
1password-cli      # Password manager (optional)
```

### Development Dependencies
```
git                # Version control
shellcheck         # Bash linting
```

## Tool Usage Patterns

### Process Pattern (QML → Shell)
```qml
Process {
    id: gitBranch
    command: ["git", "branch", "--show-current"]
    property string result: ""
    stdout: SplitParser {
        onRead: data => gitBranch.result = data.trim()
    }
    onExited: (code, status) => {
        if (code === 0) {
            root.currentBranch = gitBranch.result
        }
    }
}
```

### Timer Pattern (Polling)
```qml
Timer {
    id: refreshTimer
    interval: 5000  // 5 seconds
    repeat: true
    running: true
    onTriggered: {
        gitBranch.running = true
    }
}
```

### Scratchpad Pattern (Pyprland)
```toml
# ~/.config/hypr/pyprland.toml
[scratchpads.lazygit]
command = "kitty --class lazygit-scratch lazygit"
class = "lazygit-scratch"
size = "80% 80%"
animation = "fromTop"
```

### Launch-or-Focus Pattern
```bash
#!/bin/bash
app_class="$1"
app_cmd="$2"

if hyprctl clients -j | jq -e ".[] | select(.class == \"$app_class\")" > /dev/null; then
    hyprctl dispatch focuswindow "class:^($app_class)$"
else
    exec $app_cmd
fi
```

## File Locations

### Configuration Paths
```
~/.config/hypr/           # Hyprland config
~/.config/quickshell/     # Quickshell config
~/.config/kitty/          # Terminal config
~/.config/rofi/           # Launcher config
~/.config/matugen/        # Theming config
```

### Data Paths
```
~/.cache/quickshell/      # Quickshell cache
~/.local/share/zoxide/    # zoxide database
~/.cache/matugen/         # Theme cache
```

### Log Paths
```
journalctl -u hyprland    # Hyprland logs
~/.cache/quickshell/logs/ # Quickshell logs (if enabled)
```

## API References

### Hyprland IPC
```bash
# Active window
hyprctl activewindow -j

# All clients
hyprctl clients -j

# Execute dispatcher
hyprctl dispatch exec [app]
hyprctl dispatch focuswindow "class:^(class)$"
hyprctl dispatch workspace [n]

# Reload config
hyprctl reload
```

### Quickshell Services
```qml
// Import services
import qs.services

// Available services
ResourceUsage.cpuPercent
ResourceUsage.memPercent
Cliphist.items
MprisController.currentTrack
Notifications.list
```

### Pyprland Commands
```bash
pypr toggle [scratchpad]  # Toggle scratchpad visibility
pypr expose               # Show all windows
pypr shift_monitors       # Shift monitor focus
```
