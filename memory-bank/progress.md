# Progress: hyprod

## What Works

### Documentation (Complete)
- [x] PRD.md - Product Requirements
- [x] PHASES.md - 8-Phase Roadmap
- [x] DEVELOPER_HYPRLAND_PLAN.md - Technical Plan
- [x] INDEX.md - Project Structure
- [x] CLAUDE.md - Claude Code Instructions
- [x] README.md - Project Introduction
- [x] QUICKSTART.md - Quick Setup Guide
- [x] CONTRIBUTING.md - Contribution Guidelines
- [x] Memory Bank - All 6 core files

### Research (Complete)
- [x] Analyzed end-4/dots-hyprland codebase (549 QML files)
- [x] Identified files to remove (~1,950 lines)
- [x] Identified files to modify
- [x] Researched tools (lazygit, zoxide, pyprland, btop)
- [x] Analyzed existing features in end-4

## What's Left to Build

### Phase 1: Project Setup
- [x] Local working copy present (`dots-hyprland/`)
- [x] Created development branch (`developer-edition`)
- [x] Installed dev tools (user-space): `pyprland` (pipx), `zoxide`, `delta`, `lazydocker`
- [x] Quickshell loads (smoke tested; shapes submodule initialized)
- [ ] Backup existing configs (manual step)

### Phase 2: Cleanup & Bug Fixes
- [x] Remove Booru service + Anime/Translator modules
- [x] Update `SidebarLeftContent.qml` (AI-only) + remove Booru ping
- [x] Remove `policies.weeb` UI + Konachan/osu random wallpaper actions/scripts
- [x] Fix `ResourceUsage.qml` timer (1ms → 3000ms + clamp)
- [x] Fix `Network.qml` reconnect loop (timer-based retry + null guards)
- [x] Fix createObject leaks (`Ai.qml` message lifecycle, `StyledListView.qml` transitions)
- [ ] Test stability (3 days)

### Phase 3: Launch-or-Focus & Pyprland
- [x] Create launch-or-focus script
- [x] Add keybinds (focus-or-launch + pyprland)
- [x] Configure pyprland.toml
- [x] Set up scratchpads (lazygit, btop)
- [ ] Smoke test in-session (Hyprland)

### Phase 4: Developer Sidebar - Basic
- [x] Create Git.qml service
- [x] Create GitWidget.qml
- [x] Create SystemMonitor.qml
- [x] Add to sidebar tabs
- [ ] Test integration (in-session)

### Phase 5: Developer Sidebar - Advanced
- [x] Create ProjectSwitcher (zoxide) + favorites
- [x] Create QuickCommands (config + scripts)
- [x] Add fuzzy search
- [x] Add quick actions (terminal/editor/file manager/copy)
- [x] Enhance Git widget (stage/unstage, commit, recent commits)
- [ ] Smoke test integration (in-session)

### Phase 6: AI & Claude Code CLI
- [x] Research Claude Code CLI integration
- [x] Create ClaudeCliStrategy.qml with NDJSON parsing
- [x] Add usesDirectExecution() + buildCommand() to ApiStrategy.qml
- [x] Register claude strategy + model in Ai.qml
- [x] Add direct CLI execution to makeRequest()
- [x] Add "Run in Terminal" button to MessageCodeBlock.qml
- [x] Add Claude scratchpad keybind (Super+Alt+C) + window rules
- [x] Add cost tracking indicator to AiChat.qml
- [ ] Smoke test all Phase 6 features

### Phase 7: Extra Features
- [ ] Docker panel (lazydocker)
- [ ] Password manager integration
- [ ] System snapshots

### Phase 8: Polish & Release
- [ ] 7-day stability test
- [ ] Performance optimization
- [ ] Documentation update
- [ ] Screenshots/demos
- [ ] Release v1.0

## Current Status

