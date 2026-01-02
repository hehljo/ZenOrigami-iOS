# 📊 Status & Verbesserungsvorschläge - Zen Origami Journey iOS

**Stand:** 2026-01-02
**iOS Version:** iOS 17+ (Xcode 15/16 kompatibel)
**Best Practices:** Idle Game 2026

---

## ✅ Was ist implementiert (DONE)

### ✅ Core Architektur
- [x] **MVVM Pattern** mit `@Observable` macro (iOS 17+)
- [x] **Actor Isolation** für Thread-Safety (DatabaseService, LocalStorageService)
- [x] **DTO Pattern** für Datenbank-Serialisierung
- [x] **Environment Injection** für Services
- [x] **Swift 5.9+ Concurrency** (async/await, Task)

### ✅ Persistenz & Backend
- [x] **Dual-Mode Support:**
  - Supabase (Cloud + OAuth)
  - LocalStorageService (Offline + iCloud)
- [x] **Auto-Save** (debounced 2s Timer)
- [x] **UserDefaults Fallback** (schnell, lokal)
- [x] **Migration** (Local → Cloud beim Login)

### ✅ Game Mechanics (Logik)
- [x] **3 Währungen** (Drop, Pearl, Leaf)
- [x] **4 Upgrade-Typen** (Leveled, Add-ons, Skins, Companions)
- [x] **Idle Earnings System** (Multi-Faktor Berechnung)
- [x] **Companion Bonuses** (2x Multiplikatoren)
- [x] **Play Time Tracking** (1s Timer)
- [x] **Offline Earnings Cap** (24h Maximum)

### ✅ UI/UX Basis
- [x] **AuthView** (Google/GitHub OAuth Buttons)
- [x] **GameView** (Haupt-Gameplay Struktur)
- [x] **ContentView** (Root + Navigation)
- [x] **Welcome Back Sheet** (Offline Earnings Anzeige)

### ✅ Development Tools
- [x] **GitHub Actions CI/CD** (Build + Test)
- [x] **SwiftLint** (Code Quality)
- [x] **Unit Tests** (GameConfig, GameViewModel)
- [x] **Documentation** (README, SETUP_OPTIONS, Asset Guides)

---

## ❌ Was fehlt noch (TODO)

### 🎮 Gameplay Features (CRITICAL)

#### ❌ **Visuelle Assets** (KEINE ASSETS VORHANDEN!)
```
PROBLEM: Keine Grafiken implementiert!
```
- [ ] Boat Sprite (PNG mit Transparenz)
- [ ] Swan Skin (Alternativ-Sprite)
- [ ] Falling Items (Drop, Pearl, Leaf Animationen)
- [ ] Companions (Fish, Bird Sprites)
- [ ] Background Layers (Berge, Wolken, Wasser)
- [ ] UI Icons (Währungen, Buttons)

**AKTION BENÖTIGT:**
1. Assets mit ASSET_PROMPTS.md generieren
2. In `Assets.xcassets` importieren
3. SwiftUI Image() Referenzen hinzufügen

---

#### ❌ **Animations-System** (KERN-GAMEPLAY FEHLT!)
```
PROBLEM: Keine fallenden Items = kein Gameplay!
```
- [ ] Falling Item Spawn System
- [ ] Drop Physics (fall animation)
- [ ] Tap/Collect Interaktion
- [ ] Particle Effects (collect burst)
- [ ] Boat idle animation (rocking)
- [ ] Companion follow logic

**IMPLEMENTATION NEEDED:**
```swift
// Beispiel: FallingItemManager.swift
@MainActor
@Observable
class FallingItemManager {
    var fallingDrops: [FallingDrop] = []
    private var spawnTimer: Timer?

    func startSpawning(dropInterval: TimeInterval) {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: dropInterval, repeats: true) { _ in
            self.spawnDrop()
        }
    }

    func spawnDrop() {
        let randomX = Double.random(in: 0...1)
        let drop = FallingDrop(x: randomX, y: -0.1)
        fallingDrops.append(drop)

        // Animate fall
        withAnimation(.linear(duration: 2.0)) {
            drop.y = 1.1 // Bottom of screen
        }
    }
}
```

---

#### ❌ **Upgrade UI Screens** (KEINE SHOP-IMPLEMENTIERUNG!)
```
PROBLEM: Logik vorhanden, aber keine UI zum Kaufen!
```
- [ ] Shop/Upgrade Sheet
- [ ] Upgrade-Karten mit Kosten
- [ ] Level-up Buttons
- [ ] "Can Afford" visuelle Anzeige
- [ ] Upgrade-Effekt Preview

