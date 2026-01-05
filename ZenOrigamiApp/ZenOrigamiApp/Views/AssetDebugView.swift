import SwiftUI

/// Debug view to test if assets are loading correctly
struct AssetDebugView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Asset Loading Test")
                .font(.headline)

            HStack(spacing: 20) {
                VStack {
                    Image("drop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .border(Color.red)
                    Text("drop")
                }

                VStack {
                    Image("pearl")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .border(Color.red)
                    Text("pearl")
                }

                VStack {
                    Image("leaf")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .border(Color.red)
                    Text("leaf")
                }
            }

            HStack(spacing: 20) {
                VStack {
                    Image("boat_default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .border(Color.red)
                    Text("boat_default")
                }

                VStack {
                    Image("companion_fish")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .border(Color.red)
                    Text("companion_fish")
                }

                VStack {
                    Image("companion_bird")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .border(Color.red)
                    Text("companion_bird")
                }
            }
        }
        .padding()
    }
}

#Preview {
    AssetDebugView()
}