```
Phase 1: Project Setup     ████████░░ 80%
Phase 2: Cleanup           █████████░ 90%
Phase 3: Launch-or-Focus   ████████░░ 80%
Phase 4: Sidebar Basic     ████████░░ 80%
Phase 5: Sidebar Advanced  ████████░░ 80%
Phase 6: AI Integration    █████████░ 90%
Phase 7: Extra Features    ░░░░░░░░░░ 0%
Phase 8: Polish            ░░░░░░░░░░ 0%

Overall Progress: ███████░░░ ~70% (Docs + Phase 2-6 implemented, smoke test pending)
```

## Known Issues

### From end-4 (To Fix)
| Issue | Severity | Solution | Phase |
|-------|----------|----------|-------|
| 1ms timer | High | Change to 3000ms | 2 |
| Memory leak | High | Fix createObject cleanup | 2 |
| Anime bloat | Medium | Remove module | 2 |
| Translator bloat | Medium | Remove module | 2 |

### Potential Issues
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Quickshell API changes | Medium | High | Pin version |
| Upstream conflicts | Medium | Medium | Selective merge |
| Performance regression | Low | High | Profile regularly |

## Evolution of Decisions

### 2025-12-25: Initial Planning
- Decided on project name: **hyprod**
- Chose to fork rather than start fresh
- Identified scope: cleanup + developer tools
- Rejected complex features for later phases

### Feature Scope Changes
| Original Idea | Decision | Reason |
|--------------|----------|--------|
| 25+ features | 6 truly missing | Many already exist in end-4 |
| Embedded terminal | Scratchpad pattern | QML limitation |
| Full IDE integration | CLI tools | Keep it simple |
| Custom AI backend | Claude Code CLI | Use existing tool |

## Metrics

### Code Changes (Planned)
| Metric | Target | Current |
|--------|--------|---------|
| Lines removed | >1,500 | 0 |
| Lines added | ~2,000 | 0 |
| Files deleted | ~10 | 0 |
| Files created | ~8 | 0 |

### Performance (Planned)
| Metric | Before | Target |
|--------|--------|--------|
| CPU idle | ~10-15% | <5% |
| RAM idle | ~300 MB | <200 MB |
| Sidebar open | ~100ms | <100ms |

### Documentation
| Metric | Count |
|--------|-------|
| Documentation files | 9 |
| Memory Bank files | 6 |
| Total doc size | ~120 KB |

## Next Session Focus

When starting next session:
1. Read all Memory Bank files
2. Smoke test Phase 6: Claude Code CLI integration
   - Run `/model claude-code` and test streaming
   - Test Super+Alt+C Claude scratchpad keybind
   - Test cost tracking in status bar
   - Test "Run in Terminal" button in code blocks
3. Start Phase 7: Extra Features (Docker panel, password manager)

## Log

### 2025-12-25
- Created all documentation
- Initialized Memory Bank
- Created `developer-edition` branch in `dots-hyprland/`
- Installed user-space tooling: `pyprland`, `zoxide`, `delta`, `lazydocker`
- Added project scripts: `tools/doctor.sh`, `tools/bootstrap.sh`
- Phase 2 implemented (Anime/Translator removal, timer + network fixes, leak fixes, translation cleanup)
- Phase 3 implemented (launch-or-focus, pyprland config/autostart, lazygit/btop scratchpads)
- Phase 4 implemented (Git.qml service, GitWidget.qml, SystemMonitor.qml)
- Phase 5 implemented (ProjectSwitcher, QuickCommands, enhanced Git widget)
- Phase 6 implemented:
  - Created ClaudeCliStrategy.qml with NDJSON stream-json parsing
  - Added usesDirectExecution() + buildCommand() to ApiStrategy.qml
  - Registered claude strategy + model in Ai.qml with direct CLI execution
  - Added "Run in Terminal" button to MessageCodeBlock.qml
  - Added Claude scratchpad keybind (Super+Alt+C) + window rules
  - Added cost tracking indicator to AiChat.qml status bar
