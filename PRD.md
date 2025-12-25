# Product Requirements Document (PRD)

## hyprod: Developer-Focused Hyprland Rice

**Versiyon:** 1.0
**Tarih:** 2025-12-25
**Yazar:** Developer
**Durum:** Draft

---

## 1. Executive Summary

### 1.1 Problem Statement

Mevcut Hyprland rice'ları (dotfiles) genellikle estetik odaklı olup, yazılımcıların günlük iş akışına yönelik araçlar sunmuyor. end-4/dots-hyprland (illogical-impulse) güçlü bir temel sunuyor ancak:

- Anime booru browser, Translator gibi developer'lar için gereksiz modüller içeriyor
- Git, Docker, proje yönetimi gibi developer araçları eksik
- Claude Code CLI gibi modern AI araçları entegre değil
- Performans sorunları var (1ms timer, memory leak'ler)

### 1.2 Solution

**hyprod:** end-4/dots-hyprland fork'u olarak, yazılımcılar ve "vibe coderlar" için optimize edilmiş, AI-destekli, performanslı bir Hyprland rice.

### 1.3 Success Metrics

| Metrik | Hedef |
|--------|-------|
| CPU kullanımı azalması | >%10 |
| Gereksiz kod kaldırma | >1,500 satır |
| Yeni developer özellik | 5+ |
| Daily driver stability | 7+ gün kesintisiz |
| User satisfaction | 4/5 stars |

---

## 2. Target Users

### 2.1 Primary Persona: "Vibe Coder"

**Profil:**
- Yaş: 20-35
- Meslek: Software Developer, DevOps, SRE
- OS: Arch Linux, NixOS, Fedora
- Deneyim: Linux 2+ yıl, Hyprland 3+ ay

**İhtiyaçlar:**
- Hızlı workspace/window switching
- Git status'ü göz ucuyla görebilme
- Terminale hızlı erişim (scratchpad)
- AI assistant entegrasyonu
- Estetik ama fonksiyonel UI

**Pain Points:**
- Mouse kullanmak zorunda kalmak
- Context switch yapmak
- Araçlar arası geçiş kaybı
- Terminal dışında bilgi alamama

### 2.2 Secondary Persona: "System Tinkerer"

**Profil:**
- Ricing meraklısı
- Dotfiles özelleştirme uzmanı
- Performance-obsessed

**İhtiyaçlar:**
- Kolay özelleştirilebilirlik
- Düşük resource kullanımı
- Temiz, modüler kod

---

## 3. Features

### 3.1 Core Features (Must Have - P0)

#### 3.1.1 Temizlik & Optimizasyon

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| Anime modülü kaldırma | Booru browser tamamen kaldırılır | Sidebar'da Anime tab'ı yok |
| Translator modülü kaldırma | Çeviri widget'ı kaldırılır | Sidebar'da Translator tab'ı yok |
| Timer fix | 1ms timer → 3000ms | CPU usage <%10 |
| Memory leak fix | createObject cleanup | RAM stable 24 saat |

#### 3.1.2 Launch-or-Focus

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| App focus/launch | Varsa focus, yoksa başlat | Super+Return → kitty focus veya aç |
| Multi-app support | Her app için çalışır | Firefox, VSCode, Nautilus |

### 3.2 Developer Features (Should Have - P1)

#### 3.2.1 Git Widget

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| Branch display | Current branch göster | Branch ismi görünür |
| Changed files | Modified/staged files | Liste doğru |
| Quick commit | Mesaj + commit butonu | Commit yapılabiliyor |
| lazygit entegrasyon | Scratchpad'de aç | Super+Shift+G çalışıyor |

#### 3.2.2 System Monitor

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| CPU bar | Kullanım yüzdesi | Gerçek zamanlı |
| RAM bar | Kullanım yüzdesi | Gerçek zamanlı |
| Disk bar | Kullanım yüzdesi | Doğru değer |
| btop entegrasyon | Scratchpad'de aç | Super+Shift+H çalışıyor |

#### 3.2.3 Project Switcher

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| Recent projects | zoxide listesi | Son 10 proje |
| Fuzzy search | İsim ile arama | Arama çalışıyor |
| Quick actions | Terminal, VSCode, FM | Butonlar çalışıyor |

### 3.3 AI Features (Nice to Have - P2)

#### 3.3.1 Claude Code CLI

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| Model selection | Claude Code seçimi | Dropdown'da görünür |
| Streaming response | Real-time yanıt | Chunk'lar geliyor |
| Session persistence | Konuşma sürekliliği | --session-id kullanımı |
| Cost tracking | Maliyet gösterimi | USD gösteriliyor |

#### 3.3.2 Code Block Actions

| Feature | Açıklama | Acceptance Criteria |
|---------|----------|---------------------|
| Copy | Panoya kopyala | Buton çalışıyor |
| Apply to file | Dosyaya yaz | File picker açılıyor |
| Run in terminal | Komut çalıştır | Terminal açılıyor |

### 3.4 Extra Features (Could Have - P3)

| Feature | Öncelik | Açıklama |
|---------|---------|----------|
| Password Manager | P3 | 1Password/Bitwarden rofi |
| Container Panel | P3 | Docker container listesi |
| System Snapshots | P3 | Timeshift quick snapshot |
| Quick Commands | P2 | Özelleştirilebilir komutlar |

---

## 4. Technical Requirements

### 4.1 Technology Stack

| Bileşen | Teknoloji | Versiyon |
|---------|-----------|----------|
| Compositor | Hyprland | 0.40+ |
| UI Framework | Quickshell (QML/Qt6) | Latest |
| Shell | Zsh + Starship | - |
| Terminal | Kitty | 0.30+ |
| Launcher | Rofi-wayland | - |

### 4.2 Dependencies

**Required:**
```bash
# Core
quickshell-git hyprland

# Developer tools
lazygit zoxide

# Utilities
jq ripgrep
```

**Optional:**
```bash
# Enhanced features
lazydocker btop glances
pyprland
1password-cli OR bitwarden-cli
timeshift
```

### 4.3 System Requirements

| Kaynak | Minimum | Önerilen |
|--------|---------|----------|
| RAM | 4 GB | 8+ GB |
| CPU | 2 core | 4+ core |
| Disk | 500 MB | 1 GB |
| GPU | Any (Wayland uyumlu) | - |

### 4.4 Performance Requirements

| Metrik | Hedef |
|--------|-------|
| Idle CPU | <5% |
| Idle RAM | <200 MB |
| Sidebar açılış | <100ms |
| Widget refresh | <50ms |

---

## 5. User Experience

### 5.1 Keyboard-First Design

Tüm özellikler keyboard ile erişilebilir olmalı:

| Kategori | Örnek Keybind |
|----------|---------------|
| App launch | Super+Return, Super+B |
| Sidebar | Super+A |
| Git | Super+Shift+G (lazygit) |
| System | Super+Shift+H (btop) |
| AI | Super+Shift+I (claude) |

### 5.2 Visual Consistency

- Material Design 3 / Material You
- Matugen dynamic theming
- Dark/Light mode support
- Consistent iconography (Material Symbols)

### 5.3 Information Architecture

```
Sol Sidebar
├── Intelligence (AI Chat)
├── Git (Repository status)
├── Projects (Recent directories)
├── Commands (Quick actions)
└── System (Resource monitor)

Sağ Sidebar (Mevcut - değişmeyecek)
├── Quick Settings
├── Notifications
└── Calendar
```

---

## 6. Non-Functional Requirements

### 6.1 Reliability

- 7+ gün kesintisiz çalışma
- Graceful degradation (git/docker yoksa hata vermemeli)
- Auto-restart capability

### 6.2 Maintainability

- Modüler kod yapısı
- Component-based architecture
- Clear separation of concerns
- Inline documentation

### 6.3 Compatibility

- Hyprland 0.40+
- Qt6 / QML
- Wayland only (X11 desteği yok)
- Arch Linux, Fedora, NixOS

### 6.4 Security

- No hardcoded secrets
- Secure clipboard handling
- Safe shell command execution
- No telemetry

---

## 7. Constraints & Assumptions

### 7.1 Constraints

| Constraint | Açıklama |
|------------|----------|
| QML Terminal | Gerçek terminal embed mümkün değil, scratchpad pattern kullanılacak |
| Claude CLI | System auth gerekli, sadece Claude modelleri |
| Wayland only | X11 desteği yok |
| Quickshell | AGS/Eww'ye geçiş yok |

### 7.2 Assumptions

- Kullanıcı Hyprland deneyimli
- Git, terminal bilgisi var
- Arch-based distro (AUR erişimi)
- Modern hardware (2020+)

### 7.3 Out of Scope

| Feature | Neden |
|---------|-------|
| GUI installer | Dotfiles manuel kurulur |
| Multi-compositor | Sadece Hyprland |
| Mobile support | Desktop only |
| Windows/macOS | Linux only |
| Embedded terminal | QML limitation |

---

## 8. Risks & Mitigations

| Risk | Olasılık | Etki | Mitigasyon |
|------|----------|------|------------|
| Quickshell API değişikliği | Orta | Yüksek | Pinned version |
| Upstream breaking changes | Orta | Orta | Selective merge |
| Claude CLI deprecation | Düşük | Yüksek | Fallback to API |
| Performance regression | Orta | Orta | Profiling & monitoring |
| Community adoption | Orta | Düşük | Good documentation |

---

## 9. Success Criteria

### 9.1 MVP (Minimum Viable Product)

Faz 1-4 tamamlandığında:
- [x] Anime/Translator kaldırıldı
- [x] Bug'lar düzeltildi
- [x] Launch-or-focus çalışıyor
- [x] Git widget (basit) var
- [x] System monitor var

### 9.2 Full Release (v1.0)

Faz 1-8 tamamlandığında:
- [x] Tüm MVP özellikleri
- [x] Project Switcher
- [x] Quick Commands
- [x] Claude Code CLI
- [x] Code Block Actions
- [x] Documentation
- [x] 7 gün stability test geçti

### 9.3 Metrics

| Metrik | MVP Hedefi | v1.0 Hedefi |
|--------|------------|-------------|
| Features | 5 | 10+ |
| Stability | 3 gün | 7+ gün |
| CPU idle | <10% | <5% |
| RAM idle | <300 MB | <200 MB |
| Code removed | 1,500 satır | 2,000 satır |
| Code added | 500 satır | 2,000 satır |

---

## 10. Timeline Overview

| Faz | Adı | Durum |
|-----|-----|-------|
| 1 | Proje Kurulumu | Bekliyor |
| 2 | Temizlik & Bug Fix | Bekliyor |
| 3 | Launch-or-Focus & Pyprland | Bekliyor |
| 4 | Developer Sidebar - Temel | Bekliyor |
| 5 | Developer Sidebar - Gelişmiş | Bekliyor |
| 6 | AI & Claude Code CLI | Bekliyor |
| 7 | Ek Özellikler | Bekliyor |
| 8 | Polish & Release | Bekliyor |

---

## 11. Appendix

### A. Competitor Analysis

| Proje | Artılar | Eksiler |
|-------|---------|---------|
| end-4/dots-hyprland | Estetik, feature-rich | Anime/Translator bloat, bugs |
| HyDE | Kolay kurulum | Daha az özelleştirilebilir |
| ML4W | Minimalist | Az özellik |
| Omarchy | Launch-or-focus | macOS odaklı design |

### B. Reference Repositories

| Repo | URL | Kullanım |
|------|-----|----------|
| end-4/dots-hyprland | [GitHub](https://github.com/end-4/dots-hyprland) | Base project |
| pyprland | [GitHub](https://github.com/hyprland-community/pyprland) | Plugins |
| lazygit | [GitHub](https://github.com/jesseduffield/lazygit) | Git TUI |
| lazydocker | [GitHub](https://github.com/jesseduffield/lazydocker) | Docker TUI |
| zoxide | [GitHub](https://github.com/ajeetdsouza/zoxide) | Directory jumper |
| awesome-hyprland | [GitHub](https://github.com/hyprland-community/awesome-hyprland) | Tools list |

### C. Glossary

| Terim | Açıklama |
|-------|----------|
| Rice | Linux masaüstü özelleştirmesi |
| Dotfiles | Konfigürasyon dosyaları |
| Quickshell | QML tabanlı shell framework |
| Scratchpad | Dropdown/toggle edilebilir pencere |
| Vibe Coder | Estetik ve UX'e önem veren developer |

---

*Son güncelleme: 2025-12-25*
