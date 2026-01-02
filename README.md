# 🚤 Zen Origami Journey - iOS

Native iOS port of the Zen Origami Journey idle game, built with **Swift + SwiftUI**.

## 📱 Features

- 🎮 **Native iOS Performance** - Swift/SwiftUI for smooth 60 FPS gameplay
- 🔐 **OAuth Authentication** - Sign in with Google or GitHub via Supabase
- ☁️ **Cloud Sync** - Save progress across devices with Supabase backend
- 💾 **Offline Support** - Full gameplay without internet using UserDefaults
- ⏰ **Idle Earnings** - Collect resources while offline (up to 24 hours)
- 🏆 **Achievement System** - Track progress and unlock rewards
- 🎨 **Customization** - Skins, companions, and cosmetic upgrades
- 📊 **Statistics** - Detailed gameplay metrics and leaderboards

## 🛠️ Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (iOS 17+)
- **Backend:** Supabase (PostgreSQL + Auth)
- **Package Manager:** Swift Package Manager
- **CI/CD:** GitHub Actions with Xcode Cloud
- **Testing:** XCTest + XCUITest

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
ZenOrigami/
├── Models/           # Data models (Codable structs)
│   └── Types.swift   # Core game types
├── Views/            # SwiftUI views
│   ├── ContentView.swift
│   ├── AuthView.swift
│   └── GameView.swift
├── ViewModels/       # @Observable view models
│   └── GameViewModel.swift
├── Services/         # Business logic (actors)
│   ├── AuthService.swift
│   └── DatabaseService.swift
├── Config/           # Game configuration
│   └── GameConfig.swift
├── Utils/            # Helper functions
└── Resources/        # Assets, localization
```

**Key Patterns:**
- **MVVM + SwiftUI:** ViewModels use `@Observable` macro (iOS 17+)
- **Actor Isolation:** Services use `actor` for thread safety
- **DTO Pattern:** Separate models for database (DTO) vs. app logic
- **Environment Objects:** Dependency injection via SwiftUI environment

## 🚀 Getting Started

### Prerequisites

- Xcode 15.2+ (macOS Sonoma)
- iOS 17.0+ deployment target
- Supabase account (for cloud features)
- CocoaPods or Swift Package Manager

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ZenOrigami-iOS
   ```

2. **Resolve Swift dependencies:**
   ```bash
   swift package resolve
   ```

3. **Set up environment variables:**

   Create `.env` file:
   ```bash
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_anon_key
   ```

4. **Configure Supabase:**
   - Run SQL migrations from `/root/Zen/` React project:
     - `supabase-schema.sql` (base tables)
     - `supabase-leaderboards-migration.sql`
     - `supabase-seasonal-schema.sql`
   - Enable OAuth providers (Google, GitHub) in Supabase dashboard
   - Add iOS app deep link: `zenorigami://auth/callback`

5. **Build and run:**
   ```bash
   # Build with Swift Package Manager
   swift build

   # Run tests
   swift test

   # Or open in Xcode
   xed .
   ```

## 🧪 Testing

### Unit Tests
```bash
swift test
```

### UI Tests (Xcode required)
```bash
xcodebuild test \
  -scheme ZenOrigami \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### GitHub Actions

CI/CD pipeline automatically runs on push:
- ✅ Swift syntax checking
- ✅ SwiftLint code quality
- ✅ Unit test execution
- ✅ Build verification (iOS Simulator)
- ✅ Security audit (no hardcoded secrets)

See `.github/workflows/ios-build.yml` for details.

## 📦 Project Structure

```
ZenOrigami-iOS/
├── Package.swift                  # Swift Package Manager
├── .github/workflows/
│   └── ios-build.yml              # GitHub Actions CI/CD
├── .swiftlint.yml                 # Code style rules
├── SETUP_OPTIONS.md               # Setup guide (Offline vs Supabase)
├── ASSET_PROMPTS.md               # AI prompts for asset generation
├── VISUAL_STYLE_GUIDE.md          # Design system documentation
├── ZenOrigami/                    # Main app target
│   ├── Models/
│   │   └── Types.swift            # Game state models (400+ lines)
│   ├── ViewModels/
│   │   ├── GameViewModel.swift    # Central state management (Supabase)
│   │   └── OfflineGameViewModel.swift  # Offline-only variant
│   ├── Services/
│   │   ├── AuthService.swift      # OAuth + session management
│   │   ├── DatabaseService.swift  # Supabase persistence
│   │   └── LocalStorageService.swift   # Offline persistence
│   ├── Views/
│   │   ├── ContentView.swift      # Root view
│   │   ├── AuthView.swift         # Login screen
│   │   └── GameView.swift         # Main gameplay
│   ├── Config/
│   │   └── GameConfig.swift       # Game constants
│   └── ZenOrigamiApp.swift        # App entry point
└── Tests/                         # Unit + UI tests
```

## 🎮 Game Mechanics

### Currencies
- 💧 **Drops** - Primary currency (collected from falling items)
- 🔵 **Pearls** - Rare secondary currency
- 🍃 **Leaves** - Rare secondary currency

### Upgrades (4 types)
1. **Leveled Upgrades** (unlimited levels):
   - Boat Speed, Collection Radius, Drop Rate, Rain Collector
2. **Add-ons:** Origami Flag (cosmetic)
3. **Skins:** Origami Swan (alternative boat)
4. **Companions:** Origami Fish (2x pearl), Origami Bird (2x leaf)

### Idle System
**Best Practice Nov 2025:** All upgrades contribute to offline earnings:
- Base Rate: 2 drops/min per collector level
- Speed Bonus: +0.5 drops/min per level
- Radius Bonus: +0.75 drops/min per level
- Rate Bonus: +1.0 drops/min per level
- Companions: +10% multiplicative bonus each
- **Max Offline Cap:** 24 hours

## 🎨 Assets & Design

### Visual Style
This game uses the **"Origami Zen Foldable Minimalist"** aesthetic:
- Clean geometric shapes (paper-folded look)
- Flat colors, no gradients or shadows
- Transparent backgrounds
- Soft, calming color palette
- Visible fold lines for depth

**Complete style documentation:** See [`VISUAL_STYLE_GUIDE.md`](./VISUAL_STYLE_GUIDE.md)

### Generating Assets
Use AI image generation (Google Gemini, DALL-E, etc.) with the prompts in [`ASSET_PROMPTS.md`](./ASSET_PROMPTS.md).

**Included prompts for:**
- 🚤 Paper Boat (player sprite + variations)
- 🦢 Origami Swan (skin alternative)
- 💧🔵🍃 Falling items (drop, pearl, leaf)
- 🐟🐦 Companions (origami fish, bird)
- 🏔️☁️🌊 Background elements
- 🎯 UI elements (buttons, badges, icons)
- 🎬 Animation frames

**Example prompt structure:**
```
Create a simple origami paper boat in zen minimalist style.
Clean geometric paper folds with crisp edges.
Color: Soft white paper with cream highlights.
Style: Flat design, no shadows, no gradients.
Background: Transparent.
Size: 128x128px equivalent.
```

All prompts are optimized for transparency, clean lines, and origami authenticity.

## 🔧 Development

### Code Style

Run SwiftLint:
```bash
swiftlint lint
```

**Important Rules:**
- Force unwraps (`!`) are **errors** - use optional binding
- Force casts (`as!`) are **warnings** - use conditional casts
- Line length: 120 chars (warning), 150 (error)
- Use `OSLog` instead of `print()` for production

### Adding New Features

1. **New Model:**
   - Add struct to `Models/Types.swift`
   - Conform to `Codable` + `Equatable`
   - Add DTO conversion if persisting to database

2. **New View:**
   - Create SwiftUI view in `Views/`
   - Use `@Environment` for dependencies
   - Add `#Preview` macro for development

