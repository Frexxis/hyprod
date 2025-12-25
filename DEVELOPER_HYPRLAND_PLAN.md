# hyprod - Developer-Focused Hyprland Dotfiles

> **Proje Adı:** hyprod
> **Temel:** end-4/dots-hyprland (illogical-impulse)
> **Hedef:** Yazılımcılar ve Vibe Coderlar için optimize edilmiş Hyprland rice
> **Tarih:** 2025-12-25

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Mevcut Durum Analizi](#2-mevcut-durum-analizi)
3. [Kaldırılacak Modüller](#3-kaldırılacak-modüller)
4. [Eklenecek Özellikler](#4-eklenecek-özellikler) (Developer Tools)
5. [Claude Code CLI Entegrasyonu](#5-claude-code-cli-entegrasyonu)
6. [Teknik Mimari](#6-teknik-mimari)
7. [Dosya Yapısı](#7-dosya-yapısı)
8. [Uygulama Yol Haritası](#8-uygulama-yol-haritası)
9. [Klavye Kısayolları](#9-klavye-kısayolları)
10. [Performans Optimizasyonları](#10-performans-optimizasyonları)
11. [Kritik Bug Düzeltmeleri](#11-kritik-bug-düzeltmeleri)
12. [Mevcut Özellik Analizi](#12-mevcut-özellik-analizi-end-4te-var) ✅ (Var olanlar)
13. [Gerçekten Eksik Özellikler](#13-gerçekten-eksik-özellikler-eklenecek) ❌ (Eklenecekler)
14. [Teknoloji Stack](#14-teknoloji-stack)
15. [Risk Analizi](#15-risk-analizi)
16. [Referanslar](#16-referanslar)

---

## 1. Executive Summary

### Proje Amacı

illogical-impulse (end-4/dots-hyprland) projesini fork'layarak, yazılımcılar ve "vibe coderlar" için optimize edilmiş, AI-destekli, estetik ve performanslı bir Hyprland rice oluşturmak.

### Ana Hedefler

1. **Gereksiz modülleri kaldır** - Anime booru browser, Translator (~2,000 satır kod)
2. **Developer araçları ekle** - Git widget, Project switcher, Docker panel, System Monitor
3. **AI entegrasyonunu geliştir** - Claude Code CLI, gelişmiş code block actions
4. **Performans sorunlarını düzelt** - 1ms timer bug, memory leak'ler
5. **Omarchy'nin EKSİK özelliklerini adapte et** - Launch-or-focus, Pyprland plugins

> ⚠️ **ÖNEMLİ BULGU:** Araştırma sonucunda, ilk planladığımız özelliklerin çoğunun (clipboard manager, screenshot annotation, color picker, music widget, quick settings, workspace overview, keybind viewer, theme system) **zaten end-4'te mevcut** olduğu tespit edildi. Bu sayede iş yükü önemli ölçüde azaldı.

### Beklenen Sonuçlar

- ~2,000 satır gereksiz kod kaldırılacak
- ~2,000-3,000 satır yeni developer-focused kod eklenecek (önceki tahmin: 3,000-4,000)
- %10-15 CPU tasarrufu (timer fix ile)
- Memory leak'lerin giderilmesi
- Senior-level kod kalitesi

### Kapsam Değişikliği (2025-12-25)

| Başlangıç Planı | Güncel Durum |
|-----------------|--------------|
| 25+ yeni özellik | 6 yeni özellik (gerisi zaten var) |
| Clipboard Manager ekle | ✅ Zaten var |
| Screenshot Annotation ekle | ✅ Zaten var |
| Color Picker ekle | ✅ Zaten var |
| Music Widget ekle | ✅ Zaten var |
| Quick Settings ekle | ✅ Zaten var |
| Workspace Overview ekle | ✅ Zaten var |
| Keybind Viewer ekle | ✅ Zaten var |
| Theme System ekle | ✅ Zaten var |
| **Launch-or-Focus** | ❌ Eklenecek |
| **Pyprland Plugins** | ❌ Eklenecek |
| **Developer Tools** | ❌ Eklenecek |
| **Claude Code CLI** | ❌ Eklenecek |
| **Password Manager** | ❌ Eklenecek |
| **System Snapshots** | ❌ Eklenecek |

---

## 2. Mevcut Durum Analizi

### 2.1 Proje İstatistikleri

| Metrik | Değer |
|--------|-------|
| Toplam QML dosyası | 549 |
| Toplam QML satırı | ~54,000 |
| Shell script sayısı | 64 |
| UI Framework | Quickshell (QML/Qt6) |
| Tema sistemi | Material Design 3 + Matugen |
| AI entegrasyonu | Gemini, OpenAI, Mistral, Ollama |

### 2.2 Tespit Edilen Kritik Sorunlar

#### Performans Sorunları

| Sorun | Dosya | Satır | Etki | Öncelik |
|-------|-------|-------|------|---------|
| 1ms timer interval | `ResourceUsage.qml` | 63 | %10-15 CPU | P0 |
| Memory leak (createObject) | 133 dosya | - | RAM şişmesi | P0 |
| Process respawn bug | `Network.qml` | 138-139 | Infinite loop | P1 |
| Script error handling | 58 script | - | Sessiz hatalar | P2 |

#### Memory Leak Detayları

```
createObject() çağrısı: 712 adet
destroy() çağrısı: 2 adet
Oran: 356:1 (KRİTİK)
```

**En Tehlikeli Dosyalar:**
- `Ai.qml` (961 satır) → 15 createObject, 0 destroy
- `StyledListView.qml` → 13 createObject, 0 destroy
- `MaterialYouFloatingBox.qml` → Animasyon leak

### 2.3 Sol Sidebar Mevcut Yapısı

```
SidebarLeft
├── Tab 1: AI Chat (Intelligence) ✅ Korunacak
├── Tab 2: Translator ❌ Kaldırılacak
└── Tab 3: Anime (Booru) ❌ Kaldırılacak
```

---

## 3. Kaldırılacak Modüller

### 3.1 Temizlik Özeti

| Modül | Satır | Dosya | Açıklama |
|-------|-------|-------|----------|
| Anime.qml | 575 | 1 | Ana anime booru arayüzü |
| Translator.qml | 251 | 1 | Çeviri widget'ı |
| anime/ dizini | 473 | 2 | BooruImage, BooruResponse |
| translator/ dizini | 126 | 2 | LanguageSelector, TextCanvas |
| Booru.qml | 471 | 1 | Booru API servisi |
| BooruResponseData.qml | 13 | 1 | Veri modeli |
| **TOPLAM** | **1,909** | **8** | |

### 3.2 Silinecek Dosyalar

```bash
# Ana modüller
dots/.config/quickshell/ii/modules/ii/sidebarLeft/Anime.qml
dots/.config/quickshell/ii/modules/ii/sidebarLeft/Translator.qml

# Alt dizinler
dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/BooruImage.qml
dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/BooruResponse.qml
dots/.config/quickshell/ii/modules/ii/sidebarLeft/translator/LanguageSelectorButton.qml
dots/.config/quickshell/ii/modules/ii/sidebarLeft/translator/TextCanvas.qml

# Servisler
dots/.config/quickshell/ii/services/Booru.qml
dots/.config/quickshell/ii/services/BooruResponseData.qml
```

### 3.3 Düzenlenmesi Gereken Dosyalar

#### SidebarLeftContent.qml
```qml
// KALDIR: Satır 16-18
property bool translatorEnabled: Config.options.sidebar.translator.enable
property bool animeEnabled: Config.options.policies.weeb !== 0
property bool animeCloset: Config.options.policies.weeb === 2

// KALDIR: Satır 20-22 (tabButtonList içinden)
...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator")}] : []),
...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime")}] : [])

// KALDIR: Satır 87-88 (contentChildren içinden)
...(root.translatorEnabled ? [translator.createObject()] : []),
...(root.animeEnabled ? [anime.createObject()] : [])

// KALDIR: Satır 98-104 (Component blokları)
Component {
    id: translator
    Translator {}
}
Component {
    id: anime
    Anime {}
}
```

#### Diğer Dosyalar

| Dosya | Değişiklik |
|-------|-----------|
| `LeftSidebarButton.qml` | Booru.responseFinished() bağlantısını kaldır |
| `InterfaceConfig.qml` | Translator toggle'ı kaldır |
| `GeneralConfig.qml` | Weeb policy ayarlarını kaldır/sadeleştir |
| `QuickConfig.qml` | Anime wallpaper butonlarını kaldır |
| `welcome.qml` | Anime/Konachan referanslarını kaldır |
| `Directories.qml` | booruPreviews, booruDownloads, booruDownloadsNsfw kaldır |

### 3.4 Translation Dosyaları

Aşağıdaki dosyalardan ilgili string'ler kaldırılacak:

```
dots/.config/quickshell/ii/translations/
├── en_US.json
├── tr_TR.json
├── ja_JP.json
├── zh_CN.json
├── ru_RU.json
├── uk_UA.json
├── vi_VN.json
├── he_HE.json
└── it_IT.json
```

**Kaldırılacak key'ler:**
- `"Anime"`
- `"Anime boorus"`
- `"Translator"`
- `"Random SFW Anime wallpaper from Konachan..."`
- Booru provider isimleri

### 3.5 Korunacak Ortak Bileşenler

Aşağıdaki bileşenler hem Anime/Translator hem de AiChat tarafından kullanılıyor, **SİLİNMEYECEK**:

- `ApiCommandButton.qml`
- `ApiInputBoxIndicator.qml`
- `DescriptionBox.qml`
- `ScrollToBottomButton.qml`

---

## 4. Eklenecek Özellikler

### 4.1 Yeni Tab Yapısı

```
SidebarLeft (Yeni)
├── Tab 1: AI Chat (Geliştirilmiş) - Icon: neurology
├── Tab 2: DevTools - Icon: developer_mode
├── Tab 3: Projects - Icon: folder_open
├── Tab 4: Containers - Icon: deployed_code
└── Tab 5: System - Icon: monitoring
```

### 4.2 AI Chat Geliştirmeleri

#### Code Block Action Bar

Her code block'un altında görünecek aksiyon çubuğu:

```
┌─────────────────────────────────────────┐
│ ```python                               │
│ def hello():                            │
│     print("Hello, World!")              │
│ ```                                     │
├─────────────────────────────────────────┤
│ [📋 Kopyala] [📁 Dosyaya Uygula] [▶️ Çalıştır] [💡 Açıkla] │
└─────────────────────────────────────────┘
```

**Özellikler:**
- **Kopyala:** Code block'u panoya kopyalar
- **Dosyaya Uygula:** Dosya seçici açar, kodu yazar
- **Çalıştır:** Dil algılayıp terminal'de çalıştırır
- **Açıkla:** AI'dan kod açıklaması ister

#### Gelişmiş Dosya Ekleme

- Birden fazla dosya ekleme (max 5)
- Dosya önizlemesi (ilk 10 satır)
- Görsel dosyalar için thumbnail
- Drag & drop desteği

#### Claude Code CLI Modu

Sidebar'dan Claude Code CLI kullanabilme:
- `/claude-code` komutu ile aktifleştirme
- Streaming yanıtlar
- Session desteği
- Tool calling (file edit, shell commands)

### 4.3 Git Widget

#### Wireframe

```
┌─────────────────────────────────────────┐
│ Git Status                    [lazygit] │
├─────────────────────────────────────────┤
│ ● main ↑2 ↓1                            │
│                                         │
│ Değişen Dosyalar (3)                    │
│ ├── M src/app.py                   [+]  │
│ ├── M README.md                    [+]  │
│ └── ?? config.json                 [+]  │
│                                         │
│ Son Commitler                           │
│ ├── abc123 Fix auth bug       2h ago    │
│ ├── def456 Add API endpoint   5h ago    │
│ └── ghi789 Update docs       1d ago     │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Commit Mesajı: [________________]   │ │
│ │ [Commit] [Push] [Pull] [Stash]      │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### Özellikler

| Özellik | Açıklama |
|---------|----------|
| Branch gösterimi | Current branch + ahead/behind sayısı |
| Dosya listesi | M (modified), A (added), D (deleted), ?? (untracked) |
| Stage toggle | Dosya yanındaki [+] butonu ile stage/unstage |
| Quick commit | Commit mesajı + tek tıkla commit |
| Son commitler | Son 3 commit hash, mesaj, zaman |
| lazygit | Sağ üst buton ile lazygit scratchpad'de aç |

#### Durum Renkleri

- 🟢 Yeşil: Clean working tree
- 🟡 Sarı: Uncommitted changes
- 🔴 Kırmızı: Merge conflicts

### 4.4 Project Switcher

#### Wireframe

```
┌─────────────────────────────────────────┐
│ Son Projeler                     [+Yeni]│
├─────────────────────────────────────────┤
│ Ara: [___________________]      [zoxide]│
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📁 Hyprland Config              ⭐  │ │
│ │    ~/Projeler/Hyprland              │ │
│ │    [Aç] [VSCode] [Terminal]         │ │
│ ├─────────────────────────────────────┤ │
│ │ 📁 NexiteAI                     ⭐  │ │
│ │    ~/Projeler/nexiteai              │ │
│ │    [Aç] [VSCode] [Terminal]         │ │
│ ├─────────────────────────────────────┤ │
│ │ 📁 Bloom                            │ │
│ │    ~/Projeler/bloom                 │ │
│ │    [Aç] [VSCode] [Terminal]         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Hızlı Komutlar                          │
│ [🚀 npm run dev] [🔨 make] [🧪 pytest]  │
└─────────────────────────────────────────┘
```

#### Özellikler

| Özellik | Açıklama |
|---------|----------|
| Proje listesi | zoxide'dan son 10 proje |
| Fuzzy arama | Proje ismi/path ile arama |
| Favori toggle | Yıldız ile favorilere ekle |
| Quick actions | File manager, VSCode, Terminal |
| Hızlı komutlar | Proje bazlı özelleştirilebilir komutlar |

#### zoxide Entegrasyonu

```bash
# Proje listesi alma
zoxide query -l | head -10

# Proje ekleme
zoxide add /path/to/project

# Fuzzy search
zoxide query project_name
```

### 4.5 Container Panel

#### Wireframe

```
┌─────────────────────────────────────────┐
│ Containers (3 running)      [lazydocker]│
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ ● postgres-db                       │ │
│ │   Image: postgres:15                │ │
│ │   CPU: 2%  RAM: 245MB  NET: ↑↓     │ │
│ │   [Stop] [Restart] [Logs] [Shell]   │ │
│ ├─────────────────────────────────────┤ │
│ │ ● redis-cache                       │ │
│ │   Image: redis:7                    │ │
│ │   CPU: 1%  RAM: 52MB   NET: ↑↓     │ │
│ │   [Stop] [Restart] [Logs] [Shell]   │ │
│ ├─────────────────────────────────────┤ │
│ │ ○ nginx-proxy (stopped)             │ │
│ │   Image: nginx:alpine               │ │
│ │   [Start] [Remove]                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Compose Stacks                          │
│ ┌─────────────────────────────────────┐ │
│ │ 📦 dev-environment      [↑] [↓] [×] │ │
│ │ 📦 monitoring           [↑] [↓] [×] │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### Özellikler

| Özellik | Açıklama |
|---------|----------|
| Container listesi | Running/stopped containers |
| Resource monitoring | CPU, RAM, Network activity |
| Quick actions | Start, Stop, Restart, Logs, Shell |
| Compose stacks | docker-compose projeleri |
| Auto-refresh | Her 5 saniyede güncelleme |

#### Docker API Kullanımı

```bash
# Container listesi
docker ps -a --format '{{json .}}'

# Container stats
docker stats --no-stream --format '{{json .}}'

# Compose projeleri
docker compose ls --format json
```

### 4.6 System Monitor

#### Wireframe

```
┌─────────────────────────────────────────┐
│ System                       [htop/btop]│
├─────────────────────────────────────────┤
│ CPU                                     │
│ ████████████░░░░░░░░░░░░░░░  45%       │
│ Intel i7-12700K @ 3.6GHz    58°C       │
│                                         │
│ Memory                                  │
│ ██████████████████░░░░░░░░░  67%       │
│ 10.7 GB / 16.0 GB                      │
│                                         │
│ Disk (/)                                │
│ █████████████████████████░░  85%       │
│ 425 GB / 500 GB                        │
│                                         │
│ Network                                 │
│ ↓ 2.5 MB/s  ↑ 450 KB/s                 │
│ wlan0: Connected                        │
│                                         │
│ Top Processes                           │
│ ┌─────────────────────────────────────┐ │
│ │ chrome      3.2GB    25%            │ │
│ │ code        1.8GB    18%            │ │
│ │ hyprland    650MB    12%            │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### Özellikler

| Özellik | Açıklama |
|---------|----------|
| CPU bar | Kullanım + sıcaklık (renk kodlu) |
| RAM bar | Kullanım + GB değerleri |
| Disk bar | Kullanım + boş alan |
| Network | Upload/download hızları |
| Top processes | En çok kaynak kullanan 3 process |
| Auto-refresh | Her 2 saniyede güncelleme |

#### Sıcaklık Renk Kodları

- 🟢 < 70°C: Normal
- 🟡 70-85°C: Uyarı
- 🔴 > 85°C: Kritik

### 4.7 Quick Commands

#### Yapılandırma Dosyası

`~/.config/quickshell/ii/quickcommands.json`:

```json
{
  "categories": [
    {
      "name": "Development",
      "commands": [
        {
          "label": "Dev Server",
          "icon": "rocket_launch",
          "command": "npm run dev",
          "workingDir": "current",
          "terminal": true
        },
        {
          "label": "Build",
          "icon": "construction",
          "command": "npm run build",
          "workingDir": "current",
          "terminal": false
        },
        {
          "label": "Test",
          "icon": "science",
          "command": "npm test",
          "workingDir": "current",
          "terminal": true
        }
      ]
    },
    {
      "name": "Terminal",
      "commands": [
        {
          "label": "Kitty",
          "icon": "terminal",
          "command": "kitty",
          "workingDir": "current",
          "terminal": false
        },
        {
          "label": "Lazygit",
          "icon": "commit",
          "command": "lazygit",
          "workingDir": "current",
          "terminal": true
        }
      ]
    }
  ]
}
```

---

## 5. Claude Code CLI Entegrasyonu

### 5.1 Neden Claude Code CLI?

| Özellik | Mevcut API | Claude Code CLI |
|---------|-----------|-----------------|
| Streaming | ✅ | ✅ stream-json |
| File editing | ❌ | ✅ Edit, Read, Write |
| Shell commands | ⚠️ Manuel | ✅ Built-in |
| Web search | ⚠️ Gemini only | ✅ WebSearch tool |
| MCP servers | ❌ | ✅ Full support |
| Session management | ⚠️ Manuel | ✅ Auto |
| Cost tracking | ❌ | ✅ Built-in |

### 5.2 CLI Invocation

```bash
# Non-interactive mode with streaming
claude --print --verbose --output-format stream-json --include-partial-messages "your prompt"

# With session persistence
claude --print --session-id UUID --output-format stream-json "continue conversation"

# Without session (one-shot)
claude --print --no-session-persistence "quick question"
```

### 5.3 Stream JSON Event Types

```json
// Initialization
{"type":"system","subtype":"init","session_id":"...","model":"..."}

// Text streaming
{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"text_delta","text":"chunk"}}}

// Thinking (extended thinking)
{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"thinking_delta","thinking":"..."}}}

// Completion
{"type":"result","result":"full response","total_cost_usd":0.18}
```

### 5.4 QML Implementasyonu

#### ClaudeCliStrategy.qml (Yeni Dosya)

```qml
pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string cliPath: "/home/muhammetali/.local/bin/claude"
    property string sessionId: ""
    property real totalCost: 0.0

    function buildCommand(prompt, continueSession) {
        let args = [
            root.cliPath,
            "--print",
            "--verbose",
            "--output-format", "stream-json",
            "--include-partial-messages"
        ]

        if (continueSession && sessionId.length > 0) {
            args.push("--session-id", sessionId)
        } else {
            args.push("--no-session-persistence")
        }

        return args
    }

    function parseResponseLine(line, message) {
        if (line.length === 0) return { finished: false }

        try {
            const event = JSON.parse(line)

            if (event.type === "system") {
                root.sessionId = event.session_id
                return { finished: false }
            }

            if (event.type === "stream_event") {
                const delta = event.event?.delta

                if (delta?.type === "thinking_delta") {
                    message.thinkingContent += delta.thinking
                    return { finished: false, thinking: true }
                }

                if (delta?.type === "text_delta") {
                    message.rawContent += delta.text
                    message.content += delta.text
                    return { finished: false, thinking: false }
                }
            }

            if (event.type === "result") {
                root.totalCost = event.total_cost_usd ?? 0.0
                return {
                    finished: true,
                    cost: root.totalCost,
                    usage: event.usage
                }
            }

            return { finished: false }

        } catch (e) {
            console.error("[Claude CLI] Parse error:", e)
            return { finished: false, error: e.toString() }
        }
    }

    function reset() {
        // Keep sessionId for conversation continuity
        // Clear per-request state if needed
    }
}
```

#### Ai.qml'e Eklenecek Model

```qml
// models property içine ekle
"claude-code-cli": aiModelComponent.createObject(this, {
    "name": "Claude Code (Tools)",
    "icon": "terminal-symbolic",
    "description": Translation.tr("Claude with file/code tools\nCan edit files, run commands, search web"),
    "homepage": "https://claude.ai",
    "endpoint": "local-cli",  // Special marker
    "model": "claude-code-cli",
    "requires_key": false,  // Uses system authentication
    "api_format": "claude-cli"
})

// apiStrategies'e ekle
property Component claudeCliStrategy: ClaudeCliStrategy {}
property var apiStrategies: {
    "openai": openaiApiStrategy.createObject(this),
    "gemini": geminiApiStrategy.createObject(this),
    "mistral": mistralApiStrategy.createObject(this),
    "claude-cli": claudeCliStrategy.createObject(this)
}
```

### 5.5 Avantajlar ve Dezavantajlar

#### Avantajlar
- ✅ Dosya düzenleme araçları (Edit, Read, Write)
- ✅ Shell komut çalıştırma
- ✅ Web arama
- ✅ MCP server desteği (Serena, Context7, etc.)
- ✅ Session yönetimi (konuşma sürekliliği)
- ✅ Maliyet takibi
- ✅ Plugins ecosystem

#### Dezavantajlar
- ❌ +50-100ms ek latency
- ❌ Sistem auth gerekli
- ❌ Sadece Claude modelleri

### 5.6 Hibrit Yaklaşım (Önerilen)

```
AI Backend Seçimi:
├── Simple chat → Mevcut API (Gemini, OpenAI, etc.)
├── Code assistance → Claude Code CLI
├── Local/offline → Ollama
└── Quick queries → Mevcut API
```

---

## 6. Teknik Mimari

### 6.1 Terminal Embedding Stratejisi

#### Problem
QML'de gerçek terminal embedding (PTY) mümkün değil çünkü:
- Quickshell'in Process{} sadece pipe destekliyor
- QMLTermWidget Wayland'da sınırlı
- VTE GTK tabanlı, Qt ile uyumsuz

#### Çözüm: Hyprland Scratchpad Pattern

**İnteraktif CLI araçları için (Claude Code, lazygit, htop):**

```bash
# hyprland.conf
# Dropdown terminal
bind = $mainMod, grave, togglespecialworkspace, dropdown
exec-once = foot --app-id dropdown -e tmux new-session -A -s dev

windowrulev2 = float, class:^dropdown$
windowrulev2 = workspace special:dropdown, class:^dropdown$
windowrulev2 = size 99% 50%, class:^dropdown$
windowrulev2 = move 0.5% 0%, class:^dropdown$

# Claude Code scratchpad
bind = $mainMod SHIFT, C, togglespecialworkspace, claude
exec-once = [workspace special:claude silent] foot --app-id claude -e claude

windowrulev2 = float, class:^claude$
windowrulev2 = size 60% 80%, class:^claude$
windowrulev2 = center, class:^claude$
```

**QML'den tetikleme:**

```qml
Process {
    id: scratchpadToggle
    command: ["hyprctl", "dispatch", "togglespecialworkspace", name]
    property string name: "dropdown"

    function toggle(scratchpadName) {
        name = scratchpadName
        running = true
    }
}

// Kullanım
scratchpadToggle.toggle("claude")
scratchpadToggle.toggle("lazygit")
```

**Read-only output için (build logs, git status):**

```qml
// Mevcut pattern - Process + Styled TextArea
Process {
    id: gitStatusProcess
    command: ["git", "-C", projectPath, "status", "--short", "--branch"]

    stdout: StdioCollector {
        onStreamFinished: {
            outputText = text
        }
    }
}

MaterialTextArea {
    text: gitStatusProcess.outputText
    readOnly: true
    font.family: Appearance.font.family.monospace
}
```

### 6.2 ANSI Kod Temizleme

```javascript
// QML JavaScript function
function stripAnsiCodes(str) {
    const ansiRegex = /[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g;
    return str.replace(ansiRegex, '');
}
```

### 6.3 Refresh Stratejisi

| Widget | Interval | Trigger |
|--------|----------|---------|
| Git Status | 2000ms | Auto + file change |
| Containers | 5000ms | Auto + action |
| System | 2000ms | Auto only |
| Projects | Manual | User action |

### 6.4 Memory Management

```qml
// Her dinamik obje için cleanup
Component.onDestruction: {
    if (dynamicObject) {
        dynamicObject.destroy()
        dynamicObject = null
    }
}

// Timer cleanup
Timer {
    id: refreshTimer
    running: parent.visible
    onTriggered: { /* ... */ }
}

// Connections cleanup
Connections {
    target: someService
    enabled: parent.visible  // Disable when hidden
}
```

---

## 7. Dosya Yapısı

### 7.1 Mevcut Yapı (Kaldırılacaklar İşaretli)

```
dots/.config/quickshell/ii/modules/ii/sidebarLeft/
├── SidebarLeft.qml
├── SidebarLeftContent.qml          (DÜZENLE)
├── AiChat.qml                      (DÜZENLE)
├── Anime.qml                       ❌ SİL
├── Translator.qml                  ❌ SİL
├── ApiCommandButton.qml            (koru)
├── ApiInputBoxIndicator.qml        (koru)
├── DescriptionBox.qml              (koru)
├── ScrollToBottomButton.qml        (koru)
├── aiChat/
│   ├── AiMessage.qml
│   ├── AiMessageControlButton.qml
│   ├── AnnotationSourceButton.qml
│   ├── AttachedFileIndicator.qml
│   ├── MessageCodeBlock.qml        (DÜZENLE - actions ekle)
│   ├── MessageTextBlock.qml
│   ├── MessageThinkBlock.qml
│   └── SearchQueryButton.qml
├── anime/                          ❌ SİL (tüm dizin)
│   ├── BooruImage.qml
│   └── BooruResponse.qml
└── translator/                     ❌ SİL (tüm dizin)
    ├── LanguageSelectorButton.qml
    └── TextCanvas.qml
```

### 7.2 Yeni Yapı

```
dots/.config/quickshell/ii/modules/ii/sidebarLeft/
├── SidebarLeft.qml                 (koru)
├── SidebarLeftContent.qml          (DÜZENLE - yeni tab yapısı)
├── AiChat.qml                      (DÜZENLE)
├── ApiCommandButton.qml            (koru)
├── ApiInputBoxIndicator.qml        (koru)
├── DescriptionBox.qml              (koru)
├── ScrollToBottomButton.qml        (koru)
│
├── aiChat/                         (DÜZENLE)
│   ├── AiMessage.qml
│   ├── AiMessageControlButton.qml
│   ├── AnnotationSourceButton.qml
│   ├── AttachedFileIndicator.qml
│   ├── MessageCodeBlock.qml        (DÜZENLE - action bar ekle)
│   ├── MessageTextBlock.qml
│   ├── MessageThinkBlock.qml
│   ├── SearchQueryButton.qml
│   └── CodeBlockActions.qml        (YENİ)
│
├── git/                            (YENİ)
│   ├── GitWidget.qml
│   ├── GitStatusHeader.qml
│   ├── GitFileItem.qml
│   ├── GitCommitItem.qml
│   └── GitQuickActions.qml
│
├── projects/                       (YENİ)
│   ├── ProjectSwitcher.qml
│   ├── ProjectListItem.qml
│   ├── ProjectSearch.qml
│   └── ProjectActions.qml
│
├── containers/                     (YENİ)
│   ├── ContainerPanel.qml
│   ├── ContainerListItem.qml
│   ├── ContainerActions.qml
│   └── ComposeStackItem.qml
│
├── system/                         (YENİ)
│   ├── SystemMonitor.qml
│   ├── ResourceBar.qml
│   ├── ProcessListItem.qml
│   └── NetworkIndicator.qml
│
└── quickcommands/                  (YENİ)
    ├── QuickCommands.qml
    ├── QuickCommandButton.qml
    └── CommandEditor.qml
```

### 7.3 Servis Dosyaları

```
dots/.config/quickshell/ii/services/
├── Ai.qml                          (DÜZENLE - Claude CLI ekle)
├── Booru.qml                       ❌ SİL
├── BooruResponseData.qml           ❌ SİL
├── ai/
│   ├── AiMessageData.qml
│   ├── AiModel.qml
│   ├── GeminiApiStrategy.qml
│   ├── OpenAiApiStrategy.qml
│   ├── MistralApiStrategy.qml
│   └── ClaudeCliStrategy.qml       (YENİ)
│
├── Git.qml                         (YENİ)
├── Docker.qml                      (YENİ)
├── System.qml                      (YENİ)
└── Projects.qml                    (YENİ)
```

---

## 8. Uygulama Yol Haritası

### Faz 1: Temizlik (1-2 gün)

#### Görevler

- [ ] `Anime.qml` dosyasını sil
- [ ] `Translator.qml` dosyasını sil
- [ ] `anime/` dizinini sil
- [ ] `translator/` dizinini sil
- [ ] `Booru.qml` servisini sil
- [ ] `BooruResponseData.qml` dosyasını sil
- [ ] `SidebarLeftContent.qml` düzenle (tab listesinden kaldır)
- [ ] `LeftSidebarButton.qml` düzenle (Booru referansını kaldır)
- [ ] `InterfaceConfig.qml` düzenle
- [ ] `GeneralConfig.qml` düzenle
- [ ] `QuickConfig.qml` düzenle
- [ ] `welcome.qml` düzenle
- [ ] `Directories.qml` düzenle
- [ ] 9 translation dosyasını güncelle
- [ ] **TEST:** Sidebar hatasız açılmalı

#### Doğrulama

```bash
# Quickshell'i yeniden başlat
quickshell -c ~/.config/quickshell/ii/shell.qml

# Sidebar'ı aç (Super+A)
# Sadece AI Chat tab'ı görünmeli
# Konsol hatası olmamalı
```

### Faz 2: Kritik Bug Düzeltmeleri (1 gün)

#### Görevler

- [ ] `ResourceUsage.qml:63` - `interval: 1` → `interval: 3000`
- [ ] `Network.qml:138-139` - Process respawn logic düzelt
- [ ] Memory leak audit başlat (en kritik 10 dosya)
- [ ] `Ai.qml` - 15 createObject için destroy() ekle
- [ ] `StyledListView.qml` - 13 createObject için destroy() ekle
- [ ] **TEST:** CPU kullanımı %10-15 düşmeli

#### Doğrulama

```bash
# CPU kullanımını izle
htop -p $(pgrep quickshell)

# Düzeltme öncesi: ~15-25% CPU
# Düzeltme sonrası: ~5-10% CPU
```

### Faz 3: Claude Code CLI Entegrasyonu (2-3 gün)

#### Görevler

- [ ] `ClaudeCliStrategy.qml` oluştur
- [ ] `Ai.qml`'e claude-code-cli model ekle
- [ ] Stream JSON parser implementasyonu
- [ ] Session yönetimi (sessionId tracking)
- [ ] Maliyet gösterimi (total_cost_usd)
- [ ] Error handling (stderr parsing)
- [ ] **TEST:** Claude Code sidebar'dan çalışmalı

#### Doğrulama

```bash
# CLI'ın çalıştığını doğrula
claude --print "test" --output-format json

# Sidebar'dan Claude Code seç
# Mesaj gönder, streaming yanıt gelmeli
```

### Faz 4: AI Chat Geliştirmeleri (2 gün)

#### Görevler

- [ ] `CodeBlockActions.qml` oluştur
- [ ] `MessageCodeBlock.qml` düzenle (action bar ekle)
- [ ] "Kopyala" aksiyonu implementasyonu
- [ ] "Dosyaya Uygula" aksiyonu (file picker + write)
- [ ] "Çalıştır" aksiyonu (dil algılama + terminal)
- [ ] "Açıkla" aksiyonu (AI'a gönder)
- [ ] Çoklu dosya ekleme desteği
- [ ] Dosya önizlemesi
- [ ] **TEST:** Tüm aksiyonlar çalışmalı

### Faz 5: Git Widget (2-3 gün)

#### Görevler

- [ ] `Git.qml` servis oluştur (git komut wrapper)
- [ ] `GitWidget.qml` ana component
- [ ] `GitStatusHeader.qml` (branch + ahead/behind)
- [ ] `GitFileItem.qml` (dosya listesi item)
- [ ] `GitCommitItem.qml` (commit listesi item)
- [ ] `GitQuickActions.qml` (commit/push/pull buttons)
- [ ] Stage/unstage toggle
- [ ] Quick commit fonksiyonu
- [ ] lazygit scratchpad entegrasyonu
- [ ] Auto-refresh timer
- [ ] **TEST:** Git durumu görüntülenmeli

### Faz 6: Project Switcher (2 gün)

#### Görevler

- [ ] `Projects.qml` servis oluştur (zoxide wrapper)
- [ ] `ProjectSwitcher.qml` ana component
- [ ] `ProjectListItem.qml` (proje kartı)
- [ ] `ProjectSearch.qml` (fuzzy arama)
- [ ] `ProjectActions.qml` (open/vscode/terminal buttons)
- [ ] zoxide entegrasyonu
- [ ] Favori toggle
- [ ] Proje bazlı quick commands
- [ ] **TEST:** Proje değiştirme çalışmalı

### Faz 7: Container Panel (2-3 gün)

#### Görevler

- [ ] `Docker.qml` servis oluştur (docker CLI wrapper)
- [ ] `ContainerPanel.qml` ana component
- [ ] `ContainerListItem.qml` (container kartı)
- [ ] `ContainerActions.qml` (start/stop/restart/logs/shell)
- [ ] `ComposeStackItem.qml` (compose projesi)
- [ ] Resource monitoring (CPU/RAM/Network)
- [ ] lazydocker scratchpad entegrasyonu
- [ ] Auto-refresh timer
- [ ] **TEST:** Container listesi görünmeli

### Faz 8: System Monitor (1-2 gün)

#### Görevler

- [ ] `System.qml` servis oluştur (system stats)
- [ ] `SystemMonitor.qml` ana component
- [ ] `ResourceBar.qml` (progress bar with label)
- [ ] `ProcessListItem.qml` (process kartı)
- [ ] `NetworkIndicator.qml` (upload/download)
- [ ] CPU usage + temperature
- [ ] RAM usage
- [ ] Disk usage
- [ ] Network speeds
- [ ] Top 3 processes
- [ ] htop/btop scratchpad entegrasyonu
- [ ] Auto-refresh timer
- [ ] **TEST:** Resource kullanımı görünmeli

### Faz 9: Quick Commands (1-2 gün)

#### Görevler

- [ ] `QuickCommands.qml` ana component
- [ ] `QuickCommandButton.qml` (command button)
- [ ] `CommandEditor.qml` (edit mode UI)
- [ ] `quickcommands.json` config dosyası
- [ ] Config okuma/yazma
- [ ] Komut çalıştırma (terminal/background)
- [ ] Command history
- [ ] Edit mode toggle
- [ ] **TEST:** Quick commands çalışmalı

### Faz 10: Keyboard Shortcuts (1 gün)

#### Görevler

- [ ] `SidebarLeft.qml` shortcut'ları ekle
- [ ] Tab navigation shortcuts
- [ ] Widget-specific shortcuts
- [ ] Hyprland keybinds.conf güncelle
- [ ] Scratchpad keybinds ekle
- [ ] **TEST:** Tüm shortcut'lar çalışmalı

### Faz 11: Polish & Testing (2-3 gün)

#### Görevler

- [ ] Animasyonları düzelt/optimize et
- [ ] Tema uyumluluğu kontrol
- [ ] Memory profiling
- [ ] Performance profiling
- [ ] Edge case testing
- [ ] Error handling iyileştirmeleri
- [ ] Dokümantasyon
- [ ] README güncelle
- [ ] **FINAL TEST:** Tüm özellikler stabil çalışmalı

### Toplam Süre Tahmini

| Faz | Süre |
|-----|------|
| Faz 1: Temizlik | 1-2 gün |
| Faz 2: Bug Fixes | 1 gün |
| Faz 3: Claude CLI | 2-3 gün |
| Faz 4: AI Chat | 2 gün |
| Faz 5: Git Widget | 2-3 gün |
| Faz 6: Projects | 2 gün |
| Faz 7: Containers | 2-3 gün |
| Faz 8: System | 1-2 gün |
| Faz 9: Quick Commands | 1-2 gün |
| Faz 10: Shortcuts | 1 gün |
| Faz 11: Polish | 2-3 gün |
| **TOPLAM** | **~17-24 gün** |

---

## 9. Klavye Kısayolları

### 9.1 Mevcut Sidebar Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `Super+A` | Sol sidebar toggle |
| `Ctrl+O` | Sidebar genişliğini artır |
| `Ctrl+D` | Sidebar'ı ayır (detach) |
| `Ctrl+P` | Sidebar'ı sabitle (pin) |
| `Escape` | Sidebar'ı kapat |
| `Ctrl+PageDown` | Sonraki tab |
| `Ctrl+PageUp` | Önceki tab |

### 9.2 Yeni Global Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `Ctrl+Shift+G` | Git tab'a geç |
| `Ctrl+Shift+P` | Projects tab'a geç |
| `Ctrl+Shift+D` | Containers tab'a geç |
| `Ctrl+Shift+S` | System tab'a geç |
| `Ctrl+1` | Tab 1 (AI Chat) |
| `Ctrl+2` | Tab 2 (DevTools) |
| `Ctrl+3` | Tab 3 (Projects) |
| `Ctrl+4` | Tab 4 (Containers) |
| `Ctrl+5` | Tab 5 (System) |

### 9.3 AI Chat Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `Ctrl+Shift+C` | Son code block'u kopyala |
| `Ctrl+Shift+A` | Son code block'u dosyaya uygula |
| `Ctrl+Enter` | Code block'u terminal'de çalıştır |
| `Ctrl+Shift+E` | Son code block için açıklama iste |
| `Ctrl+L` | Sohbeti temizle |
| `Ctrl+M` | Model değiştir |

### 9.4 Git Widget Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `Ctrl+K` | Quick commit (mesaj input'a focus) |
| `Ctrl+Shift+L` | lazygit aç |
| `Space` | Seçili dosyayı stage/unstage |
| `Enter` | Seçili dosyanın diff'ini göster |
| `Ctrl+Shift+P` | Push |
| `Ctrl+Shift+F` | Fetch |

### 9.5 Projects Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `Ctrl+F` | Arama fokusla |
| `Enter` | Seçili projeyi file manager'da aç |
| `Ctrl+Enter` | Seçili projeyi VSCode'da aç |
| `Ctrl+Shift+Enter` | Seçili projede terminal aç |
| `Ctrl+S` | Seçili projeyi favorilere ekle/çıkar |

### 9.6 Container Panel Shortcuts

| Shortcut | Aksiyon |
|----------|---------|
| `S` | Seçili container'ı start/stop |
| `R` | Seçili container'ı restart |
| `L` | Seçili container'ın loglarını göster |
| `Ctrl+Shift+D` | lazydocker aç |

### 9.7 Hyprland Scratchpad Shortcuts

`~/.config/hypr/hyprland.conf` veya keybinds.conf:

```bash
# Dropdown terminal
bind = $mainMod, grave, togglespecialworkspace, dropdown

# Claude Code
bind = $mainMod SHIFT, C, togglespecialworkspace, claude

# Lazygit
bind = $mainMod SHIFT, G, togglespecialworkspace, lazygit

# Lazydocker
bind = $mainMod SHIFT, D, togglespecialworkspace, lazydocker

# htop/btop
bind = $mainMod SHIFT, H, togglespecialworkspace, htop
```

---

## 10. Performans Optimizasyonları

### 10.1 Hyprland Config

```ini
# ~/.config/hypr/hyprland.conf

misc {
    vfr = true                    # Variable refresh - %30 GPU tasarrufu
    vrr = 1                       # VRR etkin (monitor destekliyorsa)
    disable_hyprland_logo = true
    disable_splash_rendering = true
    mouse_move_focuses_monitor = true
}

decoration {
    blur {
        enabled = false           # Blur = en büyük performans kaybı
        # VEYA düşük değerler:
        # enabled = true
        # size = 3
        # passes = 1
        # new_optimizations = true
    }
    drop_shadow = false           # Shadow da pahalı
    # VEYA:
    # drop_shadow = true
    # shadow_range = 4
    # shadow_render_power = 3
}

animations {
    enabled = true
    # Hızlı animasyonlar (250ms max)
    bezier = snappy, 0.2, 0.9, 0.3, 1.0
    animation = windows, 1, 3, snappy
    animation = fade, 1, 3, snappy
    animation = workspaces, 1, 3, snappy
}
```

### 10.2 QML Best Practices

#### Timer Intervals

```qml
// ❌ YANLIŞ
Timer {
    interval: 1  // 1ms = %10-15 CPU
}

// ✅ DOĞRU
Timer {
    interval: 3000  // 3 saniye yeterli
}
```

#### Loader Pattern

```qml
// ❌ YANLIŞ - Her zaman yüklü
HeavyComponent {
    visible: panelVisible  // Görünmese bile memory'de
}

// ✅ DOĞRU - Lazy loading
Loader {
    active: panelVisible
    sourceComponent: HeavyComponent {}
}
```

#### Binding Optimization

```qml
// ❌ YANLIŞ - Her frame'de hesaplama
Rectangle {
    color: calculateColor()  // Fonksiyon sürekli çağrılır
}

// ✅ DOĞRU - Sadece dependency değişince
property color cachedColor: calculateColor()
Rectangle {
    color: cachedColor
}
```

#### Memory Management

```qml
// ✅ Her createObject için destroy
Component.onDestruction: {
    if (dynamicObject) {
        dynamicObject.destroy()
        dynamicObject = null
    }
}

// ✅ Animation caching
layer.enabled: true
layer.smooth: true
```

### 10.3 Process Management

```qml
// ✅ Sadece görünürken çalıştır
Process {
    running: parent.visible && autoRefresh
}

// ✅ Output truncation
stdout: SplitParser {
    onRead: (data) => {
        output += data
        if (output.length > 10000) {
            output = output.slice(-10000)
        }
    }
}

// ✅ Debounce için timer
Timer {
    id: debounceTimer
    interval: 250
    onTriggered: actualProcess.running = true
}

function requestRefresh() {
    debounceTimer.restart()
}
```

---

## 11. Kritik Bug Düzeltmeleri

### 11.1 Timer Fix (P0)

**Dosya:** `dots/.config/quickshell/ii/services/ResourceUsage.qml`

**Satır 63:**
```qml
// ÖNCE
Timer {
    interval: 1  // 1ms = %10-15 CPU kullanımı!
    // ...
}

// SONRA
Timer {
    interval: 3000  // 3 saniye
    // ...
}
```

### 11.2 Memory Leak Fixes (P0)

**Ai.qml için:**

```qml
// Her createObject çağrısından sonra
Component.onDestruction: {
    // Message objects
    for (let id of messageIDs) {
        if (messageByID[id]) {
            messageByID[id].destroy()
        }
    }

    // Model objects
    for (let modelId of modelList) {
        if (models[modelId]) {
            models[modelId].destroy()
        }
    }

    // API strategies
    for (let key in apiStrategies) {
        if (apiStrategies[key]) {
            apiStrategies[key].destroy()
        }
    }
}
```

**StyledListView.qml için:**

```qml
// Animation objects cleanup
Connections {
    target: root

    function onVisibleChanged() {
        if (!root.visible) {
            // Clean up animation objects
            cleanupAnimations()
        }
    }
}

function cleanupAnimations() {
    for (let anim of animationObjects) {
        if (anim) anim.destroy()
    }
    animationObjects = []
}
```

### 11.3 Process Respawn Fix (P1)

**Dosya:** `dots/.config/quickshell/ii/services/Network.qml`

**Satır 138-139:**
```qml
// ÖNCE (bug)
onExited: {
    running = true  // Hemen yeniden başlatır = infinite loop riski
}

// SONRA (fix)
onExited: (exitCode, exitStatus) => {
    if (exitCode !== 0) {
        console.warn("[Network] Process exited with code:", exitCode)
    }
    // Delay before restart
    restartTimer.start()
}

Timer {
    id: restartTimer
    interval: 5000  // 5 saniye bekle
    repeat: false
    onTriggered: {
        if (shouldRun) {
            networkProcess.running = true
        }
    }
}
```

### 11.4 Script Error Handling (P2)

Tüm shell scriptlerin başına ekle:

```bash
#!/bin/bash
set -euo pipefail

# Cleanup on exit
trap 'cleanup' EXIT ERR

cleanup() {
    # Remove temp files
    rm -f /tmp/script_*.tmp 2>/dev/null || true
}

# Script content...
```

---

## 12. Mevcut Özellik Analizi (end-4'te VAR)

> ⚠️ **ÖNEMLİ:** Aşağıdaki özellikler zaten end-4/dots-hyprland'da mevcut. Bu özellikleri tekrar yazmayacağız!

### 12.1 ✅ Clipboard Manager (VAR)

**Dosya:** `services/Cliphist.qml`

| Özellik | Durum |
|---------|-------|
| cliphist entegrasyonu | ✅ |
| Fuzzy search | ✅ |
| Image support | ✅ |
| Work-safety blur (NSFW) | ✅ |
| Super+V keybind | ✅ |

```bash
# Mevcut çalışma şekli
wl-paste --watch cliphist store
cliphist list | rofi -dmenu | cliphist decode | wl-copy
```

### 12.2 ✅ Screenshot + Annotation (VAR)

**Dizin:** `modules/waffle/screenSnip/`

| Özellik | Durum |
|---------|-------|
| grim + slurp | ✅ |
| satty/swappy annotation | ✅ |
| OCR (tesseract) | ✅ |
| Google Lens search | ✅ |
| Region/window/fullscreen | ✅ |

### 12.3 ✅ Color Picker (VAR)

**Keybind:** `Super+Shift+C`

```bash
# Mevcut implementasyon
hyprpicker -a  # Auto-copy to clipboard
```

### 12.4 ✅ Music/Media Widget (VAR)

**Dosya:** `services/MprisController.qml`

| Özellik | Durum |
|---------|-------|
| MPRIS2 entegrasyonu | ✅ |
| Cava audio visualizer | ✅ |
| Cover art display | ✅ |
| SongRec music recognition | ✅ |
| Play/pause/next/prev | ✅ |

### 12.5 ✅ Quick Settings Panel (VAR)

**Dizin:** `modules/ii/sidebarRight/`

| Toggle Tipi | Durum |
|-------------|-------|
| WiFi | ✅ |
| Bluetooth | ✅ |
| Volume | ✅ |
| Brightness | ✅ |
| Night Light | ✅ |
| DND | ✅ |
| Power menu | ✅ |
| **Toplam 18 toggle** | ✅ |

### 12.6 ✅ Workspace Overview (VAR)

**Dizin:** `modules/ii/overview/`

| Özellik | Durum |
|---------|-------|
| Grid view (2x5 default) | ✅ |
| Live window thumbnails | ✅ |
| Drag-drop window management | ✅ |
| Integrated search | ✅ |
| Keyboard navigation | ✅ |

### 12.7 ✅ Keybind Viewer/Cheatsheet (VAR)

**Dosya:** `modules/ii/cheatsheet/Cheatsheet.qml`

| Özellik | Durum |
|---------|-------|
| Super+/ toggle | ✅ |
| Hierarchical display | ✅ |
| Python keybind parser | ✅ |
| Keyboard key widgets | ✅ |

### 12.8 ✅ Theme System (VAR)

**Dosya:** `~/.config/matugen/config.toml`

| Özellik | Durum |
|---------|-------|
| Matugen dynamic colors | ✅ |
| Material You (9 scheme) | ✅ |
| Wallpaper-based generation | ✅ |
| System-wide (GTK, Qt, Terminal) | ✅ |
| Dark/Light mode switching | ✅ |

### 12.9 ✅ Scratchpad (VAR - Native)

**Dosya:** `hyprland/keybinds.conf` (line 159-207)

```bash
# Native Hyprland special workspace
Super+S       # Toggle scratchpad
Super+Alt+S   # Send window to scratchpad
```

> **Not:** Pyprland scratchpads DEĞİL, native Hyprland special workspace kullanılıyor.

---

## 13. GERÇEKTEN EKSİK ÖZELLİKLER (Eklenecek)

> Bu bölüm, end-4'te OLMAYAN ve ekleyeceğimiz özellikleri listeler.

### 13.1 Launch-or-Focus Pattern ❌

**Neden Gerekli:** Omarchy'nin en sevilen özelliklerinden biri. Mevcut window'a focus veya yeni başlatma.

**Script:** `scripts/launch-or-focus.sh`

```bash
#!/bin/bash
set -euo pipefail

APP_CLASS="$1"
LAUNCH_CMD="$2"

# Check if window exists
WINDOW_ID=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$APP_CLASS\") | .address" | head -1)

if [ -n "$WINDOW_ID" ]; then
    # Focus existing window
    hyprctl dispatch focuswindow "address:$WINDOW_ID"
else
    # Launch new instance
    $LAUNCH_CMD &
fi
```

**Hyprland keybinds:**

```bash
bind = $mainMod, Return, exec, launch-or-focus.sh kitty kitty
bind = $mainMod, B, exec, launch-or-focus.sh firefox firefox
bind = $mainMod, E, exec, launch-or-focus.sh org.gnome.Nautilus nautilus
bind = $mainMod, C, exec, launch-or-focus.sh code code
```

### 13.2 Pyprland Advanced Plugins ❌

**Neden Gerekli:** Native scratchpad var ama advanced plugins (expose, layout_center, magnify) yok.

**Yüklenecek Plugins:**

| Plugin | Özellik |
|--------|---------|
| `expose` | tüm workspace'leri grid görünümünde göster |
| `layout_center` | floating window'u ortala |
| `magnify` | cursor altındaki alanı büyüt |
| `fetch_client_menu` | dmenu ile window seçici |

**Kurulum:**

```bash
pip install pyprland
# ~/.config/hypr/pyprland.toml
[pyprland]
plugins = ["expose", "layout_center", "magnify", "fetch_client_menu"]

[expose]
include_special = false

[layout_center]
margin = 60
offset = [0, 30]
```

### 13.3 Password Manager Integration ❌

**Neden Gerekli:** 1Password/Bitwarden'dan hızlı şifre kopyalama.

**rofi-1password script:**

```bash
#!/bin/bash
# 1Password CLI ile rofi entegrasyonu
op item list --format=json | jq -r '.[].title' | rofi -dmenu -p "🔐 1Password" | \
    xargs -I{} op item get "{}" --fields password | wl-copy
```

**Alternatif Bitwarden:**

```bash
#!/bin/bash
bw list items --search "$1" | jq -r '.[0].login.password' | wl-copy
```

### 13.4 System Snapshots (Timeshift/Snapper) ❌

**Neden Gerekli:** Btrfs subvolume snapshot'ları hızlı alma ve geri yükleme.

**Quick snapshot widget:**

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
    command: ["sudo", "timeshift", "--create", "--comments", "Quick snapshot from sidebar"]
}
```

### 13.5 Developer-Specific Features ❌

Bu özellikler planın 4. bölümünde detaylı anlatılıyor:

| Özellik | Durum | Bölüm |
|---------|-------|-------|
| Git Widget | ❌ Eklenecek | 4.3 |
| Project Switcher | ❌ Eklenecek | 4.4 |
| Container Panel | ❌ Eklenecek | 4.5 |
| System Monitor | ❌ Eklenecek | 4.6 |
| Quick Commands | ❌ Eklenecek | 4.7 |
| Claude Code CLI | ❌ Eklenecek | 5.0 |

---

## 14. Teknoloji Stack

### 14.1 Core

| Bileşen | Seçim | Alternatif | Neden |
|---------|-------|------------|-------|
| Compositor | Hyprland | - | Hedef platform |
| UI Framework | Quickshell (QML) | AGS | Mevcut temel |
| Shell | Zsh + Starship | Fish | Hız + özellik |
| Terminal | Kitty | Foot, Alacritty | GPU + features |
| Launcher | Rofi-wayland | Wofi | Esneklik |

### 14.2 Developer Tools

| Araç | Kullanım | Entegrasyon |
|------|----------|-------------|
| lazygit | Git TUI | Scratchpad + widget |
| lazydocker | Docker TUI | Scratchpad + widget |
| zoxide | Smart cd | Project switcher |
| fzf | Fuzzy finder | Rofi scripts |
| delta | Git diff | lazygit config |
| bat | Cat replacement | Preview scripts |
| eza | ls replacement | File browser |
| ripgrep | Fast grep | Search scripts |

### 14.3 AI Stack

| Araç | Kullanım |
|------|----------|
| Claude Code CLI | Primary AI assistant |
| Gemini API | Alternatif AI (mevcut) |
| OpenAI API | Alternatif AI (mevcut) |
| Ollama | Local LLM (mevcut) |
| Matugen | Dynamic theming |

### 14.4 Monitoring

| Araç | Kullanım |
|------|----------|
| htop / btop | Process monitor |
| nvtop | GPU monitor |
| bandwhich | Network monitor |

---

## 15. Risk Analizi

### 15.1 Potansiyel Sorunlar

| Risk | Olasılık | Etki | Mitigasyon |
|------|----------|------|------------|
| QML memory leak | Yüksek | Yüksek | Destroy() audit + ServiceManager |
| Keybind çakışması | Orta | Düşük | Conflict checker script |
| Tema tutarsızlığı | Orta | Orta | GTK/Qt sync script |
| AI latency | Düşük | Düşük | Async + timeout |
| Quickshell crash | Düşük | Yüksek | Watchdog + auto-restart |
| zoxide/docker missing | Orta | Orta | Graceful degradation |
| Git repo olmayan dizin | Yüksek | Düşük | Check before commands |

### 15.2 Breaking Changes

1. **Tab Navigation:** Anime/Translator kaldırılınca tab indeksleri değişir
2. **Config Options:** Booru/translator ayarları orphan kalır (zararsız)
3. **Translation Keys:** Kullanılmayan key'ler kalır (zararsız)
4. **Weeb Policy:** `policies.weeb` başka yerlerde kullanılıyor olabilir

### 15.3 Rollback Planı

```bash
# Git ile geri dönüş
git checkout main -- .

# Veya tag ile
git checkout v1.0-pre-fork
```

---

## 16. Referanslar

### 16.1 Dokümantasyon

- [Quickshell Documentation](https://quickshell.org/docs/)
- [Hyprland Wiki](https://wiki.hypr.land/)
- [QML Reference](https://doc.qt.io/qt-6/qmlreference.html)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

### 16.2 İlgili Projeler

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) - Temel proje
- [basecamp/omarchy](https://github.com/basecamp/omarchy) - İlham kaynağı
- [prasanthrangan/hyprdots](https://github.com/prasanthrangan/hyprdots) - HyDE
- [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
- [mylinuxforwork/dotfiles](https://github.com/mylinuxforwork/dotfiles) - ML4W

### 16.3 Araçlar

- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [matugen](https://github.com/InioX/matugen)

---

## Notlar

### Proje İsimlendirme Önerileri

- `dots-developer`
- `dots-flow`
- `hypr-dev`
- `vibe-dots`
- `code-rice`

### Lisans

Fork olarak orijinal projenin lisansına (GPL-3.0) tabi olacak.

### Katkıda Bulunanlar

- Orijinal proje: [end-4](https://github.com/end-4)
- Fork ve geliştirme: [senin-ismin]

---

*Bu döküman, 15 araştırma ajanı + 8 end-4 analiz ajanının sonuçları derlenerek hazırlanmıştır.*
*Son güncelleme: 2025-12-25 (Kapsam güncellemesi - mevcut özellik analizi eklendi)*
