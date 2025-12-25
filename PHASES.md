# hyprod - Implementation Phases

> **Proje:** hyprod
> **Temel:** end-4/dots-hyprland (illogical-impulse)
> **Tarih:** 2025-12-25
> **Toplam Faz:** 8

---

## Quick Overview

| Faz | Adı | Karmaşıklık | Öncelik | Bağımlılık |
|-----|-----|-------------|---------|------------|
| 1 | Proje Kurulumu | ⭐ | P0 | - |
| 2 | Temizlik & Bug Fix | ⭐⭐ | P0 | Faz 1 |
| 3 | Launch-or-Focus & Pyprland | ⭐ | P1 | Faz 2 |
| 4 | Developer Sidebar - Temel | ⭐⭐ | P1 | Faz 2 |
| 5 | Developer Sidebar - Gelişmiş | ⭐⭐⭐ | P2 | Faz 4 |
| 6 | AI & Claude Code CLI | ⭐⭐⭐⭐ | P2 | Faz 4 |
| 7 | Ek Özellikler | ⭐⭐ | P3 | Faz 5 |
| 8 | Polish & Release | ⭐⭐ | P3 | Tümü |

---

## Faz 1: Proje Kurulumu

### Amaç
Fork'u oluştur, geliştirme ortamını hazırla.

### Görevler

- [ ] **1.1** GitHub'da end-4/dots-hyprland fork'la
- [ ] **1.2** Lokal clone ve branch oluştur
  ```bash
  git clone git@github.com:USERNAME/dots-hyprland.git hyprod
  cd hyprod
  git checkout -b main
  ```
- [ ] **1.3** Gerekli araçları kur
  ```bash
  # Temel
  paru -S quickshell-git hyprland

  # Developer tools
  paru -S lazygit lazydocker zoxide fzf ripgrep bat eza delta

  # Pyprland
  pip install pyprland

  # Monitoring
  paru -S btop glances
  ```
- [ ] **1.4** Test ortamı hazırla
  ```bash
  # Mevcut config'i yedekle
  cp -r ~/.config/quickshell ~/.config/quickshell.bak
  cp -r ~/.config/hypr ~/.config/hypr.bak
  ```
- [ ] **1.5** İlk build & test
  ```bash
  quickshell -c dots/.config/quickshell/ii/shell.qml
  ```

### Doğrulama
- [ ] Fork GitHub'da görünüyor
- [ ] Quickshell hatasız başlıyor
- [ ] Tüm gerekli araçlar kurulu

### Çıktılar
- Git repository hazır
- Development branch oluşturuldu
- Araçlar kuruldu

---

## Faz 2: Temizlik & Bug Fix

### Amaç
Gereksiz modülleri kaldır, kritik bug'ları düzelt.

### Görevler

#### 2.1 Dosya Silme
- [ ] `sidebarLeft/Anime.qml` sil
- [ ] `sidebarLeft/Translator.qml` sil
- [ ] `sidebarLeft/anime/` dizini sil
- [ ] `sidebarLeft/translator/` dizini sil
- [ ] `services/Booru.qml` sil
- [ ] `services/BooruResponseData.qml` sil

#### 2.2 SidebarLeftContent.qml Düzenleme
```qml
// KALDIR: property tanımları
property bool translatorEnabled: ...
property bool animeEnabled: ...
property bool animeCloset: ...

// KALDIR: tabButtonList içinden
...(root.translatorEnabled ? [...] : []),
...((root.animeEnabled && !root.animeCloset) ? [...] : [])

// KALDIR: contentChildren içinden
...(root.translatorEnabled ? [translator.createObject()] : []),
...(root.animeEnabled ? [anime.createObject()] : [])

// KALDIR: Component blokları
Component { id: translator ... }
Component { id: anime ... }
```

