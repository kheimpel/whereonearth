import SwiftUI

struct ResultView: View {
    let clue: Clue
    let result: ScoreResult
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(accuracyLabel)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(accuracyColor)

            PhaseAnimator([false, true], trigger: result.points) { phase in
                Text("+\(result.points)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(accuracyColor)
                    .scaleEffect(phase ? 1.0 : 0.3)
                    .opacity(phase ? 1.0 : 0.0)
            } animation: { _ in
                .spring(duration: 0.6, bounce: 0.3)
            }

            Text(clue.answerCountry)
                .font(.caption)
                .foregroundStyle(Color(hex: "E8DCC8"))

            Text(distanceKmLabel)
                .font(.caption2)
                .fontDesign(.monospaced)
                .foregroundStyle(Color(hex: "E8DCC8").opacity(0.6))

            Button("Next") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
    }

    private var accuracyLabel: String {
        switch result.accuracy {
        case .country: return "RIGHT COUNTRY"
        case .region: return "RIGHT REGION"
        case .continent: return "RIGHT CONTINENT"
        case .wrong: return "WRONG"
        }
    }

    private var distanceKmLabel: String {
        let km = result.distanceKm
        if km < 1 {
            return "spot on"
        } else if km < 100 {
            return String(format: "%.0f km off", km)
        } else {
            return String(format: "%.0fk km off", km / 1000)
        }
    }

    private var accuracyColor: Color {
        switch result.accuracy {
        case .country: return Color(hex: "D4A843")
        case .region: return Color(hex: "D4A843").opacity(0.8)
        case .continent: return Color(hex: "D4A843").opacity(0.6)
        case .wrong: return Color(hex: "C0392B")
        }
    }
}
