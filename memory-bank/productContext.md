# Product Context: hyprod

## Why This Project Exists

### Problem Statement
Current Hyprland rices (dotfiles) are primarily aesthetic-focused and lack developer productivity tools:

1. **end-4/dots-hyprland** includes:
   - Anime booru browser (unnecessary for developers)
   - Translator widget (rarely used)
   - 1ms timer bug causing high CPU usage
   - Memory leaks from improper object cleanup

2. **Developer Pain Points:**
   - No quick Git status visibility
   - No system resource monitoring in sidebar
   - No project/directory quick switching
   - No AI assistant integration
   - Mouse-dependent workflows

### Solution
**hyprod** transforms end-4/dots-hyprland into a developer-focused rice by:
- Removing bloat (Anime, Translator)
- Fixing critical bugs
- Adding developer productivity tools
- Integrating modern AI assistance

## Problems It Solves

| Problem | Solution |
|---------|----------|
| Can't see Git status at glance | Git Widget in sidebar |
| Unknown system resource usage | System Monitor widget |
| Slow project navigation | Project Switcher with zoxide |
| No AI assistance in desktop | Claude Code CLI integration |
| Apps don't focus when running | Launch-or-Focus pattern |
| High idle CPU usage | Fix 1ms → 3000ms timer |
| Memory creep over time | Fix object cleanup leaks |

## How It Should Work

### User Flow: Daily Development
```
1. Login → Hyprland starts with hyprod
2. Super+Return → Terminal (launch-or-focus)
3. Super+A → Open Developer Sidebar
   - See Git status for current project
   - Monitor CPU/RAM usage
   - Quick switch between recent projects
4. Super+Shift+G → lazygit in scratchpad
5. Super+Shift+I → Claude Code assistance
```

### Sidebar Architecture
```
Developer Sidebar (Left)
├── Intelligence (AI Chat + Claude Code)
├── Git (Repository status)
├── Projects (Recent directories via zoxide)
├── Commands (Quick actions)
└── System (CPU/RAM/Disk monitor)
```

## User Experience Goals

### Keyboard-First Design
Every feature accessible without mouse:
- `Super+Return` → Terminal
- `Super+A` → Developer Sidebar
- `Super+Shift+G` → lazygit
- `Super+Shift+H` → btop

### Information at a Glance
Without opening terminals:
- Current Git branch and status
- System resource usage
- Recent projects list

### Minimal Context Switching
- Scratchpad pattern for quick tools
- Launch-or-Focus to avoid duplicates
- Sidebar for quick info without leaving workflow

### Visual Consistency
- Material Design 3 / Material You
- Matugen dynamic theming
- Dark/Light mode support
- Consistent iconography (Material Symbols)

## Target Personas

### Primary: Vibe Coder
- Age: 20-35
- Uses: VS Code, terminal, Git daily
- Wants: Pretty AND functional desktop
- OS: Arch Linux, NixOS, Fedora
- Values: Keyboard efficiency, aesthetics

### Secondary: System Tinkerer
- Loves customizing dotfiles
- Wants clean, modular code
- Performance-obsessed
- Contributes to open source
