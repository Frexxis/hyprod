# Active Context: hyprod

## Current Work Focus

### Phase Status
**Current Phase:** Phase 6 - AI & Claude Code CLI Integration (Implemented)

### Immediate Next Steps
1. Smoke test all Phase 6 features in Hyprland
2. Test `/model claude-code` and verify streaming works
3. Test Super+Alt+C Claude scratchpad keybind
4. Phase 7: Extra Features (Docker panel, password manager)

## Recent Changes

### Phase 1 Setup (2025-12-25)
- Created `developer-edition` branch in `dots-hyprland/`
- Installed user-space tools: `pyprland` (pipx), `zoxide`, `delta`, `lazydocker` (GitHub releases)
- Added project tooling: `tools/doctor.sh`, `tools/bootstrap.sh`
- Added repo-wide editor settings: `.editorconfig`, `.gitignore`

### Phase 2 Cleanup & Fixes (2025-12-25)
- Removed Anime/Translator/Booru modules and Booru service
- Removed `policies.weeb` UI + Konachan/osu random wallpaper actions and scripts
- Fixed `ResourceUsage.qml` polling interval (1ms → 3000ms) + clamp
- Fixed `Network.qml` password reconnect loop (timer-based retry + null guards)
- Fixed `createObject` leaks: `Ai.qml` message lifecycle + `StyledListView.qml` transitions
- Cleaned unused translation keys and initialized the shapes submodule

### Phase 3 Launch-or-Focus & Pyprland (2025-12-25)
- Added `launch-or-focus.sh` and updated app keybinds to focus-or-launch
- Added `pyprland.toml` + autostart (`execs.conf`) and global pyprland keybinds
- Added scratchpad tooling: `toggle-scratchpad.sh` + lazygit/btop scratchpad keybinds and window rules

### Phase 4 Developer Sidebar - Basic (2025-12-25)
- Added Git status tab: `services/Git.qml` + `sidebarLeft/GitWidget.qml`
- Added System monitor tab: `sidebarLeft/SystemMonitor.qml` (CPU/RAM/Swap + Disk)
- Updated `SidebarLeftContent.qml` to include Git/System tabs
- Added config defaults under `developer.*` and updated only `en_US` translations

### Phase 5 Developer Sidebar - Advanced (2025-12-25)
- Added Projects tab: `services/Projects.qml` + `sidebarLeft/ProjectSwitcher.qml` (zoxide + favorites + quick actions)
- Added Commands tab: `sidebarLeft/QuickCommands.qml` (config commands + actions scripts + add/delete)
- Enhanced Git tab: stage/unstage + commit + recent commits
- Updated `SidebarLeftContent.qml` to 5 tabs and added `developer.projects`/`developer.commands` config defaults

### Phase 6 AI & Claude Code CLI Integration (2025-12-25)
- Created `ClaudeCliStrategy.qml` - NDJSON stream-json parsing for Claude CLI
- Updated `ApiStrategy.qml` - Added `usesDirectExecution()` + `buildCommand()` interface
- Updated `Ai.qml` - Added claude strategy, model, and direct CLI execution support
- Updated `MessageCodeBlock.qml` - Added "Run in Terminal" button for shell scripts
- Added Claude scratchpad keybind (Super+Alt+C) and window rules
- Added cost tracking indicator to AiChat.qml status bar
- Key files: `services/ai/ClaudeCliStrategy.qml`, `keybinds.conf`, `rules.conf`

### Documentation Created (2025-12-25)
- `PRD.md` - Product Requirements Document
- `PHASES.md` - 8-Phase Implementation Roadmap
- `DEVELOPER_HYPRLAND_PLAN.md` - Detailed Technical Plan
- `INDEX.md` - Project Structure & Knowledge Base
- `CLAUDE.md` - Claude Code Instructions
- `README.md` - Project Introduction
- `QUICKSTART.md` - Quick Setup Guide
- `CONTRIBUTING.md` - Contribution Guidelines
- `memory-bank/` - Memory Bank (this structure)

### Key Decisions Made
1. **Project Name:** hyprod (hypr + productivity)
2. **Base Project:** end-4/dots-hyprland fork
3. **Modules to Remove:** Anime, Translator
4. **Modules to Add:** Git, System Monitor, Projects, Commands

## Active Decisions

### Architecture Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| UI Framework | Quickshell (QML) | Maintain compatibility with end-4 |
| Tool Integration | Scratchpad pattern | QML can't embed terminal |
| Git Integration | lazygit + widget | TUI for full features, widget for status |
| AI Integration | Claude Code CLI | Modern AI assistant |

### Implementation Approach
| Feature | Complexity | Priority |
|---------|------------|----------|
| Cleanup (Anime/Translator) | Easy | P0 |
| Bug Fixes (Timer, Leaks) | Easy | P0 |
| Launch-or-Focus | Easy | P1 |
| System Monitor | Medium | P1 |
| Git Widget (Simple) | Medium | P1 |
| Project Switcher | Medium | P2 |
| Claude Code | Complex | P2 |

## Important Patterns & Preferences

### Code Style
- QML: camelCase properties, PascalCase components
- Bash: shellcheck-compliant, set -euo pipefail
- Config: Follow existing formatting

### Documentation
- Turkish comments acceptable
- English file names and code
- Markdown for all docs

### Development Workflow
- Phase-based development
- Test each phase before proceeding
- Document changes in Memory Bank

## Learnings & Insights

### From end-4 Analysis
1. **549 QML files** - Large codebase, modify carefully
2. **Booru.qml is 620 lines** - Significant removal
3. **Services are singletons** - Follow existing pattern
4. **Tab system in SidebarLeftContent.qml** - Key modification point

### From Research
1. **pyprland** - Best for scratchpads and plugins
2. **zoxide** - Essential for project switching
3. **lazygit/lazydocker** - Preferred TUI tools
4. **Material Symbols** - Icon font used throughout

## Blockers & Considerations

### Current Blockers
- None (documentation phase complete)

### Potential Risks
| Risk | Mitigation |
|------|------------|
| Quickshell API changes | Pin version |
| Upstream breaking changes | Selective merge |
| Performance regression | Profile regularly |

## Quick Reference

### Key Files to Modify
```
sidebarLeft/SidebarLeftContent.qml             # Tab management (Phase 2: AI-only)
services/ResourceUsage.qml                     # Fix polling interval
services/Network.qml                           # Fix password reconnect
services/Ai.qml                                # Fix message lifecycle cleanup
modules/common/widgets/StyledListView.qml      # Fix Transition animation allocations
```

### Key Files to Create
```
services/Git.qml                    # Git service
sidebarLeft/GitWidget.qml           # Git UI
sidebarLeft/SystemMonitor.qml       # Resource monitor
sidebarLeft/ProjectSwitcher.qml     # zoxide UI
sidebarLeft/QuickCommands.qml       # Commands UI
```

### Useful Commands
```bash
# Reload Quickshell
quickshell -c ~/.config/quickshell/ii/shell.qml

# Reload Hyprland
hyprctl reload

# Check logs
journalctl -u hyprland -f
```
