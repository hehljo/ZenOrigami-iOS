# 🚀 Zen Origami - Supabase Setup (Komplett-Anleitung)

**Zeit:** 10-15 Minuten
**Xcode Version:** 16.1.1
**Voraussetzung:** Bestehendes Xcode Projekt

---

## 📋 Checkliste

- [ ] Supabase Account erstellen
- [ ] Supabase Projekt erstellen
- [ ] Database Schema deployen
- [ ] API Keys kopieren
- [ ] Supabase SDK zu Xcode hinzufügen
- [ ] AuthService + DatabaseService kopieren
- [ ] Environment Variables setzen
- [ ] Build & Run

---

## 1️⃣ SUPABASE ACCOUNT & PROJEKT (5 Min)

### 1.1 Account erstellen
1. Gehe zu: **https://supabase.com**
2. **Start your project** klicken
3. **Sign up with GitHub** (empfohlen) oder Email
4. GitHub authorisieren

### 1.2 Neues Projekt erstellen
1. **New project** Button klicken
2. **Organization:** Falls nicht vorhanden → "New organization" erstellen

**Projekt Settings:**
```
Project name: zen-origami
Database Password: [Klick "Generate a password" dann KOPIEREN!]
Region: Europe West (Frankfurt) - oder näher zu dir
Pricing Plan: Free (perfekt zum Starten)
```

3. **Create new project** klicken
4. ⏳ **Warte 2-3 Minuten** (Datenbank wird provisioniert)

**Status:** Wenn "Project Dashboard" sichtbar ist → ✅ Fertig!

---

## 2️⃣ DATABASE SCHEMA DEPLOYEN (2 Min)

### 2.1 SQL Editor öffnen
1. Linkes Menü → **SQL Editor** Icon (</> Symbol)
2. **New query** klicken

### 2.2 Schema Code kopieren
1. Öffne im Repo: **`supabase_schema.sql`**
2. **Kopiere den GESAMTEN Inhalt** (⌘A → ⌘C)

### 2.3 Deployen
1. Paste in Supabase SQL Editor (⌘V)
2. **Run** klicken (oder F5)
3. ✅ **Success** Meldung unten rechts

**Check:**
- Linkes Menü → **Table Editor**
- Du solltest `game_states` Table sehen

---

## 3️⃣ API KEYS KOPIEREN (1 Min)

### 3.1 Settings öffnen
1. Linkes Menü → **Project Settings** (⚙️ Icon ganz unten)
2. **API** Tab (im Submenu)

### 3.2 Keys kopieren
**Du brauchst 2 Werte:**

**A) Project URL:**
```
https://xxxxxxxxxxxxx.supabase.co
```
→ Kopieren (📋 Icon)

**B) anon public Key:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ...
(sehr langer String, ~200 Zeichen)
```
→ Kopieren (📋 Icon)

**⚠️ WICHTIG:** Speichere diese in TextEdit/Notes!
(Du brauchst sie gleich in Xcode)

---

## 4️⃣ SUPABASE SDK ZU XCODE HINZUFÜGEN (3 Min)

### 4.1 Package Dependencies öffnen
1. **Xcode öffnen** (dein ZenOrigami Projekt)
2. **File** → **Add Package Dependencies...**

### 4.2 Supabase SDK hinzufügen
1. **Search Bar** (oben rechts):
   ```
   https://github.com/supabase/supabase-swift
   ```
   → Return/Enter drücken

2. **Dependency Rule:**
   - "Up to Next Major Version"
   - Version: `2.0.0` (sollte automatisch sein)

3. **Add Package** klicken
4. ⏳ **Warte 30-60 Sekunden** (Download + Compilation)

### 4.3 SDK zum Target hinzufügen
**Popup: "Choose Package Products"**

Aktiviere folgende Packages:
- ✅ **Auth**
- ✅ **Functions**
- ✅ **PostgREST**
- ✅ **Realtime**
- ✅ **Storage**
- ✅ **Supabase**

**Add to Target:** `ZenOrigami` ✅

5. **Add Package** klicken
6. ✅ **Warte bis "Dependencies" fertig sind** (unten in Xcode)

---

## 5️⃣ DATEIEN INS PROJEKT KOPIEREN (3 Min)

### 5.1 Repo Files öffnen
```bash
cd ~/Desktop/ZenOrigami-iOS
open ZenOrigami
```

### 5.2 Services kopieren (Drag & Drop)

**Aus `ZenOrigami/Services/`:**
- ✅ `AuthService.swift`
- ✅ `DatabaseService.swift`
- ✅ `LocalStorageService.swift` (für Migration)

**→ Drag & Drop in Xcode `Services` Ordner**

**Beim Dialog:**
- ✅ **Copy items if needed**
- ✅ **Create groups**
- ✅ **Add to targets: ZenOrigami**

### 5.3 Views kopieren

**Aus `ZenOrigami/Views/`:**
- ✅ `AuthView.swift` (Login Screen)
- ✅ `ContentView.swift` (Root mit Auth-Check)

**→ Drag & Drop in Xcode `Views` Ordner**

**⚠️ WICHTIG:** Wenn Xcode fragt "Replace ContentView.swift?" → **Replace** ✅

---

## 6️⃣ ENVIRONMENT VARIABLES SETZEN (2 Min)

### 6.1 Edit Scheme öffnen
1. **Xcode:** Product → Scheme → **Edit Scheme...** (oder ⌘<)
2. Linke Sidebar: **Run** (sollte schon ausgewählt sein)
3. **Arguments** Tab (oben)

### 6.2 Environment Variables hinzufügen

**Scrolle zu "Environment Variables"** (zweiter Block)

**Klick + Button** (unten links) **2x** und füge hinzu:

| Name | Value |
|------|-------|
| `SUPABASE_URL` | `https://xxxxx.supabase.co` (von Schritt 3.2) |
| `SUPABASE_ANON_KEY` | `eyJhbGciOi...` (von Schritt 3.2) |

