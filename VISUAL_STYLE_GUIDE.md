# 🎨 Visual Style Guide - Zen Origami Journey

## Kern-Ästhetik

**"Origami Zen Foldable Minimalist"**

### Design-Prinzipien

1. **Papier-Geometrie** 🗒️
   - Alles sieht aus wie gefaltet aus Papier
   - Sichtbare Falzlinien = Tiefe ohne Schatten
   - Geometrische Formen statt organische Kurven
   - Flache, gefaltete Ebenen

2. **Minimalistisch** ✨
   - Maximal 5-7 geometrische Formen pro Objekt
   - Keine dekorativen Details
   - "Weniger ist mehr" - nur essenzielle Elemente
   - Klare Silhouetten

3. **Zen Ruhe** 🧘
   - Weiche, beruhigende Farben
   - Keine aggressiven Kontraste
   - Friedliche, harmonische Kompositionen
   - Sanfte Bewegungen

4. **Technisch Sauber** 🔧
   - Keine Schatten
   - Keine Gradienten
   - Flache Farbzonen
   - Transparenz-freundlich
   - Scharfe, klare Kanten

---

## Farbsystem

### Primärfarben (Papier)
```css
--paper-white: #FFFFFF      /* Haupt-Papierton */
--cream-highlight: #FFF8E7  /* Falten-Highlights */
--soft-gray: #E8E8E8        /* Falzlinien */
--light-gray: #C0C0C0       /* Inaktive Elemente */
```

### Akzentfarben (Game Items)
```css
--drop-blue: #87CEEB        /* Wasser/Tropfen */
--water-light: #A2D5F2      /* Hintergrund-Wasser */
--leaf-green: #A8C686       /* Blätter dunkel */
--leaf-light: #D4E8C1       /* Blätter hell */
--coral-orange: #FFA07A     /* Fisch */
--sky-blue: #87CEEB         /* Vogel */
```

### Sekundärfarben (Environment)
```css
--mountain-light: #E0E0E0   /* Vordergrund-Berge */
--mountain-dark: #B0B0B0    /* Hintergrund-Berge */
--cloud-white: #FAFAFA      /* Wolken */
--beach-beige: #F4E4C1      /* Strand */
```

### UI Farben
```css
--gold-badge: #FFD700       /* Achievements unlocked */
--gold-light: #FFFACD       /* Achievement highlights */
--red-flag: #E74C3C         /* Akzent-Flag */
--wood-brown: #8B7355       /* Holz-Elemente */
```

### Farbnutzung-Regeln
- **Maximal 3 Farben** pro Asset
- **Immer Transparenz** statt weißem Hintergrund
- **Keine Gradienten** zwischen Farben
- **Flache Zonen** mit klaren Trennlinien

---

## Geometrische Sprache

### Erlaubte Formen
✅ **Verwenden:**
- Dreiecke (Hauptform für Origami)
- Trapeze (gefaltete Perspektive)
- Rechtecke/Quadrate (Basis-Papier)
- Rauten (45° rotierte Quadrate)
- Sechsecke (zusammengesetzte Dreiecke)

❌ **Vermeiden:**
- Perfekte Kreise (zu "digital")
- Komplexe Kurven
- Organische Formen
- Freie Formen ohne Struktur

### Falz-Linien
- **Dicke**: 1-2px
- **Farbe**: 10-15% dunkler als Basis
- **Position**: Kanten und zentrale Faltungen
- **Anzahl**: 3-5 pro Objekt (nicht überladen)

### Proportionen
```
Boat (Hauptfigur):     128x128px
  └─ Sichtbar auf:     6-7" Display = ~40x40mm real

Items (Sammelbar):     64x64px
  └─ Sichtbar auf:     6-7" Display = ~20x20mm real

Companions:            96x96px
  └─ Sichtbar auf:     6-7" Display = ~30x30mm real

UI Icons:              48x48px
  └─ Tap-Target:       44x44pt (iOS minimum)
```

---

## Falttechniken (Origami Reference)

### Basis-Faltungen für Assets

#### 1. **Bootsfaltung**
```
Klassische Papierhut-Faltung:
- Dreieck oben (Segel)
- Trapez Körper
- Flacher Boden
- 2-3 sichtbare Hauptfalzen
```