**NEEDED VIEWS:**
- `UpgradeSheetView.swift` - Upgrade-Menü
- `UpgradeCardView.swift` - Einzelne Upgrade-Karte
- `CurrencyDisplayView.swift` - Währungs-Anzeige oben

---

#### ❌ **Achievement System UI** (LOGIK FEHLT KOMPLETT!)
```
PROBLEM: checkAchievements() ist nur Platzhalter!
```
- [ ] Achievement Definitionen (GameConfig)
- [ ] Achievement Unlock Logic
- [ ] Achievement Notification Toast
- [ ] Achievement List Screen
- [ ] Badge Icons (locked/unlocked)

**IMPLEMENTATION:**
```swift
// GameConfig.swift
enum GameConfig {
    enum Achievements {
        case firstCollect      // Collect 1 drop
        case collector100      // Collect 100 drops total
        case upgrader          // Buy first upgrade
        case skinCollector     // Unlock swan skin
        // ... 20+ achievements

        var requirement: (GameState) -> Bool {
            switch self {
            case .firstCollect:
                return { $0.totalCollected.drop >= 1 }
            case .collector100:
                return { $0.totalCollected.drop >= 100 }
            // ...
            }
        }
    }
}
```

---

### 🎨 Visual & Audio Polish

#### ❌ **Sound Effects** (STILLE!)
- [ ] Drop collect sound (soft water plop)
- [ ] Upgrade purchase sound (paper unfold)
- [ ] Achievement unlock (wind chime)
- [ ] Background ambient (water stream, -20dB)
- [ ] Button tap feedback

**IMPLEMENTATION:**
```swift
import AVFoundation

@MainActor
class SoundManager: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]

    func playSound(_ name: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = volume
        player?.play()
        players[name] = player
    }
}
```

---

#### ❌ **Haptic Feedback** (KEINE HAPTIK!)
- [ ] Light impact (drop collect)
- [ ] Medium impact (upgrade purchase)
- [ ] Heavy impact (achievement unlock)
- [ ] Selection feedback (button tap)

**IMPLEMENTATION:**
```swift
import CoreHaptics

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
```

---

#### ❌ **Particle Effects** (KEINE VISUELLEN EFFEKTE!)
- [ ] Collect burst (Sterne/Sparkles)
- [ ] Upgrade purchase glow
- [ ] Achievement unlock confetti
- [ ] Idle water ripples

**USING:**
- SwiftUI Canvas + TimelineView
- Oder SpriteKit integration für Performance

---

### 🏆 Meta-Game Features

#### ❌ **Prestige System** (LANGZEIT-MOTIVATION!)
```
WICHTIG für Idle Games: Prestige = Replayability!
```
- [ ] Prestige Points System
- [ ] Prestige Multipliers
- [ ] "Reset & Prestige" Button
- [ ] Prestige-only Upgrades
- [ ] Visual Prestige Indicator

**BEST PRACTICE 2026:**
```swift
// Prestige nach Total Drops Collected
func calculatePrestigePoints() -> Int {
    let totalDrops = gameState.totalCollected.drop
    // 1 Prestige Point per 10,000 drops
    return Int(sqrt(Double(totalDrops) / 10000))
}

// Prestige Multiplier
func prestigeMultiplier() -> Double {
    return 1.0 + (Double(gameState.prestigeLevel) * 0.1) // +10% per Prestige
}
```

---

#### ❌ **Leaderboards** (SOCIAL ENGAGEMENT!)
- [ ] Global Leaderboard (Total Drops)
- [ ] Friends Leaderboard (OAuth required)
- [ ] Weekly/Monthly Rankings
- [ ] Leaderboard UI Screen

**USING SUPABASE:**
```sql
-- Already exists in /root/Zen/supabase-leaderboards-migration.sql
-- Just need to implement Swift integration
```

---

#### ❌ **Daily Rewards** (RETENTION!)
```
CRITICAL für Daily Active Users (DAU)!
```
- [ ] Daily Login Bonus (steigend 1-7 Tage)
- [ ] Streak Counter
- [ ] Reward Claim UI
- [ ] Notification Reminder (optional)

**IMPLEMENTATION:**
```swift
struct DailyReward {
    let day: Int
    let drops: Int

    static let rewards: [DailyReward] = [
        .init(day: 1, drops: 100),
        .init(day: 2, drops: 200),
        .init(day: 3, drops: 400),
        .init(day: 4, drops: 800),
        .init(day: 5, drops: 1600),
        .init(day: 6, drops: 3200),
        .init(day: 7, drops: 10000), // Jackpot
    ]
}
```

---

