# 🚀 Zen Origami - Offline-Only Setup Guide

## Xcode 16 Setup (ohne Supabase)

### SCHRITT 1: Xcode Projekt erstellen

1. **Xcode 16** öffnen
2. **Create New Project**
3. **iOS** → **App** Template
4. **Einstellungen:**
   ```
   Product Name: ZenOrigami
   Team: [Dein Apple Developer Team]
   Organization Identifier: com.[deinname]
   Interface: SwiftUI
   Language: Swift
   ```
5. **Speicherort wählen** und **Create** klicken

---

### SCHRITT 2: Projekt konfigurieren

#### General Settings
1. Target **ZenOrigami** auswählen
2. **General Tab:**
   - Minimum Deployments: **iOS 17.0**
   - Supported Destinations: iPhone, iPad

#### iCloud Capability
3. **Signing & Capabilities Tab:**
   - Klick **+ Capability**
   - Wähle **iCloud**
   - Aktiviere **Key-value storage** ✅

---

### SCHRITT 3: Ordnerstruktur erstellen

Rechtsklick auf **ZenOrigami** Ordner im Project Navigator:

Erstelle folgende **New Groups**:
```
ZenOrigami/
├── Models/
├── ViewModels/
├── Services/
├── Utils/
├── Views/
│   ├── Components/
│   └── Sheets/
└── Config/
```

---

### SCHRITT 4: Source Files hinzufügen

#### Option A: Von GitHub klonen (Empfohlen)

```bash
# Terminal öffnen
cd ~/Desktop
git clone https://github.com/[username]/ZenOrigami-iOS.git
```

Dann **Drag & Drop** folgende Ordner ins Xcode Projekt:
- `ZenOrigami/Models/` → in `Models` Group
- `ZenOrigami/Config/` → in `Config` Group
- `ZenOrigami/Utils/` → in `Utils` Group
- `ZenOrigami/Services/LocalStorageService.swift` → in `Services` Group
- `ZenOrigami/ViewModels/` (außer `OfflineGameViewModel.swift`) → in `ViewModels` Group
- `ZenOrigami/Views/` (außer `AuthView.swift`) → in `Views` Group

**WICHTIG:** Bei "Add files" Dialog:
- ✅ **Copy items if needed**
- ✅ **Create groups**
- ✅ **Add to targets: ZenOrigami**

---

### SCHRITT 5: App Entry Point ersetzen

**Lösche:** `ZenOrigamiApp.swift` (die Xcode-generierte Datei)

**Erstelle neu:** `ZenOrigamiApp.swift` mit folgendem Inhalt:

```swift
import SwiftUI

@main
struct ZenOrigamiApp: App {
    var body: some Scene {
        WindowGroup {
            OfflineContentView()
        }
    }
}

struct OfflineContentView: View {
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

### SCHRITT 6: Views anpassen

Die Views erwarten `GameViewModel`, aber wir nutzen `OfflineGameViewModel`.

#### Option A: Type Alias (Schnell & Einfach)

**In `OfflineGameViewModel.swift` ganz oben hinzufügen:**

```swift
// Type alias für View-Kompatibilität
typealias GameViewModel = OfflineGameViewModel
```

#### Option B: Views umbenennen (Sauberer)

In **jeder View** (GameView.swift, ScrollingGameView.swift, etc.):
- Suche: `GameViewModel`
- Ersetze mit: `OfflineGameViewModel`

**Beispiel:**
```swift
// Vorher:
struct GameView: View {
    @Bindable var viewModel: GameViewModel

// Nachher:
struct GameView: View {
    @Bindable var viewModel: OfflineGameViewModel
```

---

### SCHRITT 7: Build & Run

1. **Simulator wählen:** iPhone 15 Pro
2. **Product → Build** (⌘B)
3. Warten bis **Build Succeeded** ✅
4. **Product → Run** (⌘R)

---

## 🐛 Häufige Fehler

### Fehler 1: "Cannot find 'GameViewModel' in scope"
**Lösung:** Type Alias hinzufügen (siehe Schritt 6, Option A)

### Fehler 2: "Module 'Supabase' not found"
**Lösung:** Stelle sicher, dass du `AuthView.swift`, `AuthService.swift`, `DatabaseService.swift` NICHT kopiert hast

### Fehler 3: UIKit Fehler auf macOS
**Lösung:** HapticFeedback.swift hat schon `#if canImport(UIKit)` checks - sollte funktionieren

### Fehler 4: "Missing return in closure"
**Lösung:** Rebuild (⇧⌘K dann ⌘B)

---

## ✅ Erfolg!

Wenn die App läuft, solltest du sehen:
1. ✅ Tutorial Screen (6 Schritte)
2. ✅ Game View mit Boot 🚤
3. ✅ Fallende Drops 💧
4. ✅ Sidescrolling Parallax Background
5. ✅ Settings mit Sidescrolling Toggle

---

## 🎮 Nächste Schritte

1. **Testen auf echtem Device:**
   - iPhone via USB verbinden
   - Target auf dein iPhone ändern
   - Run (⌘R)

2. **Assets hinzufügen:**
   - Emojis durch PNG-Assets ersetzen
   - In `Assets.xcassets` importieren

3. **Später Supabase hinzufügen:**
   - Supabase SDK installieren
   - `AuthService.swift` + `DatabaseService.swift` hinzufügen
   - `AuthView.swift` einbauen

---

## 📦 Inhalt des Offline-Packages

- ✅ **Models/** - GameState, Currencies, Types
- ✅ **ViewModels/** - Game Logic (Offline-Version)
- ✅ **Services/** - LocalStorageService (UserDefaults + iCloud)
- ✅ **Utils/** - Haptics, Sound, Logger, Particles
- ✅ **Views/** - Alle UI Screens (außer AuthView)
- ✅ **Config/** - GameConfig, Achievement Definitions

**Keine Supabase Dependencies! ✅**

---

## 🆘 Support

Bei Problemen:
1. **Clean Build Folder:** ⇧⌘K
2. **Rebuild:** ⌘B
3. **Check Console** für Fehler
4. Schreib mir die Fehlermeldung!