#### 2. **Kranich-Faltung** (für Vogel)
```
Vereinfachte Kranichform:
- Langer dreieckiger Hals
- Rautenförmiger Körper
- Dreieck-Flügel (gespreizt)
- Kleiner Schwanz
```

#### 3. **Fisch-Faltung**
```
Simple Fischform:
- Dreieck Kopf
- Raute Körper
- Dreieck Schwanzflosse
- Optional: Mini-Dreiecke für Flossen
```

### Origami-Authentizität
- **Keine unmöglichen Faltungen** zeigen
- **Symmetrie** wo Papier gefaltet würde
- **Kanten müssen Sinn machen** (woher kommt die Falte?)
- Bei Unsicherheit: Echtes Origami als Referenz falten

---

## Animation Principles

### Bewegungs-Stil
- **Sanft & Fließend** (ease-in-out curves)
- **Langsam** (zen pace, keine hektischen Bewegungen)
- **Minimal** (kleine Bewegungsamplitude)
- **Schwebend** (floating/drifting quality)

### Timing
```swift
// Empfohlene Animation Durations
Boat Idle Rock:        3.0s  (hin und her)
Drop Fall:             2.0s  (oben nach unten)
Item Collect:          0.3s  (scale + fade)
Button Press:          0.15s (scale down/up)
Sheet Present:         0.4s  (slide up)
Achievement Unlock:    0.8s  (unfold effect)
```

### Bewegungs-Typen
1. **Translation** (Verschiebung)
   - Falling items: Vertical nur
   - Boat: Horizontal drift minimal
   - Clouds: Sehr langsam horizontal

2. **Rotation**
   - Boat Rock: ±5° maximum
   - Items: Leichtes Drehen beim Fallen (±10°)
   - Windmill: 360° kontinuierlich

3. **Scale**
   - Collect: 1.0 → 1.2 → 0
   - Button: 1.0 → 0.95 → 1.0
   - Achievement: 0.5 → 1.1 → 1.0

### Easing Curves
```swift
// SwiftUI Animation Presets
.easeInOut     // Standard für meiste Bewegungen
.easeOut       // Items fallen (beschleunigt oben)
.spring()      // Buttons, playful interactions
.linear        // Kontinuierliche Rotation
```

---

## Layout & Komposition

### Screen Zones (iPhone Layout)
```
┌─────────────────────────┐
│   Top Bar (Stats)       │ 80pt - Safe Area
├─────────────────────────┤
│                         │
│   Sky Zone              │ 30% - Clouds, Birds
│                         │
├─────────────────────────┤
│                         │
│   Gameplay Zone         │ 50% - Boat, Drops
│   (Boat + Items)        │
│                         │
├─────────────────────────┤
│   Water/Shore           │ 20% - Background
└─────────────────────────┘
│   Bottom Bar (Actions)  │ 60pt - Safe Area
└─────────────────────────┘
```

### Depth Layers (Z-Index)
```
Layer 10: Falling Items (Interact)
Layer 9:  Boat (Animate)
Layer 8:  Companions (Follow)
Layer 7:  Mid-ground particles
Layer 6:  Water surface (Animate)
Layer 5:  Shore/Beach (Static)
Layer 4:  Clouds (Slow parallax)
Layer 3:  Mountains (Slower parallax)
Layer 2:  Sky gradient (Static)
Layer 1:  Background color (Static)
```

### Spacing System
```swift
// Consistent Spacing Units
let spacing_xs: CGFloat = 4
let spacing_sm: CGFloat = 8
let spacing_md: CGFloat = 16
let spacing_lg: CGFloat = 24
let spacing_xl: CGFloat = 32
let spacing_xxl: CGFloat = 48
```

---

## Typografie

### Font System
```swift
// Empfohlene System Fonts (iOS)
Title:       .system(.largeTitle, weight: .bold)     // 34pt
Heading:     .system(.title2, weight: .semibold)     // 22pt
Body:        .system(.body, weight: .regular)        // 17pt
Caption:     .system(.caption, weight: .regular)     // 12pt
Numbers:     .system(.title, weight: .medium)        // 28pt (currency)
             .monospacedDigit()  // Für animierte Zahlen
```