3. **New Service:**
   - Use `actor` for async services (thread-safe)
   - Use `@MainActor` + `@Observable` for UI-related services
   - Inject via SwiftUI environment

### Common Issues

**"Cannot find 'Supabase' in scope"**
- Run `swift package resolve`
- Clean build folder: `swift package clean`

**"No such module 'Supabase'"**
- Verify `Package.swift` includes dependency
- Restart Xcode

**OAuth not working**
- Check deep link configuration in `Info.plist`
- Verify redirect URL in Supabase dashboard
- Test deep link: `xcrun simctl openurl booted "zenorigami://auth/callback?token=test"`

**Tests failing**
- Update test snapshots if UI changed
- Check mock data in test helpers
- Verify test environment variables

## 🚀 Deployment

### TestFlight (Beta)

1. Archive build in Xcode:
   - Product → Archive
   - Upload to App Store Connect

2. Add testers in App Store Connect

3. Distribute via TestFlight

### App Store Release

1. Update version in `Package.swift` and Xcode project
2. Create release notes
3. Submit for review via App Store Connect
4. Monitor review status

## 📊 Performance

**Target Metrics:**
- 60 FPS gameplay on iPhone 12+
- < 50 MB memory footprint
- < 100ms UI response time
- < 2s cold launch time

**Optimization Techniques:**
- `@Observable` macro (efficient observation)
- Lazy loading with `LazyVStack`
- Image caching with `AsyncImage`
- Debounced saves (2s interval)

## 🔒 Security

- ✅ **Row-Level Security (RLS)** on all Supabase tables
- ✅ **OAuth PKCE flow** for secure token exchange
- ✅ **Keychain storage** for sensitive data
- ✅ **No hardcoded secrets** (environment variables only)
- ✅ **Automatic security audit** in CI/CD

## 📝 TODO

**Phase 1 (Core Gameplay):**
- [ ] Implement falling item animations
- [ ] Add particle effects for collection
- [ ] Create proper boat SVG assets
- [ ] Implement touch gesture controls

**Phase 2 (Features):**
- [ ] Achievement system UI
- [ ] Prestige screen
- [ ] Seasonal events
- [ ] Leaderboards

**Phase 3 (Polish):**
- [ ] Sound effects + background music
- [ ] Haptic feedback
- [ ] Accessibility (VoiceOver)
- [ ] Localization (EN/DE)

**Phase 4 (Platform):**
- [ ] macOS Catalyst support
- [ ] Apple Watch companion app
- [ ] Widgets (Today widget)
- [ ] iCloud sync (backup to UserDefaults)

## 🤝 Contributing

This is a port of the web-based React game. See original project at `/root/Zen/` for reference.

**Key Differences from React Version:**
- SwiftUI instead of React
- Actor-based concurrency instead of promises
- UserDefaults instead of localStorage
- Native OAuth deep links instead of web redirects

## 📧 Support

For issues specific to iOS port, check:
- GitHub Issues
- Original React project documentation
- Supabase Swift SDK docs

---

**Ported from:** Zen Origami Journey (React/TypeScript)
**Original Author:** See `/root/Zen/README.md`
**iOS Port:** 2025

Made with ❤️ for relaxation and origami lovers