**⚠️ Copy & Paste aus deinem TextEdit/Notes!**

3. **Close** klicken

---

## 7️⃣ ZENORIGAMIAPP.SWIFT ANPASSEN (1 Min)

### 7.1 Datei öffnen
**Xcode:** `ZenOrigamiApp.swift` öffnen (Project Navigator)

### 7.2 Code ersetzen

**Lösche ALLES** und ersetze mit:

```swift
import SwiftUI

@main
struct ZenOrigamiApp: App {
    // Supabase Credentials from Environment Variables
    private let supabaseURL: String
    private let supabaseKey: String

    init() {
        // Read from Xcode Scheme Environment Variables
        self.supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        self.supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""

        // Validation
        if supabaseURL.isEmpty || supabaseKey.isEmpty {
            print("⚠️ ERROR: Supabase credentials missing! Check Edit Scheme → Environment Variables")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AuthService(
                    supabaseURL: supabaseURL,
                    supabaseKey: supabaseKey
                ))
        }
    }
}
```

3. **Save** (⌘S)

---

## 8️⃣ BUILD & RUN! 🚀

### 8.1 Clean Build
1. **Product** → **Clean Build Folder** (⇧⌘K)
2. Warte 2 Sekunden

### 8.2 Build
1. **Product** → **Build** (⌘B)
2. ⏳ **Warte** (~30-60 Sekunden beim ersten Mal)
3. **Check Console** für Fehler

**Wenn Build Succeeded ✅** → Weiter!

### 8.3 Run
1. **Simulator wählen:** iPhone 15 Pro
2. **Product** → **Run** (⌘R)
3. ⏳ **Warte auf App Launch**

---

## ✅ ERFOLG SIEHT SO AUS:

### 1. Login Screen
- **"Continue with Google"** Button
- **"Continue with GitHub"** Button
- Zen Origami Logo/Title

### 2. Nach Google Login:
- Browser öffnet → Google Account wählen
- **Allow** klicken
- → Zurück zur App

### 3. Tutorial (6 Schritte)
- Swipe durch Tutorial
- "Start Playing" klicken

### 4. Game läuft! 🎮
- Sidescrolling Background
- Boot rockt (±5°)
- Items fallen
- Tap → Collection!

---

## 🐛 TROUBLESHOOTING

### Fehler: "Cannot find 'AuthService'"
**Lösung:** Du hast `AuthService.swift` nicht kopiert
→ Schritt 5.2 wiederholen

### Fehler: "No such module 'Supabase'"
**Lösung:** SDK nicht richtig hinzugefügt
→ File → Add Package Dependencies → Supabase SDK nochmal hinzufügen

### Fehler: "Supabase credentials missing!"
**Lösung:** Environment Variables fehlen
→ Product → Scheme → Edit Scheme → Arguments → Check Variables

### App startet, aber sofort Crash
**Check Console** (⌘Y für Debug Area)
→ Schick mir die Fehlermeldung

### Login Button funktioniert nicht
**Lösung:** Supabase Auth Provider aktivieren
1. Supabase Dashboard → **Authentication**
2. **Providers** Tab
3. **Google** aktivieren (oder GitHub)
4. Client ID + Secret eintragen (Google Cloud Console)

---

## 📊 WAS DU JETZT HAST:

| Feature | Status |
|---------|--------|
| **Cloud Save** | ✅ Funktioniert |
| **OAuth Login** | ✅ Google + GitHub |
| **Multi-Device Sync** | ✅ Automatisch |
| **Offline Fallback** | ✅ UserDefaults |
| **Migration Local → Cloud** | ✅ Automatisch |
| **All Game Features** | ✅ Vollständig |

---

## 🔐 GOOGLE OAUTH SETUP (Optional, aber empfohlen)

Falls "Continue with Google" nicht funktioniert:

### 1. Google Cloud Console
1. https://console.cloud.google.com
2. **New Project** → "Zen Origami"
3. **APIs & Services** → **Credentials**
4. **Create Credentials** → **OAuth 2.0 Client ID**
5. **Application Type:** iOS
6. **Bundle ID:** `com.[deinname].ZenOrigami`
7. **Create**

### 2. Keys kopieren
- **Client ID:** Kopieren
- **iOS URL Scheme:** Kopieren

### 3. Supabase konfigurieren
1. Supabase Dashboard → **Authentication** → **Providers**
2. **Google** aktivieren
3. **Client ID** + **Client Secret** eintragen
4. **Save**

### 4. Xcode Info.plist
1. **Info.plist** öffnen
2. **URL Types** hinzufügen (iOS URL Scheme von Google)

---

## 🎯 NÄCHSTE SCHRITTE

1. ✅ **Testen:** Spiele 5 Minuten
2. ✅ **Device Test:** Auf echtem iPhone
3. ✅ **Multi-Device:** Login auf iPad → Progress synct!
4. ✅ **Assets:** Emojis → PNGs ersetzen
5. ✅ **StoreKit:** IAP für Monetization (Phase 6)

---

## 📝 QUICK REFERENCE

**Supabase Dashboard:** https://supabase.com/dashboard
**SQL Schema File:** `supabase_schema.sql`
**Xcode Project:** `~/Desktop/ZenOrigami-Xcode/`

**Environment Variables:**
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

---

**Bei Fragen oder Problemen → schreib mir den Console Output!** 🆘

Viel Erfolg! 🚀