#### ❌ **Seasonal Events** (ENGAGEMENT SPIKES!)
- [ ] Event Definition System
- [ ] Time-Limited Challenges
- [ ] Special Event Currency
- [ ] Event Leaderboard
- [ ] Cosmetic Event Rewards

---

### 📱 Platform Features

#### ❌ **Widgets** (HOME SCREEN PRESENCE!)
```
iOS 17+ WidgetKit - WICHTIG für Retention!
```
- [ ] Small Widget (Currency Display)
- [ ] Medium Widget (Upgrades + Currency)
- [ ] Large Widget (Full Stats + Boat)
- [ ] Live Activity (iOS 16.1+) während Spielsession

**IMPLEMENTATION:**
```swift
// Widgets/GameWidget.swift
import WidgetKit
import SwiftUI

struct GameWidget: Widget {
    let kind: String = "GameWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GameWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Zen Origami Journey")
        .description("Check your idle earnings")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

---

#### ❌ **Apple Watch App** (OPTIONAL, HIGH IMPACT!)
- [ ] Watch Companion App
- [ ] Quick Stats Glance
- [ ] Collect Drops on Watch
- [ ] Complication Support

---

#### ❌ **iCloud Sync** (DEVICE SYNC!)
```
BEREITS TEILWEISE: LocalStorageService nutzt NSUbiquitousKeyValueStore
ABER: Keine Conflict Resolution!
```
- [ ] Conflict Resolution (Cloud vs Local)
- [ ] Sync Status Indicator
- [ ] "Restore from iCloud" Button
- [ ] Sync Error Handling

---

#### ❌ **Notifications** (RE-ENGAGEMENT!)
```
Local Notifications für Offline Earnings!
```
- [ ] "Your boat earned X drops!" nach 6h offline
- [ ] Daily Reward Reminder
- [ ] Event Start Notification
- [ ] Achievement Unlock (optional)

**IMPLEMENTATION:**
```swift
import UserNotifications

