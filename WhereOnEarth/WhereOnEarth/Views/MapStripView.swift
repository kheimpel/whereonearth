import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: (Double) -> Void

    @State private var longitude: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            Text(longitudeLabel)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(Color(hex: "D4A843"))
                .padding(.top, 4)

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "0C1425"),
                        Color(hex: "14213D"),
                        Color(hex: "0C1425")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 100)

                Canvas { context, size in
                    let centerX = size.width / 2
                    let pinTop = size.height * 0.2
                    let pinBottom = size.height * 0.8

                    var path = Path()
                    path.move(to: CGPoint(x: centerX, y: pinTop))
                    path.addLine(to: CGPoint(x: centerX, y: pinBottom))
                    context.stroke(path, with: .color(Color(hex: "D4A843")), lineWidth: 2)

                    let dotSize: CGFloat = 8
                    let dotRect = CGRect(
                        x: centerX - dotSize / 2,
                        y: pinTop - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Circle().path(in: dotRect), with: .color(Color(hex: "D4A843")))
                }
                .frame(height: 100)
            }

            Button("Lock In") {
                onSubmit(longitude)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0C1425"))
        .focusable()
        .digitalCrownRotation(
            $longitude,
            from: -180.0,
            through: 180.0,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
    }

    private var longitudeLabel: String {
        let absLng = abs(longitude)
        let dir = longitude >= 0 ? "E" : "W"
        return String(format: "%.0f\u{00B0}%@", absLng, dir)
    }
}
