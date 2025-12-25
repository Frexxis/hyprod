# Quickshell Services Analiz Raporu

**Analiz Tarihi:** 2025-12-25
**Klasör:** `dots/.config/quickshell/ii/services/`
**Toplam Servis:** 40+ QML dosyası

---

## Kritik Sorunlar

### 1. TimerService.qml - YÜKSEK ÖNCELİKLİ

#### Sorunlar:
- **1ms Timer Bug (Satır 110):** Stopwatch timer'ı `interval: 10` (10ms) kullanıyor. Bu çok agresif ve CPU kullanımını artırır.
- **Resource Cleanup Yok:** Component.onDestruction eksik, timer'lar temizlenmiyor.
- **Signal Handling:** Timer'lar sadece `running` property'sine bağlı, manuel stop mekanizması eksik.

#### Kod Detayları:
```qml
// Satır 108-114: Stopwatch Timer - 10ms interval çok düşük
Timer {
    id: stopwatchTimer
    interval: 10  // ← SORUN: Çok agresif
    running: root.stopwatchRunning
    repeat: true
    onTriggered: refreshStopwatch()
}

// Satır 79-85: Pomodoro Timer - 200ms daha makul
Timer {
    id: pomodoroTimer
    interval: 200  // ← DAHA İYİ
    running: root.pomodoroRunning
    repeat: true
    onTriggered: refreshPomodoro()
}
```

#### Önerilen Düzeltme:
- Stopwatch interval'ini 50-100ms'ye çıkar (kullanıcı deneyimini etkilemez)
- Component.onDestruction ekle ve timer'ları durdur

---

### 2. Network.qml - YÜKSEK ÖNCELİKLİ

#### Sorunlar:
- **Aşırı Process Spawning:** 9 farklı Process nesnesi var, hepsi potansiyel olarak paralel çalışıyor
- **Subscriber Process Leak (Satır 177-184):** `nmcli monitor` süreci sürekli çalışıyor, hiç durmuyor
- **Resource Cleanup Yok:** Component.onDestruction eksik
- **Error Recovery Minimal:** Process'ler crash olursa yeniden başlamıyor
- **Restart Logic Yok:** Kritik process'ler için watchdog mekanizması yok

#### Kod Detayları:
```qml
// Satır 177-184: Subscriber sürekli çalışıyor - KAYNAK SIZINTISI!
Process {
    id: subscriber
    running: true  // ← Hiç durmuyor!
    command: ["nmcli", "monitor"]
    stdout: SplitParser {
        onRead: root.update()  // ← Her event'te tüm process'leri tetikliyor
    }
}

// Satır 100-130: connectProc - Error handling var ama restart yok
Process {
    id: connectProc
    environment: ({ LANG: "C", LC_ALL: "C" })
    // ... error handling var
    onExited: (exitCode, exitStatus) => {
        if (root.wifiConnectTarget) {
            root.wifiConnectTarget.askingPassword = (exitCode !== 0)
        }
        root.wifiConnectTarget = null
        // ← Ama restart mekanizması yok!
    }
}
```

#### Process Listesi:
1. `enableWifiProc` (satır 100-102)
2. `connectProc` (satır 104-130)
3. `disconnectProc` (satır 132-137)
4. `changePasswordProc` (satır 139-145)
5. `rescanProcess` (satır 158-167)
6. `subscriber` (satır 177-184) ← **SÜREKLİ ÇALIŞIYOR**
7. `updateConnectionType` (satır 186-234)
8. `updateNetworkName` (satır 236-245)
9. `updateNetworkStrength` (satır 247-256)
10. `wifiStatusProcess` (satır 258-271)
11. `getNetworks` (satır 273-339)

#### Önerilen Düzeltme:
- Component.onDestruction ekle ve tüm process'leri cleanup et
- subscriber için watchdog timer ekle
- Error recovery için retry mekanizması ekle
- Process pool boyutunu sınırlandır

---

### 3. Ai.qml - ORTA ÖNCELİKLİ

#### İyi Yanlar:
- **Resource Cleanup VAR!** (Satır 371-390): Strategies ve models destroy ediliyor
- **Error Handling İyi:** API key hataları ve invalid responses yakalanıyor

#### Sorunlar:
- **Process Cleanup Eksik:** `requester`, `commandExecutionProc`, `getOllamaModels` cleanup edilmiyor
- **Memory Leak Riski:** Message'lar için partial cleanup (removeMessage var ama Component.onDestruction'da kullanılmıyor)
- **Error Recovery Minimal:** Process crash'leri için genel mekanizma yok

