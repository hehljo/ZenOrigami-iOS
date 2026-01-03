# 🚀 Zen Origami - Xcode Offline Setup (KOMPLETT)

**Ziel:** Spielbares Idle Game ohne Supabase in 10 Minuten!

---

## SCHRITT 1: Repository klonen

```bash
# Terminal auf deinem Mac:
cd ~/Desktop
git clone https://github.com/[dein-username]/ZenOrigami-iOS.git
cd ZenOrigami-iOS
```

---

## SCHRITT 2: Xcode Projekt erstellen

1. **Xcode 16** öffnen
2. **Create New Project**
3. **iOS** → **App** Template auswählen
4. **Einstellungen:**
   ```
   Product Name: ZenOrigami
   Team: [Dein Apple Developer Team]
   Organization Identifier: com.[deinname]
   Bundle Identifier: com.[deinname].ZenOrigami
   Interface: SwiftUI ✅
   Language: Swift ✅
   Storage: None
   ```
5. **Speicherort:** `~/Desktop/ZenOrigami-Xcode` (NICHT ins Git-Repo!)
6. **Create** klicken

---

## SCHRITT 3: Projekt konfigurieren

### 3.1 iOS Target einstellen
1. Target **ZenOrigami** auswählen (linke Sidebar)
2. **General Tab:**
   - **Minimum Deployments:** `iOS 17.0`
   - **Supported Destinations:** iPhone, iPad

### 3.2 iCloud Capability hinzufügen
1. **Signing & Capabilities Tab**
2. Klick **+ Capability**
3. Wähle **iCloud**
4. Aktiviere: **Key-value storage** ✅

---

## SCHRITT 4: Ordnerstruktur erstellen

Rechtsklick auf **ZenOrigami** Ordner (im Project Navigator):

Erstelle **New Groups**:
- `Models`
- `ViewModels`
- `Services`
- `Utils`
- `Views`
  - `Components` (Sub-Group)
- `Config`

---

## SCHRITT 5: Dateien ins Projekt kopieren

### 5.1 Finder öffnen
```bash
# Terminal:
open ~/Desktop/ZenOrigami-iOS/ZenOrigami
```

### 5.2 Drag & Drop in Xcode

**WICHTIG:** Kopiere ALLE Dateien **AUSSER**:
- ❌ `AuthView.swift`
- ❌ `AuthService.swift`
- ❌ `DatabaseService.swift`
- ❌ `GameViewModel.swift`
- ❌ `ContentView.swift`
- ❌ `ZenOrigamiApp.swift` (die alte Version)

**Kopiere folgende Dateien:**

#### Models/ → Models Group
- `Types.swift`

#### Config/ → Config Group
- `GameConfig.swift`

#### Services/ → Services Group
- `LocalStorageService.swift`

#### ViewModels/ → ViewModels Group
- `OfflineGameViewModel.swift` ✅ **WICHTIG!**
- `FallingItemManager.swift`
- `ScrollingWorldManager.swift`

#### Utils/ → Utils Group
- `HapticFeedback.swift`
- `SoundManager.swift`
- `Logger.swift`
- `AccessibilityHelpers.swift`
- `ParticleEffects.swift`

#### Views/ → Views Group
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

#### Views/Components/ → Views/Components Group
- `CurrencyDisplayView.swift`
- `AchievementToastView.swift`
- `PerformanceOverlay.swift`

**Beim Drag & Drop Dialog:**
- ✅ **Copy items if needed**
- ✅ **Create groups**
- ✅ **Add to targets: ZenOrigami**

---

## SCHRITT 6: Entry Point erstellen

### 6.1 Alte Datei löschen
- Rechtsklick auf `ZenOrigamiApp.swift` (von Xcode generiert)
- **Delete** → **Move to Trash**

- Rechtsklick auf `ContentView.swift`
- **Delete** → **Move to Trash**

### 6.2 Neue Datei erstellen

1. Rechtsklick auf **ZenOrigami** Ordner (root)
2. **New File** → **Swift File**
3. Name: `ZenOrigamiApp.swift`
4. **Create**

