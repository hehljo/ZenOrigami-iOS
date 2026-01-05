import SwiftUI

/// Visual representation of a falling collectible item
struct FallingItemView: View {
    let item: FallingItem
    let emoji: String?
    let assetName: String?
    @State private var currentY: CGFloat

    init(item: FallingItem, emoji: String? = nil, assetName: String? = nil) {
        self.item = item
        self.emoji = emoji
        self.assetName = assetName
        self._currentY = State(initialValue: item.y)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let assetName = assetName {
                    // Use Image asset with animations
                    itemImage(for: assetName)
                } else if let emoji = emoji {
                    // Fallback to emoji
                    Text(emoji)
                        .font(.system(size: item.isCollected ? 48 : 32))
                }
            }
            .opacity(item.isCollected ? 0 : 1)
            .scaleEffect(item.isCollected ? 1.5 : 1.0)
            .position(
                x: item.x * geometry.size.width,
                y: currentY * geometry.size.height
            )
            .onAppear {
                withAnimation(.linear(duration: item.duration)) {
                    currentY = item.targetY
                }
            }
            .animation(.spring(response: 0.3), value: item.isCollected)
        }
    }

    /// Apply appropriate animation based on item type
    @ViewBuilder
    private func itemImage(for assetName: String) -> some View {
        let size: CGFloat = item.isCollected ? 60 : 40

        switch assetName {
        case "drop":
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                .shadow(color: .white.opacity(0.6), radius: 2, x: 0, y: 0)  // Glow
                .dropFalling()
        case "pearl":
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                .shadow(color: .cyan.opacity(0.8), radius: 4, x: 0, y: 0)  // Cyan glow for pearl
                .pearlFalling()
        case "leaf":
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                .shadow(color: .green.opacity(0.6), radius: 2, x: 0, y: 0)  // Green glow
                .leafFluttering()
        default:
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
        }
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.2)
            .ignoresSafeArea()

        FallingItemView(
            item: FallingItem(x: 0.5, y: 0.1, targetY: 0.9, duration: 2.0),
            emoji: "💧"
        )
    }
}
