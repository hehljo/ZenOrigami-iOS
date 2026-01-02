import SwiftUI

/// Development overlay showing FPS and memory usage
struct PerformanceOverlay: View {
    @State private var monitor = PerformanceMonitor.shared
    @AppStorage("showPerformanceOverlay") private var showOverlay = false

    var body: some View {
        if showOverlay {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("FPS:")
                        .font(.caption2.monospacedDigit())
                    Text(String(format: "%.1f", monitor.fps))
                        .font(.caption2.monospacedDigit().bold())
                        .foregroundStyle(fpsColor)
                }

                HStack {
                    Text("MEM:")
                        .font(.caption2.monospacedDigit())
                    Text(String(format: "%.1f MB", monitor.memoryUsageMB))
                        .font(.caption2.monospacedDigit().bold())
                        .foregroundStyle(memoryColor)
                }

                HStack {
                    Text("CPU:")
                        .font(.caption2.monospacedDigit())
                    Text(String(format: "%.1f%%", monitor.cpuUsagePercent))
                        .font(.caption2.monospacedDigit().bold())
                }
            }
            .padding(8)
            .background(.black.opacity(0.7))
            .cornerRadius(8)
            .padding()
        }
    }

    private var fpsColor: Color {
        if monitor.fps >= 55 {
            return .green
        } else if monitor.fps >= 30 {
            return .orange
        } else {
            return .red
        }
    }

    private var memoryColor: Color {
        if monitor.memoryUsageMB < 50 {
            return .green
        } else if monitor.memoryUsageMB < 100 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        PerformanceOverlay()
    }
}
