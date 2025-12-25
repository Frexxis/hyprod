# Project Brief: hyprod

## Project Name
**hyprod** (hypr + productivity)

## Project Type
Developer-focused Hyprland rice (dotfiles collection)

## Base Project
Fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (illogical-impulse)

## Core Requirements

### Primary Goals
1. **Cleanup** - Remove unnecessary modules (Anime booru browser, Translator)
2. **Bug Fixes** - Fix 1ms timer bug, memory leaks
3. **Developer Tools** - Add Git widget, System monitor, Project switcher
4. **AI Integration** - Claude Code CLI support
5. **Performance** - Achieve <5% CPU idle, <200MB RAM usage

### Target Users
- **Primary:** "Vibe Coders" - Developers who value both aesthetics and productivity
- **Secondary:** "System Tinkerers" - Ricing enthusiasts who want clean, modular code

### Success Metrics
| Metric | Target |
|--------|--------|
| CPU usage reduction | >10% |
| Code removed | >1,500 lines |
| New developer features | 5+ |
| Daily driver stability | 7+ days |

## Scope

### In Scope
- Left sidebar redesign (Developer Sidebar)
- Launch-or-Focus pattern implementation
- Scratchpad integrations (lazygit, btop, lazydocker)
- Claude Code CLI integration
- Pyprland plugin configuration
- Quick Commands system

### Out of Scope
- GUI installer
- Multi-compositor support (Hyprland only)
- X11 support (Wayland only)
- Embedded terminal in QML (use scratchpads instead)

## Timeline
8-phase implementation (see PHASES.md)

## Key Documents
| Document | Purpose |
|----------|---------|
| PRD.md | Product Requirements |
| PHASES.md | 8-Phase Roadmap |
| INDEX.md | Project Structure |
| DEVELOPER_HYPRLAND_PLAN.md | Detailed Technical Plan |
