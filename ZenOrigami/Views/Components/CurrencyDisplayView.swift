import SwiftUI

/// Currency display for top bar
struct CurrencyDisplayView: View {
    let currencies: Currencies

    var body: some View {
        HStack(spacing: 16) {
            CurrencyBadge(emoji: "💧", amount: currencies.drop)
            CurrencyBadge(emoji: "🔵", amount: currencies.pearl)
            CurrencyBadge(emoji: "🍃", amount: currencies.leaf)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

struct CurrencyBadge: View {
    let emoji: String
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 20))
            Text("\(amount)")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .monospacedDigit()
        }
    }
}

#Preview {
    VStack {
        CurrencyDisplayView(currencies: Currencies(drop: 1234, pearl: 56, leaf: 78))
    }
    .padding()
}