#### Kod Detayları:
```qml
// Satır 371-390: Model ve Strategy Cleanup - İYİ ÖRNEK!
Component.onDestruction: {
    // Destroy API strategies
    const strategies = Object.values(apiStrategies || {});
    strategies.forEach(strategy => {
        if (strategy && strategy.destroy) strategy.destroy();
    });

    // Destroy all model objects to prevent memory leaks
    const modelObjects = Object.values(models || {});
    modelObjects.forEach(model => {
        if (model && model.destroy) model.destroy();
    });

    // Destroy all message objects
    const ids = messageIDs || [];
    ids.forEach(id => {
        const message = messageByID[id];
        if (message && message.destroy) message.destroy();
    });
}

// ← SORUN: Process'ler cleanup edilmiyor!
Process { id: requester ... }  // Satır 666
Process { id: commandExecutionProc ... }  // Satır 881
Process { id: getOllamaModels ... }  // Satır 437
```

#### Önerilen Düzeltme:
- Component.onDestruction'a process cleanup ekle
- Process'ler için timeout mekanizması ekle

---

### 4. HyprlandData.qml - ORTA ÖNCELİKLİ

#### Sorunlar:
- **Aggressive Update Pattern (Satır 86-94):** Her Hyprland event'inde `updateAll()` çağrılıyor
- **Process Spam:** 4 ayrı `hyprctl` komutu her event'te çalışıyor
- **Resource Cleanup Yok:** Component.onDestruction eksik
- **Error Handling Yok:** Process'ler fail olursa sessizce ignore ediliyor

#### Kod Detayları:
```qml
// Satır 86-94: HER EVENT'TE TÜM PROCESS'LER TETİKLENİYOR!
Connections {
    target: Hyprland
    function onRawEvent(event) {
        if (["openlayer", "closelayer", "screencast"].includes(event.name)) return;
        updateAll()  // ← Her event'te 4 process spawn!
    }
}

// Satır 66-71: updateAll() fonksiyonu
function updateAll() {
    updateWindowList();   // ← hyprctl clients -j
    updateMonitors();     // ← hyprctl monitors -j
    updateLayers();       // ← hyprctl layers -j
    updateWorkspaces();   // ← hyprctl workspaces -j + activeworkspace -j
}
```

#### Process Listesi:
1. `getClients` (satır 96-112)
2. `getMonitors` (satır 114-123)
3. `getLayers` (satır 125-134)
4. `getWorkspaces` (satır 136-152)
5. `getActiveWorkspace` (satır 154-163)

#### Önerilen Düzeltme:
- Debounce mekanizması ekle (500ms delay)
- Process'leri cleanup et
- Error handling ekle
- Sadece değişen verileri update et (differential updates)

---

### 5. Diğer Servisler - DÜŞÜK-ORTA ÖNCELİKLİ

#### ResourceUsage.qml
**Sorunlar:**
- Timer cleanup yok (satır 62-98)
- FileView cleanup yok (satır 100-101)
- findCpuMaxFreqProc cleanup yok (satır 103-117)

```qml
Timer { interval: 3000; running: true; repeat: true ... }  // ← Hiç durmuyor
FileView { id: fileMeminfo; path: "/proc/meminfo" }  // ← Cleanup yok
FileView { id: fileStat; path: "/proc/stat" }  // ← Cleanup yok
```

#### Wallpapers.qml
**Sorunlar:**
- FolderListModel cleanup yok (satır 128-145)
- Process'ler cleanup yok: `applyProc`, `selectProc`, `validateDirProc`, `thumbgenProc`
- FileView cleanup yok (satır 511-519: promptLoader)

#### SongRec.qml
**Sorunlar:**
- Process cleanup yok: `recognizeMusicProc`, `musicReconizedProc`
- `manuallyStopped` flag hacky bir çözüm (satır 45, 67-70)

#### Cliphist.qml
**Sorunlar:**
- Process cleanup yok: `deleteProc`, `wipeProc`, `readProc`
- Timer cleanup yok: `delayedUpdateTimer` (satır 120-127)

#### Git.qml
**Sorunlar:**
- 7 Process cleanup yok: `checkAvailabilityProc`, `checkRepoProc`, `statusProc`, `logProc`, `stageProc`, `unstageProc`, `commitProc`, `diffProc`
- Error handling iyi ama restart logic yok

#### LauncherSearch.qml
**Sorunlar:**
- Timer cleanup yok: `nonAppResultsTimer` (satır 133-143)
- Process cleanup yok: `mathProc` (satır 145-158)

#### Translation.qml
**Sorunlar:**
- Process cleanup yok: `scanLanguagesProcess`, `scanGeneratedLanguagesProcess`