### Text Farben
```swift
// Auf hellem Hintergrund
Primary Text:    .black.opacity(0.87)
Secondary Text:  .black.opacity(0.60)
Disabled Text:   .black.opacity(0.38)

// Auf dunklem Hintergrund (Sheets)
Primary Text:    .white.opacity(0.95)
Secondary Text:  .white.opacity(0.70)
```

### Text Alignment
- **Zentriert**: Titles, Zahlen, Popups
- **Links**: Descriptions, Listen
- **Rechts**: Währungs-Beträge (optional)

---

## Sound Design Aesthetik

### Audio-Prinzipien
- **Natürlich**: Wasser, Papier, Wind
- **Gedämpft**: Keine grellen Töne
- **Kurz**: 0.1-0.5s per Effekt
- **Harmonisch**: Pentatonische Skala für Musik

### Sound Palette
```
Item Collect:     "Soft water plop" (pitches: C4, E4, G4)
Upgrade Buy:      "Paper unfold rustle"
Achievement:      "Wind chime ding" (longer, ~1s)
Boat Rock:        "Gentle water lap" (ambient loop)
Background:       "Distant water stream" (subtle, -20dB)
```

---

## Accessibility

### Kontrast-Anforderungen
- **Minimum**: 4.5:1 für normalen Text
- **Large Text**: 3:1 für ≥24pt
- **Icons**: 3:1 gegen Hintergrund

### Farbenblind-Freundlichkeit
- **Nicht nur auf Farbe verlassen**
- Items: Farbe + Form unterschiedlich
  - Drop: Tränenform + Blau
  - Pearl: Rund + Weiß
  - Leaf: Mandel + Grün

### Touch Targets
- **Minimum**: 44x44pt (iOS Standard)
- **Empfohlen**: 48x48pt für Buttons
- **Spacing**: 8pt zwischen Tap-Elementen

### Reduce Motion Support
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Disable falling animations
    // Use fade-in instead
    // Instant transitions
}
```

---

## Do's & Don'ts

### ✅ DO:
- Use simple geometric shapes
- Show paper fold lines
- Keep backgrounds transparent
- Use soft, muted colors
- Maintain consistent line weight (1-2px)
- Test at actual display size
- Consider zen peaceful aesthetic
- Make assets modular (reusable)

### ❌ DON'T:
- Add drop shadows or glows
- Use gradients or blur effects
- Create overly complex details
- Mix realistic + flat styles
- Use bright neon colors
- Make tiny details <3px
- Ignore transparent backgrounds
- Deviate from color palette

---

## Export Checklist

Jedes finale Asset muss durchlaufen:

```markdown
- [ ] Transparenter Hintergrund (alpha channel)
- [ ] Korrekte Größe (@2x für Retina)
- [ ] sRGB Farbprofil
- [ ] PNG-24 + Alpha Format
- [ ] Keine Schatten/Glows
- [ ] Keine Gradienten
- [ ] Klare Kanten (minimal AA)
- [ ] Dateiname nach Konvention
- [ ] Geprüft bei 100% + 50% Zoom
- [ ] Konsistent mit anderen Assets
```

### Dateinamen-Konvention
```
{object}_{variant}_{state}.png

Beispiele:
boat_default_normal.png
boat_default_tilt_left.png
swan_skin_normal.png
drop_item_normal.png
drop_item_squash.png
pearl_item_normal.png
fish_companion_normal.png
badge_achievement_locked.png
badge_achievement_unlocked.png
```

---

## Referenzen & Inspiration

### Origami Tutorials
- Klassisches Boot: https://origami.me/boat
- Kranich: https://origami.me/crane
- Fisch: https://origami.me/fish

### Design Inspiration
- Monument Valley (geometrisch + minimalistisch)
- Alto's Adventure (zen + einfache Farben)
- Prune (organisch + minimal)
- Gris (Kunst + Farbe)

### Color Inspiration
- Japanische Washi-Papier Farben
- Zen Garten Sand/Stein Töne
- Origami Papier Sets (Yuzen, Chiyogami)

---

**Version**: 1.0
**Erstellt**: 2026-01-02
**Für**: Zen Origami Journey iOS
**Engine**: SwiftUI + SpriteKit
**Ziel**: Konsistente, zen-inspirierte Origami-Ästhetik
