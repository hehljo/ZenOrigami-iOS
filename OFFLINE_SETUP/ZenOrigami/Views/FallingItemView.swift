import SwiftUI

/// Visual representation of a falling collectible item
struct FallingItemView: View {
    let item: FallingItem
    let emoji: String
    @State private var currentY: CGFloat

    init(item: FallingItem, emoji: String) {
        self.item = item
        self.emoji = emoji
        self._currentY = State(initialValue: item.y)
    }

    var body: some View {
        GeometryReader { geometry in
            Text(emoji)
                .font(.system(size: item.isCollected ? 48 : 32))
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