#### ConflictKiller.qml
**Sorunlar:**
- Process cleanup yok: `checkConflictsProc`

---

## Genel Sorunlar ve Pattern'lar

### 1. Resource Cleanup
**Durum:** %95 serviste Component.onDestruction eksik
**Etki:** Memory leaks, zombie process'ler, resource exhaustion
**İstisna:** Sadece `Ai.qml` partial cleanup yapıyor

### 2. Process Management
**Sorunlar:**
- Process'ler hiç cleanup edilmiyor
- Running process'lerin sayısı takip edilmiyor
- Process pool limiti yok
- Zombie process riski yüksek

**Etkilenen Servisler:**
- Network.qml: 11 process
- Ai.qml: 6+ process
- HyprlandData.qml: 5 process
- Git.qml: 8 process
- Wallpapers.qml: 4 process

### 3. Timer Management
**Sorunlar:**
- Timer'lar hiç stop edilmiyor
- Cleanup mekanizması yok
- Interval değerleri optimize edilmemiş

**Etkilenen Servisler:**
- TimerService.qml: 2 timer
- ResourceUsage.qml: 1 timer
- Cliphist.qml: 1 timer
- LauncherSearch.qml: 1 timer
- Network.qml: 1 timer (reconnectAfterPasswordTimer)

### 4. Signal Handling
**Sorunlar:**
- Sadece `onExited` signal'i kullanılıyor
- `onStarted`, `onError` signal'leri nadiren kullanılıyor
- Custom signal'ler minimal (Ai.qml'de `responseFinished` var)

### 5. Error Recovery
**Sorunlar:**
- Error handling çoğunlukla log/ignore pattern'i
- Retry mekanizması neredeyse hiç yok
- Fallback stratejileri minimal
- Watchdog mekanizması yok

### 6. Restart Logic
**Sorunlar:**
- Process'ler crash olursa yeniden başlamıyor
- Kritik servisler için watchdog yok
- Health check mekanizması yok

---

## Öncelikli Düzeltmeler

### YÜKSEK ÖNCELİK
1. **Network.qml:** subscriber process leak'ini düzelt
2. **TimerService.qml:** stopwatch interval'ini optimize et
3. **HyprlandData.qml:** Event flood'unu düzelt (debounce ekle)
4. **Tüm Servisler:** Component.onDestruction ekle

### ORTA ÖNCELİK
5. **Process Cleanup:** Tüm Process'ler için cleanup ekle
6. **Timer Cleanup:** Tüm Timer'lar için stop mekanizması ekle
7. **Error Recovery:** Kritik process'ler için retry mekanizması ekle

### DÜŞÜK ÖNCELİK
8. **Watchdog:** Kritik servisler için health check ekle
9. **Process Pool:** Global process limiti ekle
10. **Monitoring:** Resource usage monitoring ekle

---

## Örnek Düzeltme Pattern'leri

### Pattern 1: Basic Cleanup
```qml
Singleton {
    id: root

    // ... existing code ...

    Component.onDestruction: {
        // Stop timers
        myTimer.stop();

        // Stop processes
        myProcess.running = false;

        // Cleanup objects
        if (myObject && myObject.destroy) {
            myObject.destroy();
        }
    }
}
```

### Pattern 2: Process Watchdog
```qml
Process {
    id: criticalProcess
    property int restartCount: 0
    property int maxRestarts: 3

    onExited: (exitCode, exitStatus) => {
        if (exitCode !== 0 && restartCount < maxRestarts) {
            restartCount++;
            restartTimer.restart();
        }
    }
}

Timer {
    id: restartTimer
    interval: 1000
    onTriggered: criticalProcess.running = true
}
```

### Pattern 3: Debounce Events
```qml
Timer {
    id: debounceTimer
    interval: 500
    repeat: false
    onTriggered: actualUpdate()
}

function update() {
    debounceTimer.restart();  // Debounce
}
```

---

## Sonuç

**Toplam Servis:** 40+
**Kritik Sorun:** 3 (TimerService, Network, HyprlandData)
**Orta Sorun:** 15+
**Genel Sorun:** Resource cleanup eksikliği tüm servislerde mevcut

**Önerilen Aksiyon:**
1. Önce kritik 3 servisi düzelt
2. Sonra tüm servislere Component.onDestruction ekle
3. Son olarak error recovery ve watchdog mekanizmaları ekle

**Tahmini Düzeltme Süresi:**
- Kritik düzeltmeler: 2-3 saat
- Tüm cleanup'lar: 1-2 gün
- Error recovery: 2-3 gün
