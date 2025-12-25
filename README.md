<div align="center">

# 🚀 hyprod

**Developer-Focused Hyprland Rice**

*A productivity-oriented Hyprland configuration optimized for developers and "vibe coders"*

[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.40%2B-9b59b6.svg)](https://hyprland.org)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Supported-1793d1.svg)](https://archlinux.org)
[![Quickshell](https://img.shields.io/badge/Quickshell-QML%2FQt6-41cd52.svg)](https://github.com/yshui/quickshell)

[Özellikler](#-özellikler) • [Kurulum](#-kurulum) • [Kullanım](#-kullanım) • [Katkıda Bulunma](#-katkıda-bulunma)

</div>

---

## 📖 Hakkında

**hyprod**, [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) projesinden fork edilmiş, yazılım geliştiriciler ve "vibe coderlar" için optimize edilmiş bir Hyprland dotfiles koleksiyonudur.

### 🎯 Temel Felsefe

- **Keyboard-First**: Tüm işlemler klavye ile yapılabilir
- **Developer-Centric**: Git, proje yönetimi ve AI araçları entegre
- **Performance**: Gereksiz modüller kaldırıldı, performans optimizasyonları yapıldı
- **Material You**: Dinamik renk temaları ile modern görünüm

### 🔄 end-4/dots-hyprland'dan Farklar

| Kaldırılanlar | Eklenenler |
|---------------|------------|
| ❌ Anime booru browser | ✅ Git widget |
| ❌ Translator modülü | ✅ System monitor |
| ❌ 1ms timer bug | ✅ Project switcher |
| ❌ Memory leak'ler | ✅ Quick commands |
| | ✅ Claude Code CLI entegrasyonu |

---

## ✨ Özellikler

### 🎨 Temel Özellikler

- **🎯 Launch-or-Focus**: Akıllı uygulama geçişi (açıksa focus, yoksa başlat)
- **💻 Developer Sidebar**: Git durumu, sistem monitörü, proje değiştirici
- **🤖 Claude Code CLI**: AI asistan entegrasyonu
- **🎨 Material You Theming**: Matugen ile dinamik renkler
- **⚡ Performans Optimizasyonları**: Timer düzeltmeleri ve memory leak çözümleri

### 🛠️ Developer Araçları

- **Git Widget**: Branch durumu, değişen dosyalar, hızlı commit
- **System Monitor**: CPU, RAM, Disk kullanımı
- **Project Switcher**: zoxide entegrasyonu ile proje geçişi
- **Quick Commands**: Özelleştirilebilir hızlı komutlar
- **Scratchpad Entegrasyonları**: lazygit, btop için hazır scratchpad'ler

### 🎭 Görsel Özellikler

- Material Design 3 / Material You
- Dinamik tema desteği (Matugen)
- Dark/Light mode
- Tutarlı ikonografi (Material Symbols)

---

## 📸 Ekran Görüntüleri

> *Ekran görüntüleri yakında eklenecek*

---

## 📋 Gereksinimler

### Minimum Sistem Gereksinimleri

| Bileşen | Minimum | Önerilen |
|---------|---------|-----------|
| **RAM** | 4 GB | 8+ GB |
| **CPU** | 2 core | 4+ core |
| **Disk** | 500 MB | 1 GB |
| **GPU** | Wayland uyumlu | - |

### Yazılım Gereksinimleri

- **Hyprland** 0.40+
- **Quickshell** (QML/Qt6)
- **Arch Linux** veya Arch tabanlı dağıtım (AUR erişimi)

### Bağımlılıklar

#### Temel Paketler

```bash
# Core (AUR üzerinden)
yay -S quickshell-git hyprland kitty rofi-wayland

# Developer araçları
yay -S lazygit zoxide jq ripgrep

# Opsiyonel
yay -S pyprland btop lazydocker
```

#### Fontlar

```bash
yay -S ttf-material-symbols-variable-git ttf-jetbrains-mono-nerd
```

---

## 🚀 Kurulum

### Hızlı Kurulum (Önerilen)

```bash
bash <(curl -s https://raw.githubusercontent.com/Frexxis/hyprod/main/install.sh)
```

Bu komut şunları yapar:
1. ✅ Sistem uyumluluğunu kontrol eder (Arch tabanlı + Hyprland)
2. ✅ hyprod'u `~/.local/share/hyprod` konumuna klonlar
3. ✅ Bağımlılıkları kurar ve konfigürasyonları kopyalar
4. ✅ Kurulumu doğrular

### Manuel Kurulum

```bash
# Repo'yu klonla
git clone https://github.com/Frexxis/hyprod.git
cd hyprod

# Kurulum scriptini çalıştır
./dots-hyprland/setup install
```

### Kurulum Sonrası

1. **Oturumu kapat ve tekrar giriş yap**
2. **Giriş ekranında Hyprland'ı seç**
3. **Veya zaten Hyprland'taysan:** `hyprctl reload`

> 💡 **Sorun mu yaşıyorsun?** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) dosyasına bakabilirsin.

---

## ⌨️ Kullanım

### Temel Kısayollar

| Kısayol | Aksiyon |
|---------|---------|
| `Super + Return` | Terminal (Kitty) |
| `Super + B` | Tarayıcı |
| `Super + E` | Dosya Yöneticisi |
| `Super + Tab` | Workspace Genel Bakış |
| `Super + A` | Developer Sidebar (Sol) |
| `Super + Shift + N` | Bildirimler (Sağ) |
| `Super + Q` | Pencereyi Kapat |
| `Super + Space` | Uygulama Başlatıcı |

### Developer Kısayolları

| Kısayol | Aksiyon |
|---------|---------|
| `Super + Shift + G` | lazygit (scratchpad) |
| `Super + Shift + H` | btop (scratchpad) |
| `Super + Shift + I` | Claude Code CLI |

### Sidebar Widget'ları

Sol sidebar (`Super + A`) içinde:

- **🤖 Intelligence**: AI Chat (Claude Code CLI)
- **📦 Git**: Repository durumu ve hızlı commit
- **📁 Projects**: Son projeler ve hızlı geçiş
- **⚡ Commands**: Özelleştirilebilir hızlı komutlar
- **📊 System**: Sistem kaynak kullanımı

---

## 📁 Proje Yapısı

```
hyprod/
├── .github/                    # GitHub workflows & templates
├── docs/                       # Dokümantasyon
│   ├── examples/              # Konfigürasyon örnekleri
│   └── memory-bank/           # Proje bellek bankası
├── dots-hyprland/             # Ana dotfiles klasörü
│   ├── dots/                  # Dotfiles
│   │   └── .config/
│   │       ├── hypr/         # Hyprland konfigürasyonları
│   │       ├── kitty/        # Terminal konfigürasyonu
│   │       ├── quickshell/   # QML shell (UI)
│   │       └── matugen/      # Dinamik tema
│   ├── dots-extra/           # Ekstra konfigürasyonlar
│   ├── sdata/                # Kurulum verileri
│   └── setup                 # Kurulum scripti
├── tools/                     # Yardımcı araçlar
│   ├── backup-config.sh
│   ├── doctor.sh
│   └── run-quickshell.sh
├── install.sh                 # Tek satır kurulum scripti
├── diagnose                   # Tanılama aracı
└── README.md
```

---

## 🛠️ Geliştirme

### Yerel Geliştirme Ortamı

```bash
# Repo'yu klonla
git clone https://github.com/Frexxis/hyprod.git
cd hyprod

# Feature branch oluştur
git checkout -b feature/yeni-ozellik

# Değişiklikleri test et
./dots-hyprland/setup install
hyprctl reload
```

### Test Etme

```bash
# Quickshell'i yeniden yükle
quickshell -c ~/.config/quickshell/ii/shell.qml

# Hyprland konfigürasyonunu yeniden yükle
hyprctl reload

# Hataları kontrol et
journalctl -xe | grep -E "(quickshell|hyprland)"
```

Detaylı bilgi için [CONTRIBUTING.md](./CONTRIBUTING.md) dosyasına bakabilirsin.

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen:

1. **Fork** yapın
2. **Feature branch** oluşturun (`git checkout -b feature/amazing-feature`)
3. **Commit** yapın (`git commit -m 'feat: amazing feature eklendi'`)
4. **Push** yapın (`git push origin feature/amazing-feature`)
5. **Pull Request** açın

Detaylı bilgi için [CONTRIBUTING.md](./CONTRIBUTING.md) dosyasına bakabilirsin.

---

## 📚 Dokümantasyon

- **[QUICKSTART.md](./docs/QUICKSTART.md)**: Hızlı başlangıç rehberi
- **[PRD.md](./docs/PRD.md)**: Ürün gereksinimleri dokümanı
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**: Sorun giderme rehberi
- **[CONTRIBUTING.md](./CONTRIBUTING.md)**: Katkıda bulunma rehberi

---

## 🙏 Teşekkürler

- **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**: Temel proje
- **[Quickshell](https://github.com/yshui/quickshell)**: QML shell framework
- **[Hyprland](https://hyprland.org)**: Wayland compositor
- **[lazygit](https://github.com/jesseduffield/lazygit)**: Git TUI
- **[zoxide](https://github.com/ajeetdsouza/zoxide)**: Directory jumper
- **[pyprland](https://github.com/hyprland-community/pyprland)**: Hyprland plugin sistemi

---

## 📄 Lisans

Bu proje **GPL-3.0** lisansı altında lisanslanmıştır. Detaylar için [LICENSE](./LICENSE) dosyasına bakabilirsin.

---

## ⭐ Yıldız Ver

Bu projeyi beğendiysen, yıldız vermeyi unutma! ⭐

---

<div align="center">

**Made with ❤️ for developers**

[🔝 Başa Dön](#-hyprod)

</div>
