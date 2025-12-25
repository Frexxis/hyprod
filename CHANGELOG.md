# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-12-25

### Added
- Developer sidebar tabs: Git, System, Projects, Commands
- Launch-or-Focus script + keybinds
- Pyprland config and expose/magnify/center keybinds
- Claude Code CLI integration and scratchpad
- Code block actions: copy, save, apply to file, run in terminal, explain
- System monitor integrations: Docker panel + Timeshift snapshots
- Password manager launcher (1Password/Bitwarden)
- Quick Commands and Project Switcher

### Changed
- Sidebar left tab layout expanded to 5 tabs
- Scratchpad workflow via toggle-scratchpad script

### Fixed
- Removed Anime/Translator/Booru modules and related references
- ResourceUsage polling interval (1ms -> 3000ms + clamp)
- Network reconnect loop (debounce + retry guard)
- Memory leak cleanup in Ai.qml and StyledListView.qml
- Bash parsing issue in fuzzel-emoji.sh
- Stopwatch timer interval (10ms -> 50ms) for reduced CPU usage
- LauncherSearch memory leak (destroy old search results)
- Keybind description consistency for wallpaper selector

### Docs
- Added INSTALL.md, KEYBINDS.md, CHANGELOG.md
- Updated README.md links and structure
