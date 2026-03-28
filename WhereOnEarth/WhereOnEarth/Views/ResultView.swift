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

            Text("+\(result.points)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(accuracyColor)

            Text(clue.answerCountry)
                .font(.caption)
                .foregroundStyle(Color(hex: "E8DCC8"))

            Text(String(format: "%.0f\u{00B0} off", result.distanceDegrees))
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

    private var accuracyColor: Color {
        switch result.accuracy {
        case .country: return Color(hex: "D4A843")
        case .region: return Color(hex: "D4A843").opacity(0.8)
        case .continent: return Color(hex: "D4A843").opacity(0.6)
        case .wrong: return Color(hex: "C0392B")
        }
    }
}
