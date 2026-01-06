# 📱 App Icon Backup

Hier sind die verschiedenen App Icon Versionen gespeichert für manuelle Bearbeitung.

## Verfügbare Versionen

### 1. AppIcon-1024_v1_larger_boat.png (360 KB)
- **Commit:** 8253cef
- **Beschreibung:** Erstes Icon mit größerem Boot (60% Größe)
- **Status:** ✅ Aktuell in App verwendet (wiederhergestellt)
- **Features:**
  - Boot nimmt 60% des Icons ein
  - Berge im Hintergrund
  - Sky-Gradient Blau-Türkis

### 2. AppIcon-1024_v2_no_border.png (384 KB)
- **Commit:** fbd01b1
- **Beschreibung:** Version ohne weißen Rand (regeneriert)
- **Status:** ⚠️ Hatte Build-Probleme (zu neu)
- **Features:**
  - Kein weißer Rand
  - Gradient bis zu den Kanten
  - Möglicherweise andere Farbbalance

## 🛠️ Manuelle Bearbeitung

Du kannst diese PNG-Dateien manuell bearbeiten:
1. In Photoshop/GIMP/Affinity Photo öffnen
2. Boot größer/kleiner skalieren
3. Farben anpassen
4. Filter/Effekte hinzufügen
5. Als `AppIcon-1024.png` speichern
6. Nach `ZenOrigamiApp/ZenOrigamiApp/Assets.xcassets/AppIcon.appiconset/` kopieren

## 📐 iOS Requirements

- **Größe:** 1024x1024 px
- **Format:** PNG (keine Transparenz!)
- **Farbraum:** RGB
- **Dateiname:** AppIcon-1024.png (muss mit Contents.json übereinstimmen)

## 🎨 Regeneration Script

Falls du ein komplett neues Icon generieren willst:
```bash
python3 generate_app_icon.py
```

Prompt anpassen in `generate_app_icon.py` für andere Stile/Farben.
