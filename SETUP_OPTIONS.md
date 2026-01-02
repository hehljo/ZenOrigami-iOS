# 🎮 Setup-Optionen für Zen Origami Journey iOS

Es gibt **zwei Möglichkeiten**, das Spiel zu nutzen:

## ✅ Option 1: **Offline-Only** (EMPFOHLEN für Start)

**Vorteile:**
- ✅ **Keine externe Abhängigkeiten** - funktioniert sofort
- ✅ **Kostenlos** - kein Supabase-Konto nötig
- ✅ **iCloud Sync** - automatische Synchronisation zwischen iPhone/iPad
- ✅ **Schneller** - keine Netzwerk-Calls
- ✅ **Privat** - Daten bleiben auf Ihren Geräten

**Nachteile:**
- ❌ Kein Google/GitHub Login
- ❌ Keine Web-Dashboard-Integration
- ❌ Nur Apple-Geräte (iCloud)

### Setup (5 Minuten)

1. **Projekt öffnen:**
   ```bash
   cd /root/ZenOrigami-iOS
   xed .  # Öffnet Xcode
   ```

2. **Offline-ViewModel verwenden:**

   In `ZenOrigamiApp.swift` ändern:
   ```swift
   import SwiftUI

   @main
   struct ZenOrigamiApp: App {
       @State private var storageService = LocalStorageService()
       @State private var gameViewModel: OfflineGameViewModel?

       var body: some Scene {
           WindowGroup {
               OfflineContentView()
                   .task {
                       gameViewModel = OfflineGameViewModel(
                           storageService: storageService
                       )
                       await gameViewModel?.loadGameState()
                   }
           }
       }
   }
   ```

3. **iCloud aktivieren (optional):**
   - Xcode → Signing & Capabilities
   - ✅ iCloud
   - ✅ Key-Value Storage

4. **Fertig!** Build & Run (Cmd+R)

---

## 🌐 Option 2: **Mit Supabase** (für Multi-Plattform)

**Vorteile:**
- ✅ **OAuth Login** - Google + GitHub
- ✅ **Cross-Plattform** - iOS + Web + Android
- ✅ **PostgreSQL** - robuste Datenbank
- ✅ **Leaderboards** - global rankings
- ✅ **Admin Dashboard** - Daten-Verwaltung

**Nachteile:**
- ❌ Supabase-Konto erforderlich (kostenlos bis 500MB)
- ❌ Setup komplexer (45 Min)
- ❌ Netzwerk-Abhängigkeit

### Setup (45 Minuten)

#### 1. Supabase-Projekt erstellen

```bash
# 1. Gehe zu https://supabase.com
# 2. Erstelle kostenloses Konto
# 3. Neues Projekt erstellen
# 4. Warte 2-3 Minuten für Provisioning
```

#### 2. Datenbank einrichten

```sql
-- In Supabase SQL Editor ausführen:
-- 1. /root/Zen/supabase-schema.sql
-- 2. /root/Zen/supabase-leaderboards-migration.sql
-- 3. /root/Zen/supabase-seasonal-schema.sql
```

#### 3. OAuth konfigurieren

**Google OAuth:**
```bash
# 1. https://console.cloud.google.com
# 2. Neues Projekt erstellen
# 3. APIs & Services → Credentials
# 4. OAuth 2.0 Client ID erstellen
# 5. iOS Bundle ID hinzufügen
# 6. Client ID kopieren
```

**In Supabase:**
```
Settings → Authentication → Providers
✅ Google (Client ID & Secret einfügen)
✅ GitHub (ebenfalls konfigurieren)
```

#### 4. Environment Variables

```bash
# .env erstellen:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

#### 5. App konfigurieren

In Xcode → Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>zenorigami</string>
        </array>
    </dict>
</array>
```

#### 6. Build & Run

```bash
# Fertig!
```

---

## 🤔 Welche Option wählen?

### Wähle **Option 1 (Offline)** wenn:
- ✅ Du **schnell starten** willst
- ✅ Du **nur iOS** brauchst
- ✅ Du **keine Cloud** willst
- ✅ Du **noch kein Supabase-Konto** hast

### Wähle **Option 2 (Supabase)** wenn:
- ✅ Du **Web + iOS** möchtest
- ✅ Du **OAuth Login** brauchst
- ✅ Du **Leaderboards** willst
- ✅ Du **Analytics** tracken möchtest

---

## 🔄 Später wechseln?

**Ja!** Du kannst jederzeit upgraden:

```swift
// 1. Daten aus UserDefaults exportieren
let gameState = await offlineViewModel.gameState

// 2. In Supabase importieren
await databaseService.saveGameState(userId: user.id, gameState: gameState)

// 3. ViewModel wechseln
```

---

## ❓ FAQ

**Q: Kann ich beides gleichzeitig nutzen?**
A: Ja! Offline als Fallback, wenn Netzwerk fehlt.

**Q: Wie groß sind die Daten?**
A: ~5-10 KB pro Spielstand (UserDefaults/iCloud limit: 1 MB)

**Q: Kostet Supabase etwas?**
A: **Free Tier:** 500 MB Datenbank + 50.000 monatliche Requests (reicht für 1000+ Spieler)

**Q: Brauche ich ein Apple Developer Account?**
A: **Für Simulator:** Nein
**Für echtes Gerät:** Ja (kostenlos für Testing, $99/Jahr für App Store)

**Q: Funktioniert iCloud ohne Apple ID?**
A: Nein, aber UserDefaults funktioniert immer (nur kein Sync)

---

## 📝 Empfehlung

**Für den Anfang:** Start mit **Option 1 (Offline)**
- Schneller Start
- Kein Setup nötig
- Später upgraden wenn nötig

**Später upgraden zu Supabase** wenn:
- Du eine Web-Version willst
- Du Leaderboards brauchst
- Du Analytics möchtest

---

**Happy Coding! 🚀**
