import SwiftUI

struct ResultView: View {
    let clue: Clue
    let result: ScoreResult
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Score — the hero element
            PhaseAnimator([false, true], trigger: result.points) { phase in
                Text("+\(result.points)")
                    .font(Theme.font(size: 44, weight: .light))
                    .foregroundStyle(Theme.gold)
                    .scaleEffect(phase ? 1.0 : 0.5)
                    .opacity(phase ? 1.0 : 0.0)
            } animation: { _ in
                .spring(duration: 0.6, bounce: 0.3)
            }

            // Accuracy tier
            Text(accuracyLabel)
                .font(Theme.font(size: 10, weight: .medium))
                .tracking(3)
                .foregroundStyle(accuracyColor)
                .minimumScaleFactor(0.7)
                .padding(.top, 2)

            Spacer()
                .frame(height: 16)

            Rectangle()
                .fill(Theme.gold.opacity(0.15))
                .frame(width: 40, height: 0.5)

            Spacer()
                .frame(height: 12)

            // The answer
            Text("The answer was")
                .font(Theme.font(size: 9))
                .foregroundStyle(Theme.parchment.opacity(0.4))
            Text(clue.answerCountry)
                .font(Theme.font(size: 16, weight: .medium))
                .foregroundStyle(Theme.parchment)
                .minimumScaleFactor(0.6)
                .padding(.top, 2)

            // Distance
            Text(distanceKmLabel)
                .font(Theme.font(size: 9))
                .foregroundStyle(Theme.parchment.opacity(0.35))
                .minimumScaleFactor(0.7)
                .padding(.top, 4)

            Spacer()

            // Next
            Button(action: { onNext() }) {
                Text("NEXT")
                    .font(Theme.font(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Theme.gold.opacity(0.5))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ocean)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var accuracyLabel: String {
        switch result.accuracy {
        case .country: return "RIGHT COUNTRY"
        case .region: return "RIGHT REGION"
        case .continent: return "RIGHT CONTINENT"
        case .wrong: return "WRONG CONTINENT"
        }
    }

    private var accuracyColor: Color {
        switch result.accuracy {
        case .country: return Theme.gold
        case .region: return Theme.gold.opacity(0.7)
        case .continent: return Theme.gold.opacity(0.5)
        case .wrong: return Theme.parchment.opacity(0.3)
        }
    }

    private var distanceKmLabel: String {
        let km = result.distanceKm
        if km < 1 {
            return "spot on"
        } else if km < 10 {
            return String(format: "%.0f km off", km)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            let formatted = formatter.string(from: NSNumber(value: km)) ?? "\(Int(km))"
            return "\(formatted) km off"
        }
    }
}