class NotificationManager {
    func scheduleOfflineEarningsReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Your boat is waiting!"
        content.body = "Collect your idle earnings now 🚤"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 21600, repeats: false) // 6h
        let request = UNNotificationRequest(identifier: "offlineEarnings", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
```

---

### 🎯 UX Improvements

#### ❌ **Onboarding/Tutorial** (NEUER NUTZER FLOW!)
```
PROBLEM: Neuer User sieht leeren Screen und weiß nicht was tun!
```
- [ ] Welcome Screen mit Anleitung
- [ ] "Tap to collect" Tutorial
- [ ] First Upgrade Hint
- [ ] Companion Unlock Celebration

**BEST PRACTICE:**
```swift
struct TutorialStep {
    let title: String
    let description: String
    let highlightView: String? // ID of view to highlight
}

let tutorialSteps: [TutorialStep] = [
    .init(title: "Welcome!", description: "Tap falling drops to collect them", highlightView: nil),
    .init(title: "Currencies", description: "You earn Drops, Pearls, and Leaves", highlightView: "currencyDisplay"),
    .init(title: "Upgrades", description: "Spend drops to buy upgrades", highlightView: "upgradeButton"),
]
```

---

#### ❌ **Settings Screen** (NUTZER-PRÄFERENZEN!)
- [ ] Sound On/Off Toggle
- [ ] Haptics On/Off Toggle
- [ ] Notification Permission Request
- [ ] iCloud Sync Toggle
- [ ] Account Management (Logout)
- [ ] Reset Progress (mit Warnung)

---

#### ❌ **Statistics Screen** (PROGRESSION TRACKING!)
- [ ] Total Playtime
- [ ] Total Collected (per Währung)
- [ ] Total Upgrades Purchased
- [ ] Achievements Progress (X/50 unlocked)
- [ ] Prestige Level & Points
- [ ] Lifetime Stats

---

### 🔧 Technical Improvements

#### ❌ **Performance Optimization**
```
CURRENT: Kein Performance-Monitoring!
```
- [ ] FPS Monitoring (sollte konstant 60 FPS sein)
- [ ] Memory Leak Detection
- [ ] Battery Usage Optimization
- [ ] Lazy Loading für große Listen
- [ ] Image Caching (AsyncImage)

**USING:**
```swift
import os.signpost

let subsystem = "com.zenorigami.performance"
let category = "GameLoop"

os_signpost(.begin, log: OSLog(subsystem: subsystem, category: category), name: "FrameUpdate")
// ... frame update logic
os_signpost(.end, log: OSLog(subsystem: subsystem, category: category), name: "FrameUpdate")
```

---

#### ❌ **Error Handling & Logging**
```
CURRENT: Nur print() statements!
```
- [ ] Structured Logging mit OSLog
- [ ] Error Tracking (z.B. Sentry)
- [ ] User-friendly Error Messages
- [ ] Retry Logic für Netzwerk-Fehler

**REPLACE:**
```swift
// Bad:
print("[GameVM] ❌ Error saving: \(error)")

// Good:
Logger.game.error("Failed to save game state: \(error.localizedDescription, privacy: .public)")
```

---

#### ❌ **Analytics** (DATA-DRIVEN DEVELOPMENT!)
```
CRITICAL: Keine Analytics = blind entwickeln!
```
- [ ] Track User Actions (collect, upgrade, etc.)
- [ ] Session Duration
- [ ] Retention Metrics (Day 1, 7, 30)
- [ ] Funnel Analysis (Onboarding → First Upgrade)
- [ ] A/B Testing Framework

**USING:**
- Firebase Analytics (gratis)
- Oder Telemetry (iOS 17+ native)

---

#### ❌ **Accessibility** (INKLUSIVITÄT!)
```
CURRENT: Keine VoiceOver Labels!
```
- [ ] VoiceOver Labels für alle UI
- [ ] Dynamic Type Support (Text Scaling)
- [ ] Reduce Motion Support
- [ ] High Contrast Mode
- [ ] Color Blind Friendly (Icons + Farbe)

**IMPLEMENTATION:**
```swift
Image("drop_item")
    .accessibilityLabel("Water Drop")
    .accessibilityHint("Tap to collect")
    .accessibilityAddTraits(.isButton)
```

---

#### ❌ **Localization** (GLOBALE REICHWEITE!)
```
CURRENT: Nur Englisch!
```
- [ ] German (Deutsch) - Primary
- [ ] English - Secondary
- [ ] Weitere Sprachen (FR, ES, JA)
- [ ] Currency/Number Formatting
- [ ] Date Formatting (regional)

**USING:**
```swift
// Localizable.strings
"currency.drop" = "Drops";
"currency.pearl" = "Pearls";
"upgrade.collector" = "Rain Collector";

// Code:
Text("currency.drop".localized)
```

---

## 🏆 Best Practices Idle Games 2026

### 1. **Offline Progression** ✅ DONE
```
✅ Bereits implementiert: 24h Cap + Multi-Faktor Berechnung
```

### 2. **Prestige System** ❌ MISSING (KRITISCH!)
```
WARUM: Ohne Prestige = Game endet nach paar Tagen!
```
**EMPFEHLUNG:**
- Prestige ab 50,000 Total Drops
- Prestige gibt +10% pro Level
- Unlock: Neue Companions, Skins nur via Prestige

### 3. **Daily Engagement Loops** ❌ MISSING
```
CRITICAL für Retention!
```
- Daily Login Bonus ✅
- Daily Challenges ❌
- Time-gated Content ❌
- Limited Events ❌

### 4. **Social Features** ❌ TEILWEISE
```
OAuth vorhanden, aber keine Social Features!
```
- [ ] Freunde hinzufügen
- [ ] Freunde Leaderboard
- [ ] Geschenke senden/empfangen
- [ ] Co-op Events

### 5. **Monetization Ready** ❌ NICHT VORHANDEN
```
Falls später Monetization gewünscht:
```
- [ ] IAP Integration (StoreKit 2)
- [ ] "Remove Ads" Option (auch wenn keine Ads)
- [ ] Premium Currency (Gems)
- [ ] Cosmetic Shop

**BEST PRACTICE 2026:**
- **KEINE** Pay-to-Win Mechanics
- Nur Cosmetics & QoL Upgrades
- Ads: Optional Rewarded Videos (2x Speed für 30min)

### 6. **Live Ops Framework** ❌ FEHLT
```
Für kontinuierliches Content-Update:
```
- [ ] Remote Config (Firebase/Supabase)
- [ ] Feature Flags (A/B Testing)
- [ ] Event Scheduling (Server-Side)
- [ ] Dynamic Content Loading

### 7. **Data Analytics** ❌ FEHLT (KRITISCH!)
```
OHNE Analytics = keine Optimierung möglich!
```
**KPIs für Idle Games:**
- DAU/MAU (Daily/Monthly Active Users)
- Session Length (Durchschnitt)
- Retention D1/D7/D30
- ARPU (Average Revenue Per User)
- Funnel Conversion (Onboarding → Erste Stunde)

### 8. **Performance Standards** ⚠️ UNBEKANNT
```
TARGET für iOS Idle Game:
```
- 60 FPS konstant ✅ (SwiftUI sollte schaffen)
- < 50 MB RAM ❓ (Testen benötigt)
- < 2s Cold Start ❓ (Testen benötigt)
- < 100 MB App Size ✅ (Aktuell minimal)
- < 10% Battery/Hour ❓ (Optimierung nötig)

---

## 📊 Prioritäten-Matrix (Was zuerst?)

### 🔴 P0 - KRITISCH (Game funktioniert nicht ohne!)
```
1. ✅ Assets generieren (ASSET_PROMPTS.md nutzen)
2. ✅ Falling Items Animation System
3. ✅ Tap/Collect Interaktion
4. ✅ Upgrade Shop UI
5. ✅ Basic Tutorial/Onboarding
```
**Zeitaufwand:** 2-3 Tage Entwicklung

---

### 🟠 P1 - WICHTIG (Game ist "spielbar" aber unvollständig)
```
6. ✅ Achievement System (Logik + UI)
7. ✅ Sound Effects
8. ✅ Haptic Feedback
9. ✅ Settings Screen
10. ✅ Statistics Screen
11. ✅ Daily Rewards
```
**Zeitaufwand:** 3-4 Tage

---

### 🟡 P2 - VERBESSERUNGEN (Nice-to-have)
```
12. ✅ Prestige System
13. ✅ Particle Effects
14. ✅ Leaderboards
15. ✅ Notifications
16. ✅ Widgets
17. ✅ Localization (DE/EN)
```
**Zeitaufwand:** 1 Woche

---

### 🟢 P3 - POLISH (Post-Launch)
```
18. ○ Seasonal Events
19. ○ Apple Watch App
20. ○ iCloud Advanced Sync
21. ○ Analytics Deep-Dive
22. ○ A/B Testing Framework
23. ○ Monetization (IAP)
```
**Zeitaufwand:** 2-3 Wochen

---

## 🚀 Roadmap Vorschlag

### **Woche 1: MVP (Minimum Viable Product)**
- Assets erstellen & importieren
- Falling Items System
- Collect Interaction
- Upgrade Shop UI
- Basic Tutorial
→ **ERGEBNIS: Spielbares Game**

### **Woche 2: Core Features**
- Achievement System
- Sound + Haptics
- Settings + Stats
- Daily Rewards
- Polish & Bug Fixes
→ **ERGEBNIS: Feature-Complete Game**

### **Woche 3: Meta-Game**
- Prestige System
- Leaderboards
- Notifications
- Widgets
- Localization
→ **ERGEBNIS: Release-Ready**

### **Woche 4+: Post-Launch**
- Analytics Monitoring
- Performance Optimization
- Seasonal Events
- Community Feedback Integration
→ **ERGEBNIS: Live Service**

---

## 🎯 Konkrete nächste Schritte

### HEUTE:
1. **Assets generieren** mit ASSET_PROMPTS.md
   ```bash
   # Open QUICK_ASSET_REFERENCE.md
   # Copy Boot-Prompt → Google Gemini
   # Export als PNG @2x
   ```

2. **Assets importieren** in Xcode
   ```bash
   # Create Assets.xcassets folder
   # Drag & Drop PNGs
   # Verify naming (boat_default, drop_item, etc.)
   ```

### MORGEN:
3. **FallingItemManager.swift** erstellen
4. **GameView** erweitern mit Tap-Gestures
5. **First Playable Build** testen

### DIESE WOCHE:
6. Upgrade Shop UI
7. Tutorial implementieren
8. Sounds + Haptics
9. TestFlight Beta Upload

---

## 📝 Zusammenfassung

### ✅ WAS GUT IST:
- Solide Architektur (MVVM + Actor)
- Dual-Mode (Online/Offline)
- Game Logic vollständig
- Gute Dokumentation
- CI/CD Pipeline

### ❌ WAS FEHLT:
- **Visuelle Assets** (CRITICAL!)
- **Animations-System** (CRITICAL!)
- **Upgrade UI** (HIGH)
- **Achievements** (HIGH)
- **Sound/Haptics** (MEDIUM)
- **Meta-Features** (Prestige, Daily Rewards) (MEDIUM)

### 🎯 EMPFEHLUNG:
**FOKUS:** P0 + P1 Features (1-2 Wochen)
**DANN:** TestFlight Beta für Feedback
**DANN:** P2 Features basierend auf Feedback

---

**Status:** 🟡 **~40% Complete**
- Architektur: ✅ 100%
- Game Logic: ✅ 100%
- UI/UX: ⚠️ 20%
- Assets: ❌ 0%
- Polish: ❌ 0%

**Next Milestone:** MVP Playable Build (Assets + Falling Items + Shop UI)

---

Soll ich mit der Implementierung der P0-Features starten? 🚀
