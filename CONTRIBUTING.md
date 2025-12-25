# Contributing to hyprod

Thank you for your interest in contributing to hyprod!

## Development Setup

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/hyprod.git
cd hyprod
```

### 2. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Development Environment

```bash
# Install dev dependencies
yay -S quickshell-git hyprland

# QML development
# Use Qt Creator or VS Code with QML extension
```

## Project Structure

```
dots-hyprland/dots/.config/
├── quickshell/ii/          # Main QML codebase
│   ├── modules/            # UI modules
│   │   ├── common/         # Shared components
│   │   └── ii/             # Main modules
│   │       └── sidebarLeft/  # Developer sidebar
│   └── services/           # Background services
└── hypr/                   # Hyprland configs
    └── hyprland/           # Config files
```

## Coding Standards

### QML/Qt6

```qml
// Use camelCase for properties and functions
property string myProperty: "value"

function myFunction() {
    // Implementation
}

// Use PascalCase for component names
Item {
    id: root
    // Component content
}
```

### Bash Scripts

```bash
#!/bin/bash
# Use shellcheck-compliant code
# shellcheck disable=SC2086

set -euo pipefail

# Use lowercase with underscores for variables
my_variable="value"

# Use functions for reusable code
my_function() {
    echo "Hello"
}
```

### Configuration Files

- Follow existing formatting
- Use comments for non-obvious settings
- Keep related settings grouped

## Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `perf`: Performance improvement
- `test`: Testing
- `chore`: Maintenance

Examples:
```
feat(sidebar): add Git widget component
fix(timer): change interval from 1ms to 3000ms
docs(readme): update installation instructions
```

## Pull Request Process

1. **Create PR** against `main` branch
2. **Fill template** with description
3. **Link issues** if applicable
4. **Wait for review**
5. **Address feedback**
6. **Merge** after approval

### PR Checklist

- [ ] Code follows project style
- [ ] Changes tested locally
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit messages follow convention

## Testing

### Manual Testing

```bash
# Reload Quickshell
quickshell -c ~/.config/quickshell/ii/shell.qml

# Reload Hyprland
hyprctl reload

# Check for errors
journalctl -u hyprland -f
```

### Performance Testing

```bash
# Monitor CPU/RAM usage
btop

# Check for memory leaks
watch -n 1 'ps aux | grep quickshell'
```

## Reporting Issues

### Bug Reports

Include:
- Hyprland version (`hyprctl version`)
- Quickshell version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs

### Feature Requests

Include:
- Use case description
- Proposed solution
- Alternative approaches

## Development Workflow

### Phase-Based Development

Check [PHASES.md](./PHASES.md) for current implementation phase.

1. Pick a task from current phase
2. Create feature branch
3. Implement and test
4. Submit PR
5. Review and merge

### Key Files

| File | Purpose |
|------|---------|
| `SidebarLeftContent.qml` | Tab management |
| `services/*.qml` | Background services |
| `keybinds.conf` | Keyboard shortcuts |

## Getting Help

- Read [INDEX.md](./INDEX.md) for project structure
- Check [PRD.md](./PRD.md) for requirements
- Review existing code patterns
- Ask in discussions/issues

## License

By contributing, you agree that your contributions will be licensed under GPL-3.0.
