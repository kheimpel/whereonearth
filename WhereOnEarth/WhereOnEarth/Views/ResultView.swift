import SwiftUI

struct ResultView: View {
    let clue: Clue
    let result: ScoreResult
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Score — hero element
            PhaseAnimator([false, true], trigger: result.points) { phase in
                Text(formattedPoints)
                    .font(Theme.display)
                    .foregroundStyle(Theme.gold)
                    .scaleEffect(phase ? 1.0 : 0.5)
                    .opacity(phase ? 1.0 : 0.0)
            } animation: { _ in
                .spring(duration: 0.6, bounce: 0.3)
            }

            // Tier
            Text(result.tier)
                .font(Theme.caption)
                .fontWeight(.medium)
                .tracking(3)
                .foregroundStyle(tierColor)
                .minimumScaleFactor(0.7)
                .padding(.top, Theme.spacingXS)

            Spacer()
                .frame(height: Theme.spacingLG)

            Rectangle()
                .fill(Theme.gold.opacity(0.15))
                .frame(width: 40, height: 0.5)

            Spacer()
                .frame(height: Theme.spacingMD)

            // The answer
            Text("The answer was")
                .font(Theme.caption)
                .foregroundStyle(Theme.parchment.opacity(0.4))
            Text(clue.answerCountry)
                .font(Theme.body)
                .fontWeight(.medium)
                .foregroundStyle(Theme.parchment)
                .minimumScaleFactor(0.6)
                .padding(.top, Theme.spacingXS)

            Text(distanceKmLabel)
                .font(Theme.caption)
                .foregroundStyle(Theme.parchment.opacity(0.35))
                .minimumScaleFactor(0.7)
                .padding(.top, Theme.spacingSM)

            Spacer()

            // Next
            Button(action: { onNext() }) {
                Text("NEXT").ghostButton()
            }
            .buttonStyle(.plain)
            .padding(.bottom, Theme.spacingMD)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ocean)
        .toolbar(.hidden, for: .navigationBar)
        .persistentSystemOverlays(.hidden)
    }

    private var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: result.points)) ?? "\(result.points)"
    }

    private var tierColor: Color {
        switch result.points {
        case 4500...5000: return Theme.gold
        case 3500..<4500: return Theme.gold.opacity(0.8)
        case 2000..<3500: return Theme.gold.opacity(0.6)
        case 500..<2000: return Theme.parchment.opacity(0.4)
        default: return Theme.parchment.opacity(0.25)
        }
    }

    private var distanceKmLabel: String {
        let km = result.distanceKm
        if km < 0.025 { return "spot on" }
        if km < 1 { return String(format: "%.0f m off", km * 1000) }
        if km < 10 { return String(format: "%.1f km off", km) }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: km)) ?? "\(Int(km))"
        return "\(formatted) km off"
    }
}
