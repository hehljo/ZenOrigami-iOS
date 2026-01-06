import SwiftUI

/// Visual representation of a falling collectible item
/// IMPORTANT: Must be used inside a GeometryReader that provides screen dimensions
struct FallingItemView: View {
    let item: FallingItem
    let emoji: String?
    let assetName: String?
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var currentY: CGFloat

    init(item: FallingItem, emoji: String? = nil, assetName: String? = nil, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.item = item
        self.emoji = emoji
        self.assetName = assetName
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self._currentY = State(initialValue: item.y)
    }

    var body: some View {
        Group {
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
            x: item.x * screenWidth,
            y: currentY * screenHeight
        )
        .onAppear {
            withAnimation(.linear(duration: item.duration)) {
                currentY = item.targetY
            }
        }
        .animation(.spring(response: 0.3), value: item.isCollected)
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
    GeometryReader { geometry in
        ZStack {
            Color.blue.opacity(0.2)
                .ignoresSafeArea()

            FallingItemView(
                item: FallingItem(x: 0.5, y: 0.1, targetY: 0.9, duration: 2.0),
                assetName: "drop",
                screenWidth: geometry.size.width,
                screenHeight: geometry.size.height
            )
        }
    }
}
