import SwiftUI

struct ClueView: View {
    let clue: Clue
    let onReady: () -> Void

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()

            Text(clue.type.rawValue.uppercased())
                .font(Theme.caption)
                .fontWeight(.medium)
                .tracking(3)
                .foregroundStyle(Theme.gold.opacity(0.5))

            Text(clue.text)
                .font(Theme.body)
                .foregroundStyle(Theme.parchment)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, Theme.margin)

            Spacer()

            Button(action: { onReady() }) {
                Text("GUESS").primaryButton()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, Theme.spacingXL)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ocean)
        .toolbar(.hidden, for: .navigationBar)
        .persistentSystemOverlays(.hidden)
    }
}
