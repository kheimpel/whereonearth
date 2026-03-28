import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("WHERE ON\nEARTH")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "E8DCC8"))

                NavigationLink("Play") {
                    Text("Game coming soon")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "D4A843"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "0C1425"))
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
    MenuView()
}
