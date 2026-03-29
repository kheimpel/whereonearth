import SwiftUI

struct MenuView: View {
    let geoData: GeoData
    let wristMotion: WristMotion
    private let clueBank = ClueBank()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Text("WHERE ON\nEARTH")
                    .font(Theme.font(size: 20, weight: .light))
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.parchment)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                NavigationLink {
                    GameView(clues: clueBank.cluesForSession(), geoData: geoData, wristMotion: wristMotion)
                } label: {
                    Text("PLAY")
                        .font(Theme.font(size: 12, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(Theme.ocean)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.gold.opacity(0.8))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.ocean)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    MenuView(geoData: GeoData(), wristMotion: WristMotion())
}
