# hyprod - Claude Code Instructions

## Project Overview

This is **hyprod**, a developer-focused Hyprland rice forked from end-4/dots-hyprland.

## Key Documentation

| File | Purpose |
|------|---------|
| `INDEX.md` | Project structure & knowledge base |
| `PRD.md` | Product requirements |
| `PHASES.md` | 8-phase implementation roadmap |
| `DEVELOPER_HYPRLAND_PLAN.md` | Detailed technical plan |

## Important Directories

```
dots-hyprland/dots/.config/quickshell/ii/     # Main QML codebase
dots-hyprland/dots/.config/hypr/              # Hyprland configs
```

## Current Phase

Check memory-bank (/home/muhammetali/Projeler/Hyprland/memory-bank) and `PHASES.md` for current implementation phase. Start with Phase 1 if unstarted.

## Code Style

- **QML/Qt6**: Follow existing patterns in the codebase
- **Bash scripts**: Use shellcheck-compliant code
- **Config files**: Maintain existing formatting

## Key Files to Modify

1. `sidebarLeft/SidebarLeftContent.qml` - Tab management
2. `services/TimerService.qml` - Fix 1ms timer bug
3. `hyprland/keybinds.conf` - Add new shortcuts

## Files to Remove

- `services/Booru.qml`
- `sidebarLeft/Anime.qml` + `anime/`
- `sidebarLeft/Translator.qml` + `translator/`

## Testing

```bash
# Reload Quickshell
quickshell -c ~/.config/quickshell/ii/shell.qml

# Reload Hyprland
hyprctl reload

# Check logs
journalctl -u hyprland -f
```

## Dependencies

Required: `lazygit`, `zoxide`, `jq`
Optional: `pyprland`, `btop`, `lazydocker`