5. **Inhalt ersetzen mit:**

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

## SCHRITT 7: Type Alias hinzufügen

**Problem:** Views erwarten `GameViewModel`, aber wir nutzen `OfflineGameViewModel`

**Lösung:** Type Alias!

1. Öffne `OfflineGameViewModel.swift`
2. Scrolle **ganz nach unten**
3. Füge hinzu (nach der letzten `}`, ganz am Ende):

```swift
// MARK: - Type Alias für View-Kompatibilität
typealias GameViewModel = OfflineGameViewModel
```

4. **Save** (⌘S)

---

## SCHRITT 8: Build & Run! 🚀

1. **Simulator wählen:** iPhone 15 Pro (oder dein Device)
2. **Product** → **Clean Build Folder** (⇧⌘K)
3. **Product** → **Build** (⌘B)
4. Warten auf **Build Succeeded** ✅
5. **Product** → **Run** (⌘R)

---

## ✅ ERFOLG sieht so aus:

Wenn alles funktioniert, siehst du:

1. **Tutorial Screen** (6 Schritte)
   - Swipe durch → "Start Playing"

2. **Sidescrolling Game View**
   - Boot 🚤 rockt hin und her (±5°)
   - Parallax Background (Berge, Wolken, Bäume)
   - Fallende Items: Drops 💧, Pearls 🔵, Leaves 🍃
   - Top HUD: Currency Counter
   - Bottom Button: Upgrades

3. **Settings** (Gear Icon oben rechts)
   - Sound Effects Toggle
   - Haptic Feedback Toggle
   - Sidescrolling Mode Toggle
   - Performance Overlay Toggle

4. **Performance Overlay** (aktiviere in Settings)
   - FPS Counter (grün = >55 FPS)
   - Memory Usage
   - CPU Usage

---

## 🐛 Häufige Fehler & Lösungen

### Fehler 1: "Cannot find 'GameViewModel' in scope"
**Ursache:** Type Alias fehlt
**Lösung:**
- Öffne `OfflineGameViewModel.swift`
- Füge am Ende hinzu: `typealias GameViewModel = OfflineGameViewModel`

### Fehler 2: "No such module 'Supabase'"
**Ursache:** Du hast Supabase-Dateien kopiert
**Lösung:** Lösche aus Xcode:
- `AuthView.swift`
- `AuthService.swift`
- `DatabaseService.swift`

### Fehler 3: "Ambiguous use of 'GameViewModel'"
**Ursache:** Beide `GameViewModel.swift` UND `OfflineGameViewModel.swift` kopiert
**Lösung:** Lösche `GameViewModel.swift` (brauchen wir nicht!)

### Fehler 4: UIKit Errors (z.B. "UIScreen not found")
**Ursache:** Platform Conditionals fehlen
**Lösung:** Sollte nicht passieren, HapticFeedback hat schon `#if canImport(UIKit)`

### Fehler 5: Build schlägt fehl mit "Missing return"
**Lösung:**
1. **Product** → **Clean Build Folder** (⇧⌘K)
2. **Rebuild** (⌘B)

---

## 📊 Dateien Checkliste

Stelle sicher, dass du **genau diese 23 Dateien** hast:

```
ZenOrigami/
├── ZenOrigamiApp.swift              ✅ NEU ERSTELLT
├── Models/
│   ├── Types.swift                  ✅
│   └── GameConfig.swift             ✅
├── ViewModels/
│   ├── OfflineGameViewModel.swift   ✅ + Type Alias!
│   ├── FallingItemManager.swift     ✅
│   └── ScrollingWorldManager.swift  ✅
├── Services/
│   └── LocalStorageService.swift    ✅
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
        ├── CurrencyDisplayView.swift     ✅
        ├── AchievementToastView.swift    ✅
        └── PerformanceOverlay.swift      ✅
```

**Total:** 23 Swift Files

---

## 🎮 Features testen

Nach erfolgreichem Launch:

