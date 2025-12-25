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

```bash
# Clone the repository
git clone https://github.com/USERNAME/hyprod.git
cd hyprod

# Run setup script
./dots-hyprland/setup

# Copy configurations
cp -r dots-hyprland/dots/.config/* ~/.config/
```

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

## Documentation

| Document | Description |
|----------|-------------|
| [INDEX.md](./INDEX.md) | Project structure & knowledge base |
| [PRD.md](./PRD.md) | Product requirements |
| [PHASES.md](./PHASES.md) | 8-phase implementation roadmap |
| [QUICKSTART.md](./QUICKSTART.md) | Quick setup guide |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Contribution guidelines |

## Project Structure

```
hyprod/
├── dots-hyprland/
│   ├── dots/.config/
│   │   ├── hypr/           # Hyprland configs
│   │   ├── kitty/          # Terminal config
│   │   ├── quickshell/     # QML shell (UI)
│   │   └── matugen/        # Dynamic theming
│   ├── setup               # Installation script
│   └── diagnose            # Diagnostic tool
├── README.md
├── INDEX.md
├── PRD.md
├── PHASES.md
├── QUICKSTART.md
└── CONTRIBUTING.md
```

## Performance

| Metric | Target |
|--------|--------|
| CPU Idle | < 5% |
| RAM Idle | < 200 MB |
| Sidebar Open | < 100ms |

## Roadmap

- [x] Phase 1: Project Setup
- [ ] Phase 2: Cleanup & Bug Fixes
- [ ] Phase 3: Launch-or-Focus
- [ ] Phase 4: Developer Sidebar (Basic)
- [ ] Phase 5: Developer Sidebar (Advanced)
- [ ] Phase 6: Claude Code CLI
- [ ] Phase 7: Extra Features
- [ ] Phase 8: Polish & Release

See [PHASES.md](./PHASES.md) for detailed roadmap.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## Credits

- **Base Project:** [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- **Tools:** lazygit, zoxide, pyprland, btop

## License

GPL-3.0 (inherited from end-4/dots-hyprland)
