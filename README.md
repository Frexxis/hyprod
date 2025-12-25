<div align="center">

# 🚀 hyprod

**Developer-Focused Hyprland Rice**

*A productivity-oriented Hyprland configuration optimized for developers*

[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.40%2B-9b59b6.svg)](https://hyprland.org)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Supported-1793d1.svg)](https://archlinux.org)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 📖 About

**hyprod** is a developer-focused Hyprland dotfiles collection, forked from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) and optimized for productivity.

### What's Different?

| Removed | Added |
|--------|-------|
| ❌ Anime booru browser | ✅ Git widget |
| ❌ Translator module | ✅ System monitor |
| ❌ Timer bugs | ✅ Project switcher |
| ❌ Memory leaks | ✅ Quick commands |
| | ✅ Claude Code CLI integration |

---

## ✨ Features

- **🎯 Launch-or-Focus**: Smart app switching (focus if open, launch if not)
- **💻 Developer Sidebar**: Git status, system monitor, project switcher
- **🤖 Claude Code CLI**: AI assistant integration
- **🎨 Material You Theming**: Dynamic colors via Matugen
- **⚡ Performance**: Optimized with bug fixes and memory leak solutions

---

## 📋 Requirements

- **Hyprland** 0.40+
- **Arch Linux** or Arch-based distro (AUR access)
- **Quickshell** (QML/Qt6)
- **4 GB RAM** minimum (8+ GB recommended)

### Dependencies

```bash
# Core packages
yay -S quickshell-git hyprland kitty rofi-wayland

# Developer tools
yay -S lazygit zoxide jq ripgrep btop

# Optional
yay -S pyprland lazydocker
```

---

## 🚀 Installation

### Quick Install

```bash
bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)
```

### Manual Install

```bash
git clone https://github.com/Frexxis/hyprod.git
cd hyprod
./setup install
```

### After Installation

1. Log out and log back in
2. Select Hyprland at login screen
3. Or if already in Hyprland: `hyprctl reload`

> 💡 **Troubleshooting?** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## ⌨️ Usage

### Basic Keybinds

| Keybind | Action |
|---------|--------|
| `Super + Return` | Terminal |
| `Super + B` | Browser |
| `Super + E` | File Manager |
| `Super + Tab` | Workspace Overview |
| `Super + A` | Developer Sidebar |
| `Super + Q` | Close Window |

### Developer Keybinds

| Keybind | Action |
|---------|--------|
| `Super + Shift + G` | lazygit (scratchpad) |
| `Super + Shift + B` | btop (scratchpad) |
| `Super + Alt + C` | Claude Code CLI |
| `Super + Shift + D` | lazydocker (scratchpad) |
| `Super + P` | Password manager |

---

## 📁 Project Structure

```
hyprod/
├── dots/.config/          # Hyprland + Quickshell configs
├── dots-extra/            # Extra configs
├── docs/                  # Documentation
├── setup                  # Installation script
└── install.sh             # One-liner installer
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

---

## 📚 Documentation

- **[QUICKSTART.md](./docs/QUICKSTART.md)**: Quick start guide
- **[INSTALL.md](./INSTALL.md)**: Full installation guide
- **[KEYBINDS.md](./KEYBINDS.md)**: Keybind reference
- **[CHANGELOG.md](./CHANGELOG.md)**: Release notes
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**: Troubleshooting guide
- **[CONTRIBUTING.md](./CONTRIBUTING.md)**: Contribution guidelines

---

## 🙏 Credits

- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**: Base project
- **[Quickshell](https://github.com/yshui/quickshell)**: QML shell framework
- **[Hyprland](https://hyprland.org)**: Wayland compositor

---

## 📄 License

This project is licensed under **GPL-3.0**. See [LICENSE](./LICENSE) for details.

---

<div align="center">

**Made with ❤️ for developers**

[🔝 Back to Top](#-hyprod)

</div>
