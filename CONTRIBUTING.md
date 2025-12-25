# Contributing to hyprod

Thank you for your interest in contributing!

## Quick Start

```bash
# 1. Fork & Clone
git clone https://github.com/YOUR_USERNAME/hyprod.git
cd hyprod

# 2. Create Feature Branch
git checkout -b feature/your-feature-name

# 3. Install for testing
./setup install
```

## Project Structure

```
hyprod/
├── dots/.config/
│   ├── quickshell/ii/    # QML shell (sidebar, bar, widgets)
│   ├── hypr/             # Hyprland configs
│   └── kitty/            # Terminal config
├── sdata/                # Setup data & dependencies
├── setup                 # Installation script
└── diagnose              # Diagnostic tool
```

## Testing Changes

```bash
# Reload Quickshell
qs -c ~/.config/quickshell/ii/shell.qml

# Reload Hyprland config
hyprctl reload

# Check for errors
journalctl -xe | grep -E "(quickshell|hyprland)"
```

## Coding Standards

### QML/Qt6

- Use `camelCase` for properties and functions
- Use `PascalCase` for component names
- Follow existing patterns in the codebase

### Bash Scripts

- Use `shellcheck`-compliant code
- Use `set -euo pipefail` for safety
- Use lowercase with underscores for variables

## Commit Messages

Use conventional commit format:

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `chore`

Examples:
```
feat(sidebar): add Git widget
fix(timer): correct interval to 3000ms
docs(readme): update installation steps
```

## Pull Request Process

1. Create PR against `main` branch
2. Describe your changes clearly
3. Link related issues if any
4. Wait for review

## Reporting Issues

Include:
- Hyprland version: `hyprctl version`
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs from `journalctl`

## License

GPL-3.0 - Contributions will be licensed under the same terms.