#### 2.3 Diğer Dosya Düzenlemeleri
- [ ] `LeftSidebarButton.qml` - Booru referansı kaldır
- [ ] `InterfaceConfig.qml` - Translator toggle kaldır
- [ ] `GeneralConfig.qml` - Weeb policy ayarları kaldır
- [ ] `QuickConfig.qml` - Anime wallpaper butonları kaldır
- [ ] `welcome.qml` - Anime/Konachan referansları kaldır
- [ ] `Directories.qml` - booruPreviews, booruDownloads kaldır

#### 2.4 Translation Dosyaları
- [ ] 9 dil dosyasından Anime/Translator key'leri kaldır

#### 2.5 Kritik Bug Düzeltmeleri

**Timer Fix (P0):**
```qml
// ResourceUsage.qml:63
// ÖNCE: interval: 1
// SONRA:
interval: 3000
```

**Process Respawn Fix (P1):**
```qml
// Network.qml:138-139
// Delay before restart
Timer {
    id: restartTimer
    interval: 5000
    onTriggered: if (shouldRun) networkProcess.running = true
}
```

**Memory Leak Audit (P0):**
- [ ] Ai.qml - 15 createObject için destroy() ekle
- [ ] StyledListView.qml - cleanup ekle

### Doğrulama
```bash
# Sidebar aç
# Sadece AI Chat tab'ı görünmeli
# Console'da hata olmamalı

# CPU kullanımını kontrol et
htop -p $(pgrep quickshell)
# Hedef: %5-10 (önceki: %15-25)
```

### Çıktılar
- ~2,000 satır kod kaldırıldı
- 3 kritik bug düzeltildi
- CPU kullanımı %10-15 azaldı

---

## Faz 3: Launch-or-Focus & Pyprland

### Amaç
Temel Omarchy özelliklerini ekle.

### Görevler

#### 3.1 Launch-or-Focus Script

**Dosya:** `scripts/launch-or-focus.sh`
```bash
#!/bin/bash
set -euo pipefail

APP_CLASS="$1"
LAUNCH_CMD="$2"

WINDOW_ID=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$APP_CLASS\") | .address" | head -1)

if [ -n "$WINDOW_ID" ]; then
    hyprctl dispatch focuswindow "address:$WINDOW_ID"
else
    $LAUNCH_CMD &
fi
```

- [ ] Script oluştur
- [ ] Execute permission ver: `chmod +x`
- [ ] PATH'e ekle veya tam yol kullan

#### 3.2 Hyprland Keybinds
```bash
# keybinds.conf
bind = $mainMod, Return, exec, launch-or-focus.sh kitty kitty
bind = $mainMod, B, exec, launch-or-focus.sh firefox firefox
bind = $mainMod, E, exec, launch-or-focus.sh org.gnome.Nautilus nautilus
bind = $mainMod, C, exec, launch-or-focus.sh "Code" code
bind = $mainMod, O, exec, launch-or-focus.sh obsidian obsidian
```

#### 3.3 Pyprland Kurulum

**Dosya:** `~/.config/hypr/pyprland.toml`
```toml
[pyprland]
plugins = ["expose", "layout_center", "magnify", "fetch_client_menu"]

[expose]
include_special = false

[layout_center]
margin = 60
offset = [0, 30]

[magnify]
factor = 2
```

- [ ] pyprland.toml oluştur
- [ ] Hyprland exec-once ekle: `exec-once = pypr`
- [ ] Keybinds ekle:
  ```bash
  bind = $mainMod, E, exec, pypr expose
  bind = $mainMod, Z, exec, pypr zoom
  bind = $mainMod SHIFT, M, exec, pypr layout_center toggle
  ```

### Araçlar & Repolar

