import SwiftUI

struct ClueView: View {
    let clue: Clue
    let onReady: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(clue.type.rawValue.uppercased())
                .font(Theme.font(size: 9, weight: .medium))
                .tracking(3)
                .foregroundStyle(Theme.gold.opacity(0.5))

            Text(clue.text)
                .font(Theme.font(size: 13, weight: .regular))
                .foregroundStyle(Theme.parchment)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 8)

            Spacer()

            Button(action: { onReady() }) {
                Text("GUESS")
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
