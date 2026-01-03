# 📥 Download & Setup - Zen Origami Offline

## Schnellstart (3 Optionen)

### Option 1: GitHub Clone (Empfohlen)

```bash
# Terminal auf deinem Mac
cd ~/Desktop
git clone https://github.com/[dein-username]/ZenOrigami-iOS.git
cd ZenOrigami-iOS
```

**Dann:** Öffne `OFFLINE_SETUP/SETUP_GUIDE.md` und folge den Schritten!

---

### Option 2: ZIP Download vom Server

Wenn du SSH-Zugriff hast:

```bash
# Vom Server (wo ich laufe):
cd /root/ZenOrigami-iOS/OFFLINE_SETUP
scp ZenOrigami-Offline.tar.gz [user]@[your-mac]:~/Desktop/

# Auf deinem Mac:
cd ~/Desktop
tar -xzf ZenOrigami-Offline.tar.gz
```

---

### Option 3: Dateien einzeln kopieren

Falls du nur spezifische Files brauchst:

#### Benötigte Dateien (27 Files):

**Models/** (3 Dateien):
- `Types.swift`
- `GameConfig.swift`

**ViewModels/** (4 Dateien):
- `OfflineGameViewModel.swift` ← WICHTIG!
- `FallingItemManager.swift`
- `ScrollingWorldManager.swift`

**Services/** (1 Datei):
- `LocalStorageService.swift`

**Utils/** (6 Dateien):
- `HapticFeedback.swift`
- `SoundManager.swift`
- `Logger.swift`
- `AccessibilityHelpers.swift`
- `ParticleEffects.swift`
- `PerformanceMonitor.swift`

**Views/** (12 Dateien):
- `GameView.swift`
- `ScrollingGameView.swift`
- `SettingsView.swift`
- `StatisticsView.swift`
- `UpgradeSheetView.swift`
- `PrestigeView.swift`
- `DailyRewardView.swift`
- `TutorialView.swift`
- `WelcomeBackView.swift`
- `FallingItemView.swift`

**Views/Components/** (3 Dateien):
- `CurrencyDisplayView.swift`
- `AchievementToastView.swift`
- `PerformanceOverlay.swift`

**NICHT kopieren (Supabase-abhängig):**
- ❌ `AuthView.swift`
- ❌ `AuthService.swift`
- ❌ `DatabaseService.swift`
- ❌ `GameViewModel.swift` (brauchen wir nicht, nutzen OfflineGameViewModel)

---

## 📂 Ziel-Ordnerstruktur in Xcode

```
ZenOrigami/                    ← Xcode Projekt Root
├── ZenOrigamiApp.swift        ← NEU ERSTELLEN (siehe SETUP_GUIDE.md)
├── ContentView.swift          ← LÖSCHEN (nicht gebraucht)
├── Models/
│   ├── Types.swift
│   └── GameConfig.swift
├── ViewModels/
│   ├── OfflineGameViewModel.swift
│   ├── FallingItemManager.swift
│   └── ScrollingWorldManager.swift
├── Services/
│   └── LocalStorageService.swift
├── Utils/
│   ├── HapticFeedback.swift
│   ├── SoundManager.swift
│   ├── Logger.swift
│   ├── AccessibilityHelpers.swift
│   ├── ParticleEffects.swift
│   └── PerformanceMonitor.swift
└── Views/
    ├── GameView.swift
    ├── ScrollingGameView.swift
    ├── SettingsView.swift
    ├── StatisticsView.swift
    ├── UpgradeSheetView.swift
    ├── PrestigeView.swift
    ├── DailyRewardView.swift
    ├── TutorialView.swift
    ├── WelcomeBackView.swift
    ├── FallingItemView.swift
    └── Components/
        ├── CurrencyDisplayView.swift
        ├── AchievementToastView.swift
        └── PerformanceOverlay.swift
```

---

## ✅ Nach dem Kopieren

1. **Öffne:** `OFFLINE_SETUP/SETUP_GUIDE.md`
2. **Folge:** Schritt 1-7
3. **Build & Run!**

---

## 🆘 Probleme?

**Fehler:** "Cannot find type 'GameViewModel'"
**Fix:** In `OfflineGameViewModel.swift` ganz oben hinzufügen:
```swift
typealias GameViewModel = OfflineGameViewModel
```

**Fehler:** "Module 'Supabase' not found"
**Fix:** Du hast versehentlich Supabase-Dateien kopiert. Entferne:
- AuthView.swift
- AuthService.swift
- DatabaseService.swift

**Fehler:** Build schlägt fehl
**Fix:**
1. Clean Build Folder (⇧⌘K)
2. Rebuild (⌘B)
3. Schick mir die Fehlermeldung!

---

## 📊 Dateigröße

- **Komplett-Package:** 29 KB (tar.gz)
- **Entpackt:** ~150 KB Swift Source
- **Keine Dependencies:** 0 externe SDKs nötig!

---

## 🚀 Nächste Schritte

Nach erfolgreichem Build:
1. ✅ App auf Simulator testen
2. ✅ App auf Device testen (via USB)
3. ✅ Features durchspielen (Tutorial, Upgrades, Prestige)
4. ✅ Performance prüfen (FPS Overlay in Settings)
5. ✅ Später: Assets hinzufügen (Emojis → PNGs)
6. ✅ Optional: Supabase nachträglich integrieren
