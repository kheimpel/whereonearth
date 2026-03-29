import SwiftUI

struct MenuView: View {
    let geoData: GeoData
    let wristMotion: WristMotion
    private let clueBank = ClueBank()

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                Spacer()

                Text("WHERE ON\nEARTH")
                    .font(Theme.title)
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.parchment)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                NavigationLink {
                    GameView(clues: clueBank.cluesForSession(), geoData: geoData, wristMotion: wristMotion)
                } label: {
                    Text("PLAY").primaryButton()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, Theme.spacingXL)
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
