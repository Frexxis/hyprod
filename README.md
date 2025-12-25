# hyprod

> Developer-Focused Hyprland Rice

A productivity-oriented Hyprland dotfiles collection forked from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland), optimized for developers and "vibe coders".

## Features

### Core Features
- **Launch-or-Focus** - Smart app switching (focus if open, launch if not)
- **Developer Sidebar** - Git status, system monitor, project switcher
- **Claude Code CLI** - AI assistant integration
- **Material You Theming** - Dynamic colors via Matugen

### What's Different from end-4?
| Removed | Added |
|---------|-------|
| Anime booru browser | Git widget |
| Translator module | System monitor |
| 1ms timer bug | Project switcher |
| Memory leaks | Quick commands |

## Screenshots

*Coming soon after implementation*

## Requirements

### Minimum
- Hyprland 0.40+
- Quickshell (QML/Qt6)
- 4 GB RAM
- Wayland-compatible GPU

### Dependencies

```bash
# Core (via AUR)
yay -S quickshell-git hyprland kitty rofi-wayland

# Developer tools
yay -S lazygit zoxide jq ripgrep

# Optional
yay -S pyprland btop lazydocker
```

## Installation

### Quick Install (Recommended)

```bash
bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)
```

This will:
1. Check system compatibility (Arch-based + Hyprland)
2. Clone hyprod to `~/.local/share/hyprod`
3. Install dependencies and copy configs
4. Verify installation

### Manual Install

```bash
git clone https://github.com/Frexxis/hyprod
cd hyprod
./setup install
```

### After Installation

1. Log out and log back in
2. Select Hyprland at login screen
3. Or if already in Hyprland: `hyprctl reload`

> **Troubleshooting?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## Keybinds

| Keybind | Action |
|---------|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + B` | Browser |
| `Super + E` | File Manager |
| `Super + Tab` | Workspace Overview |
| `Super + A` | Developer Sidebar |
| `Super + Shift + G` | lazygit (scratchpad) |
| `Super + Shift + H` | btop (scratchpad) |

## Project Structure

```
hyprod/
├── .github/              # GitHub workflows & templates
├── docs/examples/        # Configuration examples
├── dots/                 # Dotfiles
│   └── .config/
│       ├── hypr/         # Hyprland configs
│       ├── kitty/        # Terminal config
│       ├── quickshell/   # QML shell (UI)
│       └── matugen/      # Dynamic theming
├── dots-extra/           # Extra configs
├── sdata/                # Setup data
├── setup                 # Installation script
├── diagnose              # Diagnostic tool
├── install.sh            # One-liner installer
└── README.md
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## Credits

- **Base Project:** [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- **Tools:** lazygit, zoxide, pyprland, btop

## License

GPL-3.0 (inherited from end-4/dots-hyprland)
