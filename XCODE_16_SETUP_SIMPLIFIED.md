# 🚀 Xcode 16 Setup - VEREINFACHT (ohne iCloud)

**Für Xcode 16.x** - Funktioniert auch **OHNE iCloud Capability**!

---

## ⚡ Quick Start (10 Minuten)

### SCHRITT 1: Repo klonen
```bash
cd ~/Desktop
git clone https://github.com/hehljo/ZenOrigami-iOS.git
```

### SCHRITT 2: Xcode Projekt erstellen
1. **Xcode 16** öffnen
2. **Create New Project**
3. **iOS** → **App**
4. Einstellungen:
   - Product Name: `ZenOrigami`
   - Interface: **SwiftUI**
   - Storage: **None** ← WICHTIG!
   - Language: **Swift**
5. **Create**

### SCHRITT 3: iOS 17 Target setzen
1. Target **ZenOrigami** auswählen
2. **General** Tab
3. **Minimum Deployments:** `iOS 17.0`

### SCHRITT 4: ⚠️ WICHTIG - Dateien kopieren

**Option A: OHNE iCloud** (Empfohlen für Start)

Kopiere diese Datei:
- `LocalStorageService_NoiCloud.swift` → **UMBENNEN zu** `LocalStorageService.swift`

**Option B: MIT iCloud** (Multi-Device Sync)

Kopiere:
- `LocalStorageService.swift` (original)
- Dann: iCloud Capability hinzufügen (siehe unten)

---

## 📂 Dateien kopieren (Drag & Drop)

### Aus Repo kopieren (OHNE Supabase):

```
ZenOrigami/
├── Models/
│   └── Types.swift                  ✅
├── Config/
│   └── GameConfig.swift             ✅
├── Services/
│   └── LocalStorageService_NoiCloud.swift  ✅ → UMBENENNEN!
├── ViewModels/
│   ├── OfflineGameViewModel.swift   ✅
│   ├── FallingItemManager.swift     ✅
│   └── ScrollingWorldManager.swift  ✅
├── Utils/
│   ├── HapticFeedback.swift         ✅
│   ├── SoundManager.swift           ✅
│   ├── Logger.swift                 ✅
│   ├── AccessibilityHelpers.swift   ✅
│   └── ParticleEffects.swift        ✅
└── Views/
    ├── GameView.swift               ✅
    ├── ScrollingGameView.swift      ✅
    ├── SettingsView.swift           ✅
    ├── StatisticsView.swift         ✅
    ├── UpgradeSheetView.swift       ✅
    ├── PrestigeView.swift           ✅
    ├── DailyRewardView.swift        ✅
    ├── TutorialView.swift           ✅
    ├── WelcomeBackView.swift        ✅
    ├── FallingItemView.swift        ✅
    └── Components/
        ├── CurrencyDisplayView.swift      ✅
        ├── AchievementToastView.swift     ✅
        └── PerformanceOverlay.swift       ✅
```

**NICHT kopieren:**
- ❌ AuthView.swift
- ❌ AuthService.swift
- ❌ DatabaseService.swift
- ❌ GameViewModel.swift

---

## 📝 ZenOrigamiApp.swift erstellen

1. **Lösche:** `ZenOrigamiApp.swift` + `ContentView.swift` (von Xcode generiert)
2. **Neue Datei:** Rechtsklick → New File → Swift File → `ZenOrigamiApp.swift`
3. **Code:**

```swift
import SwiftUI

@main
struct ZenOrigamiApp: App {
    var body: some Scene {
        WindowGroup {
            OfflineRootView()
        }
    }
}

struct OfflineRootView: View {
    @State private var gameViewModel: OfflineGameViewModel?
    @AppStorage("useScrollingMode") private var useScrollingMode = true

    var body: some View {
        Group {
            if let viewModel = gameViewModel {
                if useScrollingMode {
                    ScrollingGameView(viewModel: viewModel)
                } else {
                    GameView(viewModel: viewModel)
                }
            } else {
                LoadingView()
                    .task {
                        await initializeGameViewModel()
                    }
            }
        }
    }

    @MainActor
    private func initializeGameViewModel() async {
        let storageService = LocalStorageService()
        let viewModel = OfflineGameViewModel(storageService: storageService)
        await viewModel.loadGameState()
        self.gameViewModel = viewModel
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}
```

---

## 🔧 Type Alias hinzufügen

**In `OfflineGameViewModel.swift` ganz unten:**

```swift
// MARK: - Type Alias
typealias GameViewModel = OfflineGameViewModel
```

---

## 🚀 Build & Run

1. **Clean Build Folder:** ⇧⌘K
2. **Build:** ⌘B
3. **Run:** ⌘R

**Fertig!** 🎉

---

## 🔄 Optional: iCloud später hinzufügen

### Warum iCloud?
- ✅ Sync zwischen iPhone + iPad
- ✅ Backup in der Cloud
- ✅ Automatische Wiederherstellung

### Wie hinzufügen?

**1. Capability aktivieren:**
- Target → Signing & Capabilities
- "+ Capability" → iCloud
- Aktiviere: "Key-value storage"

**2. Datei tauschen:**
- Lösche `LocalStorageService.swift`
- Kopiere das **Original** `LocalStorageService.swift` (mit iCloud)

**3. Fertig!**
- Rebuild (⌘B)
- Jetzt synct über iCloud

---

## 📊 Vergleich: Mit vs Ohne iCloud

| Feature | Ohne iCloud | Mit iCloud |
|---------|------------|-----------|
| **Funktioniert** | ✅ Ja | ✅ Ja |
| **Local Save** | ✅ Ja | ✅ Ja |
| **Multi-Device Sync** | ❌ Nein | ✅ Ja |
| **Capability nötig** | ❌ Nein | ✅ Ja |
| **Apple Dev Account** | ✅ Kostenlos OK | ⚠️ $99/Jahr nötig |
| **Code Änderung** | ✅ Keine | ✅ Keine |

**Für lokales Testen: Ohne iCloud ist perfekt!** ✅

---

## ✅ Erfolg sieht so aus:

1. **App startet** → Tutorial (6 Schritte)
2. **Sidescrolling Game** → Boot rockt, Items fallen
3. **Tap Item** → Sound + Particle Effect
4. **Upgrades kaufen** → funktioniert
5. **Settings** → Toggles funktionieren
6. **App schließen + öffnen** → Progress gespeichert ✅

---

## 🐛 Troubleshooting

### "Cannot find 'GameViewModel'"
→ Type Alias vergessen! Füge hinzu in `OfflineGameViewModel.swift`

### "No such module 'Supabase'"
→ Supabase-Dateien versehentlich kopiert. Lösche sie!

### Build schlägt fehl
→ Clean Build Folder (⇧⌘K) dann Rebuild (⌘B)

### Performance schlecht
→ Settings → Performance Overlay aktivieren → Check FPS

---

## 🎯 Nächste Schritte

1. ✅ **Testen:** Spiele 5 Minuten durch
2. ✅ **Device Test:** Auf echtem iPhone testen
3. ✅ **Assets:** Später Emojis durch PNGs ersetzen
4. ✅ **iCloud:** Optional später hinzufügen
5. ✅ **Supabase:** Optional für Cloud + Auth

---

**Viel Erfolg! Bei Fragen einfach melden!** 🚀
