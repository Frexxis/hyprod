# System Patterns: hyprod

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Hyprland                              │
│                    (Wayland Compositor)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Quickshell  │  │   Pyprland   │  │    Matugen   │       │
│  │  (QML/Qt6)   │  │  (Plugins)   │  │  (Theming)   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         │                 │                 │                │
│  ┌──────┴─────────────────┴─────────────────┴──────┐        │
│  │                    Services                      │        │
│  │  ┌─────────────────────────────────────────┐    │        │
│  │  │ Git.qml | ResourceUsage.qml | Ai.qml    │    │        │
│  │  └─────────────────────────────────────────┘    │        │
│  └──────────────────────────────────────────────────┘        │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │                    UI Modules                     │       │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐    │       │
│  │  │ SidebarL   │ │ SidebarR   │ │    Bar     │    │       │
│  │  └────────────┘ └────────────┘ └────────────┘    │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Key Technical Decisions

### 1. Quickshell over AGS/Eww
- **Why:** end-4 already uses Quickshell, maintain compatibility
- **Trade-off:** Less community examples, but Qt6 is powerful
- **Pattern:** QML components with JavaScript logic

### 2. Service-Based Architecture
- **Pattern:** Singleton services for background tasks
- **Location:** `services/*.qml`
- **Usage:** Import and access via `ServiceName.property`

```qml
// Example service access
import qs.services
Text {
    text: ResourceUsage.cpuPercent + "%"
}
```

### 3. Scratchpad Pattern for Tools
- **Why:** QML can't embed terminal, use Hyprland special workspaces
- **Implementation:** pyprland or native special workspace
- **Pattern:** Toggle visibility with keybind

```conf
# Hyprland keybind
bind = $mainMod SHIFT, G, exec, pypr toggle lazygit
```

### 4. Launch-or-Focus Pattern
- **Why:** Avoid opening duplicate instances
- **Implementation:** Check window class, focus or launch

```bash
# Pattern
if hyprctl clients -j | jq -e '.[] | select(.class == "kitty")'; then
    hyprctl dispatch focuswindow "class:^(kitty)$"
else
    kitty
fi
```

## Design Patterns in Use

### Component Pattern (QML)
```qml
// Reusable component structure
Item {
    id: root

    // Public properties
    property string title: ""
    property bool enabled: true

    // Private properties
    property bool _internal: false

    // Signals
    signal clicked()

    // Content
    ColumnLayout {
        // ...
    }
}
```

### Service Pattern
```qml
// Singleton service
Singleton {
    id: gitService

    property string currentBranch: ""
    property list<string> changedFiles: []

    // Process for background work
    Process {
        id: gitBranchProc
        command: ["git", "branch", "--show-current"]
        // ...
    }

    // Timer for polling
    Timer {
        interval: 5000
        repeat: true
        onTriggered: refresh()
    }
}
```

### Tab-Based Sidebar Pattern
```qml
// SidebarLeftContent.qml pattern
property var tabButtonList: [
    {"icon": "neurology", "name": "Intelligence"},
    {"icon": "git_branch", "name": "Git"},
    {"icon": "folder", "name": "Projects"},
    // ...
]

SwipeView {
    currentIndex: tabBar.currentIndex
    contentChildren: [
        aiChat.createObject(),
        gitWidget.createObject(),
        // ...
    ]
}
```

## Component Relationships

```
SidebarLeft.qml
    └── SidebarLeftContent.qml
        ├── TabBar (navigation)
        └── SwipeView (content)
            ├── AiChat.qml → uses → Ai.qml (service)
            ├── GitWidget.qml → uses → Git.qml (service)
            ├── ProjectSwitcher.qml → uses → zoxide
            ├── QuickCommands.qml → uses → Config.qml
            └── SystemMonitor.qml → uses → ResourceUsage.qml
```

## Critical Implementation Paths

### Path 1: Adding New Sidebar Tab
1. Create widget component (e.g., `GitWidget.qml`)
2. Create service if needed (e.g., `services/Git.qml`)
3. Add to `SidebarLeftContent.qml`:
   - Add to `tabButtonList`
   - Add Component
   - Add to `contentChildren`

### Path 2: Adding Launch-or-Focus Keybind
1. Create helper script or use inline command
2. Add to `keybinds.conf`:
```conf
bind = $mainMod, Return, exec, /path/to/launch-or-focus.sh kitty
```

### Path 3: Adding Scratchpad
1. Configure in `pyprland.toml`:
```toml
[scratchpads.lazygit]
command = "kitty --class lazygit-scratch lazygit"
class = "lazygit-scratch"
```
2. Add keybind:
```conf
bind = $mainMod SHIFT, G, exec, pypr toggle lazygit
```

## File Organization

```
quickshell/ii/
├── modules/
│   ├── common/           # Shared components
│   │   ├── Appearance.qml
│   │   ├── Config.qml
│   │   ├── functions/    # Utility functions
│   │   ├── models/       # Data models
│   │   └── widgets/      # Reusable widgets
│   └── ii/
│       ├── sidebarLeft/  # LEFT SIDEBAR (modify)
│       │   ├── SidebarLeft.qml
│       │   ├── SidebarLeftContent.qml
│       │   ├── GitWidget.qml (CREATE)
│       │   └── ...
│       └── sidebarRight/ # Keep as-is
├── services/             # Background services
│   ├── Ai.qml
│   ├── Git.qml (CREATE)
│   ├── ResourceUsage.qml
│   └── ...
└── scripts/              # Helper scripts
```