### 1. Tutorial
- ✅ Swipe durch 6 Schritte
- ✅ "Start Playing" Button funktioniert

### 2. Gameplay
- ✅ Boot rockt (Sine Wave Animation)
- ✅ Parallax Background scrollt
- ✅ Items fallen von oben
- ✅ Tap auf Item → Collection Sound + Particle Burst
- ✅ Currency Counter updated

### 3. Upgrades
- ✅ Tap "Upgrades" Button
- ✅ Sheet öffnet sich
- ✅ Kaufe "Speed" → Boot scrollt schneller
- ✅ Kaufe "Swan Skin" → Boot ändert sich zu 🦢

### 4. Settings
- ✅ Tap Gear Icon (oben rechts)
- ✅ Toggle Sidescrolling → Mode wechselt
- ✅ Toggle Performance Overlay → FPS anzeigen
- ✅ Toggle Sound → Sounds an/aus

### 5. Offline Earnings
- ✅ App schließen (Home Button)
- ✅ Warte 2 Minuten
- ✅ App öffnen → "Welcome Back" Sheet mit Earnings

---

## 🚀 Nächste Schritte

### Auf echtem Device testen:
1. iPhone via USB verbinden
2. Xcode: Target auf dein iPhone ändern
3. Wenn "Trust Developer" Dialog erscheint:
   - iPhone → Settings → General → VPN & Device Management
   - Tap dein Developer Name → Trust
4. Run (⌘R)

### Assets hinzufügen (später):
1. Emojis durch PNG-Sprites ersetzen
2. `Assets.xcassets` öffnen
3. Drag & Drop PNGs:
   - `boat_default.png` (statt 🚤)
   - `boat_swan.png` (statt 🦢)
   - `drop.png` (statt 💧)
   - `pearl.png` (statt 🔵)
   - `leaf.png` (statt 🍃)
4. In Code ersetzen:
   ```swift
   // Vorher:
   Text("🚤")

   // Nachher:
   Image("boat_default")
       .resizable()
       .frame(width: 80, height: 80)
   ```

### Supabase nachträglich hinzufügen (optional):
1. File → Add Package Dependencies
2. URL: `https://github.com/supabase/supabase-swift`
3. Supabase Projekt erstellen auf supabase.com
4. `AuthService.swift` + `DatabaseService.swift` hinzufügen
5. `AuthView.swift` einbauen
6. Environment Variables setzen

---

## 📈 Performance Targets

Mit Performance Overlay aktiviert (Settings):

- **FPS:** Sollte konstant >55 FPS sein (grün)
- **Memory:** <50 MB (grün), <100 MB (orange)
- **CPU:** <30% im Idle, <60% bei vielen Items

Bei schlechter Performance:
- Reduziere Spawn Interval in FallingItemManager
- Deaktiviere Particle Effects
- Reduziere Parallax Layers

---

## ✅ Checkliste: Projekt Setup Complete

- [ ] Git Repo geklont
- [ ] Xcode Projekt erstellt (iOS 17+)
- [ ] iCloud Capability hinzugefügt
- [ ] Ordnerstruktur erstellt
- [ ] 23 Dateien kopiert
- [ ] Supabase-Dateien NICHT kopiert
- [ ] ZenOrigamiApp.swift neu erstellt
- [ ] Type Alias in OfflineGameViewModel hinzugefügt
- [ ] Build Succeeded
- [ ] App läuft im Simulator
- [ ] Tutorial funktioniert
- [ ] Sidescrolling + Rocking funktioniert
- [ ] Upgrades kaufbar
- [ ] Settings funktionieren
- [ ] Performance Overlay sichtbar

---

## 🆘 Support

Bei Problemen:
1. **Clean Build Folder:** ⇧⌘K
2. **Rebuild:** ⌘B
3. **Check Console:** Fehler lesen
4. **GitHub Issue:** Screenshot + Fehlermeldung posten

---

**Viel Erfolg! 🎉**

Die App ist **production-ready** außer Monetization + Assets!
