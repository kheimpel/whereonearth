import SwiftUI

struct ClueView: View {
    let clue: Clue
    let onReady: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(clue.type.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(Color(hex: "D4A843").opacity(0.6))

            Text(clue.text)
                .font(.body)
                .foregroundStyle(Color(hex: "E8DCC8"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button("Guess") {
                onReady()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
    }
}
