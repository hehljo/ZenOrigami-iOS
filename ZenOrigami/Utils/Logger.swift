import Foundation
import OSLog
import QuartzCore

/// Centralized logging system using OSLog
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.zenorigami"

    /// Game-related logs (collect, upgrades, achievements)
    static let game = Logger(subsystem: subsystem, category: "game")

    /// Persistence logs (save, load, sync)
    static let persistence = Logger(subsystem: subsystem, category: "persistence")

    /// Network logs (Supabase, OAuth)
    static let network = Logger(subsystem: subsystem, category: "network")

    /// UI logs (view lifecycle, navigation)
    static let ui = Logger(subsystem: subsystem, category: "ui")

    /// Performance logs (FPS, memory, battery)
    static let performance = Logger(subsystem: subsystem, category: "performance")

    /// Error logs (critical failures)
    static let error = Logger(subsystem: subsystem, category: "error")
}

// MARK: - Convenience Extensions

extension Logger {
    /// Log with emoji prefix for better readability
    func info(_ message: String, emoji: String = "ℹ️") {
        self.info("\(emoji) \(message)")
    }

    func debug(_ message: String, emoji: String = "🔍") {
        self.debug("\(emoji) \(message)")
    }

    func warning(_ message: String, emoji: String = "⚠️") {
        self.warning("\(emoji) \(message)")
    }

    func error(_ message: String, emoji: String = "❌") {
        self.error("\(emoji) \(message)")
    }

    func critical(_ message: String, emoji: String = "🔥") {
        self.critical("\(emoji) \(message)")
    }
}

// MARK: - Performance Monitoring

@MainActor
@Observable
class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    var fps: Double = 60.0
    var memoryUsageMB: Double = 0.0
    var cpuUsagePercent: Double = 0.0

    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var displayLink: CADisplayLink?

    private init() {}

    func startMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)

        // Memory monitoring timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }

        AppLogger.performance.info("Started performance monitoring", emoji: "📊")
    }

    func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        AppLogger.performance.info("Stopped performance monitoring", emoji: "📊")
    }

    @objc private func update(displayLink: CADisplayLink) {
        if lastFrameTime == 0 {
            lastFrameTime = displayLink.timestamp
            return
        }

        frameCount += 1

        let elapsed = displayLink.timestamp - lastFrameTime
        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastFrameTime = displayLink.timestamp

            if fps < 55.0 {
                AppLogger.performance.warning("Low FPS detected: \(fps, privacy: .public)", emoji: "🐌")
            }
        }
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            memoryUsageMB = Double(info.resident_size) / 1024.0 / 1024.0

            if memoryUsageMB > 100.0 {
                AppLogger.performance.warning(
                    "High memory usage: \(memoryUsageMB, privacy: .public) MB",
                    emoji: "💾"
                )
            }
        }
    }
}

// MARK: - Error Handling

enum AppError: LocalizedError {
    case persistenceFailure(String)
    case networkFailure(String)
    case invalidGameState(String)
    case authenticationFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .persistenceFailure(let message):
            return "Failed to save/load game data: \(message)"
        case .networkFailure(let message):
            return "Network error: \(message)"
        case .invalidGameState(let message):
            return "Invalid game state: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .persistenceFailure:
            return "Try restarting the app. Your progress may be restored from backup."
        case .networkFailure:
            return "Check your internet connection and try again."
        case .invalidGameState:
            return "Try resetting your game progress in Settings."
        case .authenticationFailed:
            return "Try signing in again with a different account."
        case .unknown:
            return "Please contact support if the problem persists."
        }
    }

    func log() {
        AppLogger.error.error(
            "\(self.errorDescription ?? "Unknown error", privacy: .public) | Suggestion: \(self.recoverySuggestion ?? "None", privacy: .public)"
        )
    }
}

// MARK: - Analytics Events (Placeholder)

enum AnalyticsEvent {
    case appLaunched
    case tutorialCompleted
    case itemCollected(currency: String, amount: Int)
    case upgradePurchased(upgradeId: String, level: Int)
    case achievementUnlocked(achievementId: String)
    case prestigePerformed(level: Int)
    case dailyRewardClaimed(day: Int)
    case sessionEnded(duration: TimeInterval)

    func track() {
        // Placeholder for analytics integration (Firebase, Telemetry, etc.)
        AppLogger.game.info("Analytics: \(String(describing: self))", emoji: "📈")

        // TODO: Integrate actual analytics service
        // Example: Analytics.logEvent(name, parameters)
    }
}