| Araç | Repo | Açıklama |
|------|------|----------|
| pyprland | [hyprland-community/pyprland](https://github.com/hyprland-community/pyprland) | Plugin host |
| hyprscratch | [sashetophizika/hyprscratch](https://github.com/sashetophizika/hyprscratch) | Rust scratchpad (alternatif) |
| hyprland_scripts | [Reagent992/hyprland_scripts](https://github.com/Reagent992/hyprland_scripts) | Launch-or-focus referans |

### Doğrulama
- [ ] Super+Return → kitty focus veya aç
- [ ] Super+E → expose görünümü
- [ ] Super+Z → magnify çalışıyor

### Çıktılar
- Launch-or-focus aktif
- Pyprland plugins çalışıyor

---

## Faz 4: Developer Sidebar - Temel

### Amaç
Git ve System tab'larını ekle (basit versiyonlar).

### Görevler

#### 4.1 Yeni Tab Yapısı

**SidebarLeftContent.qml:**
```qml
property var tabButtonList: [
    {"icon": "neurology", "name": Translation.tr("Intelligence")},
    {"icon": "commit", "name": Translation.tr("Git")},
    {"icon": "monitoring", "name": Translation.tr("System")}
]

contentChildren: [
    aiChat.createObject(),
    gitWidget.createObject(),
    systemMonitor.createObject()
]

Component { id: gitWidget; GitWidget {} }
Component { id: systemMonitor; SystemMonitor {} }
```

#### 4.2 Git Widget (Basit)

**Dosya:** `sidebarLeft/git/GitWidget.qml`

Özellikler:
- [ ] Branch gösterimi
- [ ] Changed files listesi (read-only)
- [ ] lazygit butonu (scratchpad aç)
- [ ] Auto-refresh (5 saniye)

```qml
Process {
    id: gitStatusProc
    command: ["git", "-C", projectPath, "status", "--porcelain", "-b"]
    // Parse output...
}

GroupButton {
    text: "lazygit"
    onClicked: Hyprctl.dispatch("togglespecialworkspace", "lazygit")
}
```

#### 4.3 System Monitor (Basit)

**Dosya:** `sidebarLeft/system/SystemMonitor.qml`

Özellikler:
- [ ] CPU bar + percentage
- [ ] RAM bar + percentage
- [ ] Disk bar + percentage
- [ ] btop butonu

```qml
// ResourceUsage service zaten var, onu kullan
property real cpuUsage: ResourceUsage.cpuUsage
property real ramUsage: ResourceUsage.ramUsage

GroupButton {
    text: "btop"
    onClicked: Hyprctl.dispatch("togglespecialworkspace", "btop")
}
```

#### 4.4 Scratchpad'ler

**hyprland.conf:**
```bash
# lazygit scratchpad
bind = $mainMod SHIFT, G, togglespecialworkspace, lazygit
exec-once = [workspace special:lazygit silent] kitty --class lazygit -e lazygit

windowrulev2 = float, class:^lazygit$
windowrulev2 = size 90% 85%, class:^lazygit$
windowrulev2 = center, class:^lazygit$

# btop scratchpad
bind = $mainMod SHIFT, B, togglespecialworkspace, btop
exec-once = [workspace special:btop silent] kitty --class btop -e btop
```

### Araçlar & Repolar

| Araç | Repo | Açıklama |
|------|------|----------|
| lazygit | [jesseduffield/lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| btop | [aristocratos/btop](https://github.com/aristocratos/btop) | System monitor |
| glances | [nicolargo/glances](https://github.com/nicolargo/glances) | JSON API desteği |

### Doğrulama
- [ ] Git tab açılıyor
- [ ] Branch ve dosya listesi görünüyor
- [ ] lazygit butonu scratchpad açıyor
- [ ] System tab CPU/RAM gösteriyor
- [ ] btop butonu çalışıyor

### Çıktılar
- 2 yeni sidebar tab
- 2 yeni scratchpad

---

## Faz 5: Developer Sidebar - Gelişmiş

### Amaç
Project Switcher ve Quick Commands ekle, Git widget'ı geliştir.

### Görevler

#### 5.1 Project Switcher

**Dosya:** `sidebarLeft/projects/ProjectSwitcher.qml`

Özellikler:
- [ ] zoxide'dan son projeler
- [ ] Fuzzy arama
- [ ] Quick actions (terminal, vscode, file manager)
- [ ] Favori toggle

```qml
Process {
    id: zoxideProc
    command: ["zoxide", "query", "-l"]
    // Parse output...
}

Repeater {
    model: projectList
    ProjectListItem {
        projectPath: modelData
        onOpenTerminal: launchTerminalAt(projectPath)
        onOpenVscode: Qt.openUrlExternally("vscode://file" + projectPath)
    }
}
```

#### 5.2 Quick Commands

**Dosya:** `sidebarLeft/quickcommands/QuickCommands.qml`

**Config:** `~/.config/quickshell/ii/quickcommands.json`
```json
{
  "commands": [
    {"label": "npm run dev", "icon": "rocket_launch", "cmd": "npm run dev", "terminal": true},
    {"label": "make build", "icon": "construction", "cmd": "make build", "terminal": false},
    {"label": "pytest", "icon": "science", "cmd": "pytest", "terminal": true}
  ]
}
```

- [ ] Config okuma/yazma
- [ ] Komut çalıştırma
- [ ] Terminal/background mode

#### 5.3 Git Widget Geliştirme

Ek özellikler:
- [ ] Stage/unstage toggle
- [ ] Quick commit (mesaj + buton)
- [ ] Son 3 commit gösterimi
- [ ] Diff preview (optional)

#### 5.4 Tab Güncelleme
```qml
property var tabButtonList: [
    {"icon": "neurology", "name": Translation.tr("Intelligence")},
    {"icon": "commit", "name": Translation.tr("Git")},
    {"icon": "folder_open", "name": Translation.tr("Projects")},
    {"icon": "terminal", "name": Translation.tr("Commands")},
    {"icon": "monitoring", "name": Translation.tr("System")}
]
```

### Araçlar & Repolar

| Araç | Repo | Açıklama |
|------|------|----------|
| zoxide | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd |
| fzf | [junegunn/fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| sesh | [joshmedeski/sesh](https://github.com/joshmedeski/sesh) | Session manager (referans) |

### Doğrulama
- [ ] Projects tab son dizinleri gösteriyor
- [ ] Arama çalışıyor
- [ ] VSCode/Terminal butonları çalışıyor
- [ ] Quick Commands çalıştırılabiliyor
- [ ] Git stage/unstage çalışıyor

### Çıktılar
- 2 yeni tab (Projects, Commands)
- Git widget geliştirildi
- Toplam 5 sidebar tab

---

## Faz 6: AI & Claude Code CLI

### Amaç
Claude Code CLI entegrasyonu ve AI chat geliştirmeleri.

### Görevler

#### 6.1 Claude CLI Strategy

**Dosya:** `services/ai/ClaudeCliStrategy.qml`

```qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property string cliPath: "/home/muhammetali/.local/bin/claude"
    property string sessionId: ""
    property real totalCost: 0.0

    function buildCommand(prompt) {
        return [
            root.cliPath,
            "--print",
            "--output-format", "stream-json",
            "--include-partial-messages",
            root.sessionId ? ["--session-id", root.sessionId] : "--no-session-persistence"
        ].flat()
    }

    function parseResponseLine(line, message) {
        // Stream JSON parsing
        const event = JSON.parse(line)
        if (event.type === "system") root.sessionId = event.session_id
        if (event.type === "stream_event") {
            // Handle text/thinking deltas
        }
        if (event.type === "result") {
            root.totalCost = event.total_cost_usd
            return { finished: true }
        }
    }
}
```

#### 6.2 Ai.qml Model Ekleme

```qml
"claude-code-cli": aiModelComponent.createObject(this, {
    "name": "Claude Code (Tools)",
    "icon": "terminal-symbolic",
    "description": "Claude with file/code tools",
    "endpoint": "local-cli",
    "requires_key": false,
    "api_format": "claude-cli"
})
```

#### 6.3 Code Block Actions

**Dosya:** `sidebarLeft/aiChat/CodeBlockActions.qml`

- [ ] Kopyala butonu
- [ ] Dosyaya Uygula butonu
- [ ] Terminal'de Çalıştır butonu
- [ ] Açıkla butonu

```qml
RowLayout {
    GroupButton {
        icon: "content_copy"
        onClicked: Quickshell.clipboardText = codeContent
    }
    GroupButton {
        icon: "file_save"
        onClicked: fileApplyDialog.open()
    }
    GroupButton {
        icon: "play_arrow"
        onClicked: runInTerminal(codeContent, language)
    }
}
```

#### 6.4 Claude Scratchpad

```bash
# hyprland.conf
bind = $mainMod SHIFT, C, togglespecialworkspace, claude
exec-once = [workspace special:claude silent] kitty --class claude -e claude

windowrulev2 = float, class:^claude$
windowrulev2 = size 70% 85%, class:^claude$
windowrulev2 = center, class:^claude$
```

### Doğrulama
- [ ] Claude Code model seçilebiliyor
- [ ] Streaming yanıtlar geliyor
- [ ] Session devam ediyor
- [ ] Code block actions çalışıyor
- [ ] Super+Shift+I → Claude scratchpad

### Çıktılar
- Claude Code CLI entegre
- Code block actions aktif
- Claude scratchpad

---

## Faz 7: Ek Özellikler

### Amaç
Password manager, snapshots ve container panel (opsiyonel).

### Görevler

#### 7.1 Password Manager Integration

**Script:** `scripts/rofi-pass.sh`
```bash
#!/bin/bash
# 1Password
op item list --format=json | jq -r '.[].title' | \
    rofi -dmenu -p "1Password" | \
    xargs -I{} op item get "{}" --fields password | wl-copy

# Veya Bitwarden
bw list items --search "$1" | jq -r '.[0].login.password' | wl-copy
```

- [ ] Script oluştur
- [ ] Keybind ekle: `bind = $mainMod, P, exec, rofi-pass.sh`

#### 7.2 System Snapshots Widget

Quick snapshot butonu (optional):
```qml
GroupButton {
    text: "Create Snapshot"
    icon: "backup"
    onClicked: {
        snapshotProcess.running = true
    }
}

Process {
    id: snapshotProcess
    command: ["sudo", "timeshift", "--create", "--comments", "Quick snapshot"]
}
```

#### 7.3 Container Panel (Opsiyonel)

**Dosya:** `sidebarLeft/containers/ContainerPanel.qml`

Basit versiyon:
- [ ] Running containers listesi
- [ ] Start/stop butonları
- [ ] lazydocker butonu

```qml
Process {
    id: dockerListProc
    command: ["docker", "ps", "-a", "--format", "{{json .}}"]
}
```

### Araçlar & Repolar

| Araç | Repo | Açıklama |
|------|------|----------|
| 1Password CLI | [1password/1password-cli](https://1password.com/downloads/command-line/) | Password manager |
| Bitwarden CLI | [bitwarden/cli](https://github.com/bitwarden/clients) | Alternatif |
| lazydocker | [jesseduffield/lazydocker](https://github.com/jesseduffield/lazydocker) | Docker TUI |
| ctop | [bcicen/ctop](https://github.com/bcicen/ctop) | Container monitoring |
| dry | [moncho/dry](https://github.com/moncho/dry) | Docker manager |
| Timeshift | [linuxmint/timeshift](https://github.com/linuxmint/timeshift) | Snapshots |

### Doğrulama
- [ ] Super+P → password picker
- [ ] Snapshot butonu çalışıyor (varsa)
- [ ] Container panel görünüyor (varsa)

### Çıktılar
- Password manager entegre
- Opsiyonel: snapshots, containers

---

## Faz 8: Polish & Release

### Amaç
Son düzeltmeler, optimizasyonlar ve release.

### Görevler

#### 8.1 Performance Audit
- [ ] Memory profiling
- [ ] CPU kullanımı kontrol
- [ ] Timer audit (1ms olanlar)
- [ ] createObject/destroy audit

#### 8.2 Theme Consistency
- [ ] Tüm yeni widget'lar Material You uyumlu
- [ ] Dark/Light mode test
- [ ] Renk tutarlılığı kontrol

#### 8.3 Keyboard Shortcuts
- [ ] Tüm shortcut'ları dokümante et
- [ ] Conflict check
- [ ] Cheatsheet güncelle

#### 8.4 Error Handling
- [ ] Git olmayan dizinlerde hata yönetimi
- [ ] Docker yoksa graceful degradation
- [ ] Network hatalarında fallback

#### 8.5 Documentation
- [ ] README.md güncelle
- [ ] INSTALL.md oluştur
- [ ] KEYBINDS.md oluştur
- [ ] Screenshots ekle

#### 8.6 Release
- [ ] CHANGELOG.md oluştur
- [ ] Version tag: `git tag v1.0.0`
- [ ] GitHub release
- [ ] AUR paketi (opsiyonel)

### Doğrulama
- [ ] Fresh install test
- [ ] 24 saat stability test
- [ ] Memory leak kontrolü
- [ ] Tüm özellikler çalışıyor

### Çıktılar
- v1.0.0 release
- Dokümantasyon tamamlandı
- Stable, production-ready

---

## Faz Özeti

```
Faz 1 ──► Faz 2 ──► Faz 3 ──► Faz 4 ──► Faz 5 ──► Faz 6 ──► Faz 7 ──► Faz 8
Setup    Clean    Basic     Dev       Dev       AI        Extra    Release
         +Bugs    Features  Sidebar   Sidebar   Claude    Features Polish
                            Basic     Advanced
```

| Faz | Satır Değişikliği | Yeni Dosya |
|-----|-------------------|------------|
| 1 | 0 | 0 |
| 2 | -2000, +50 | 0 |
| 3 | +100 | 2 scripts |
| 4 | +400 | 4 QML |
| 5 | +600 | 6 QML |
| 6 | +500 | 3 QML |
| 7 | +200 | 2-4 QML |
| 8 | +100 | 3 MD |
| **TOPLAM** | ~-350 net | ~20 dosya |

---

## Araç & Repo Referansları

### Temel Araçlar
| Araç | Repo | Kategori |
|------|------|----------|
| pyprland | [hyprland-community/pyprland](https://github.com/hyprland-community/pyprland) | Hyprland plugins |
| hyprscratch | [sashetophizika/hyprscratch](https://github.com/sashetophizika/hyprscratch) | Scratchpads |
| lazygit | [jesseduffield/lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| lazydocker | [jesseduffield/lazydocker](https://github.com/jesseduffield/lazydocker) | Docker TUI |
| zoxide | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) | Directory jumper |
| btop | [aristocratos/btop](https://github.com/aristocratos/btop) | System monitor |
| glances | [nicolargo/glances](https://github.com/nicolargo/glances) | System monitor (JSON) |

### Referans Projeler
| Proje | Repo | Ne Alınabilir |
|-------|------|---------------|
| end-4/dots-hyprland | [GitHub](https://github.com/end-4/dots-hyprland) | Temel proje |
| awesome-hyprland | [GitHub](https://github.com/hyprland-community/awesome-hyprland) | Araç listesi |
| jimallen/quickshell | [GitHub](https://github.com/jimallen/quickshell) | QML widget örnekleri |
| hyprland-qtutils | [GitHub](https://github.com/hyprwm/hyprland-qtutils) | Qt/QML utilities |

### Monitoring Araçları
| Araç | Repo | Özellik |
|------|------|---------|
| JsonPerfMon | [GitHub](https://github.com/pduveau/jsonperfmon) | JSON output |
| sysmond | [Blog](https://blog.lxsang.me/post/id/39) | Battery + CPU |
| psensor-server | [TecMint](https://www.tecmint.com/psensor-monitors-hardware-temperature-in-linux/) | Temperature JSON API |

---

*Son güncelleme: 2025-12-25*
