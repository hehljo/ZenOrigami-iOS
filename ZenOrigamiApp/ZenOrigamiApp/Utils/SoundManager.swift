import AVFoundation
import Foundation

/// Manages game sound effects and background music
@MainActor
@Observable
class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]
    var isSoundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }

    private init() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        // Default to true if never set
        if !UserDefaults.standard.bool(forKey: "soundEnabledSet") {
            isSoundEnabled = true
            UserDefaults.standard.set(true, forKey: "soundEnabledSet")
        }
    }

    // MARK: - Sound Effects

    /// Play drop collect sound (soft water plop)
    /// TODO: Replace with actual sound file (drop_collect.mp3)
    func playDropCollect() {
        guard isSoundEnabled else { return }
        // Placeholder: System sound
        AudioServicesPlaySystemSound(1104) // SMS_Alert1.caf
    }

    /// Play pearl collect sound (higher pitched plop)
    /// TODO: Replace with actual sound file (pearl_collect.mp3)
    func playPearlCollect() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1105) // SMS_Alert2.caf
    }

    /// Play leaf collect sound (soft rustle)
    /// TODO: Replace with actual sound file (leaf_collect.mp3)
    func playLeafCollect() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1106) // SMS_Alert3.caf
    }

    /// Play upgrade purchase sound (paper unfold)
    /// TODO: Replace with actual sound file (upgrade_purchase.mp3)
    func playUpgradePurchase() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1111) // SentMessage.caf
    }

    /// Play achievement unlock sound (wind chime)
    /// TODO: Replace with actual sound file (achievement_unlock.mp3)
    func playAchievementUnlock() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1151) // Anticipate.caf
    }

    /// Play prestige sound (dramatic unfold)
    /// TODO: Replace with actual sound file (prestige.mp3)
    func playPrestige() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1152) // Bloom.caf
    }

    /// Play button tap sound
    /// TODO: Replace with actual sound file (button_tap.mp3)
    func playButtonTap() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Soft click
    }

    // MARK: - Background Music

    /// Play background ambient music (water stream)
    /// TODO: Implement background music loop
    /// File: ambient_water.mp3 (loop, -20dB volume)
    func playBackgroundMusic() {
        guard isSoundEnabled else { return }
        // TODO: Load and play looping ambient track
    }

    func stopBackgroundMusic() {
        // TODO: Stop ambient track
    }

    // MARK: - Custom Sound Loading (for future use)

    private func playSound(_ filename: String, volume: Float = 1.0) {
        guard isSoundEnabled else { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("[SoundManager] ⚠️ Sound file not found: \(filename).mp3")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.play()
            players[filename] = player
        } catch {
            print("[SoundManager] ❌ Error playing sound: \(error)")
        }
    }
}
