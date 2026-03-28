import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: (Double) -> Void
    let geoData: GeoData

    @State private var longitude: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            Text(longitudeLabel)
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(Color(hex: "D4A843"))
                .padding(.top, 4)

            Canvas { context, size in
                let w = size.width
                let h = size.height

                // 1. Ocean background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color(hex: "0C1425"))
                )

                // 2. Graticule
                let latLines: [Double] = [-60, -40, -20, 0, 20, 40, 60]
                for lat in latLines {
                    let y = latToY(lat, height: h)
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: w, y: y))
                    let opacity: Double = lat == 0 ? 0.15 : 0.06
                    context.stroke(line, with: .color(Color(hex: "D4A843").opacity(opacity)), lineWidth: 0.5)
                }
                let lngLines = stride(from: -180.0, through: 180.0, by: 30.0)
                for lngLine in lngLines {
                    let x = lngToX(lngLine, center: longitude, width: w)
                    if x >= -w && x <= w * 2 {
                        var line = Path()
                        line.move(to: CGPoint(x: x, y: 0))
                        line.addLine(to: CGPoint(x: x, y: h))
                        context.stroke(line, with: .color(Color(hex: "D4A843").opacity(0.06)), lineWidth: 0.5)
                    }
                }

                // 3. Land fills
                for offset in [-360.0, 0.0, 360.0] {
                    for polygon in geoData.landPolygons {
                        let path = buildPath(points: polygon.points, lngOffset: offset, center: longitude, width: w, height: h)
                        context.fill(path, with: .color(Color(hex: "14213D")))
                    }
                }

                // 4. Coastline strokes
                for offset in [-360.0, 0.0, 360.0] {
                    for line in geoData.coastlines {
                        let path = buildPath(points: line.points, lngOffset: offset, center: longitude, width: w, height: h)
                        context.stroke(path, with: .color(Color(hex: "D4A843").opacity(0.5)), lineWidth: 0.8)
                    }
                }

                // 5. Vignette
                let vignetteWidth = w * 0.25
                let leftGrad = Gradient(stops: [
                    .init(color: .black.opacity(0.4), location: 0),
                    .init(color: .black.opacity(0), location: 1)
                ])
                let rightGrad = Gradient(stops: [
                    .init(color: .black.opacity(0), location: 0),
                    .init(color: .black.opacity(0.4), location: 1)
                ])
                context.fill(
                    Path(CGRect(x: 0, y: 0, width: vignetteWidth, height: h)),
                    with: .linearGradient(leftGrad, startPoint: CGPoint(x: 0, y: h/2), endPoint: CGPoint(x: vignetteWidth, y: h/2))
                )
                context.fill(
                    Path(CGRect(x: w - vignetteWidth, y: 0, width: vignetteWidth, height: h)),
                    with: .linearGradient(rightGrad, startPoint: CGPoint(x: w - vignetteWidth, y: h/2), endPoint: CGPoint(x: w, y: h/2))
                )

                // 6. Pin
                let centerX = w / 2
                let pinTop = h * 0.1
                let pinBottom = h * 0.9

                var pinLine = Path()
                pinLine.move(to: CGPoint(x: centerX, y: pinTop))
                pinLine.addLine(to: CGPoint(x: centerX, y: pinBottom))
                context.stroke(pinLine, with: .color(Color(hex: "D4A843")), lineWidth: 2)

                let dotSize: CGFloat = 8
                let dotRect = CGRect(x: centerX - dotSize / 2, y: pinTop - dotSize / 2, width: dotSize, height: dotSize)
                context.fill(Circle().path(in: dotRect), with: .color(Color(hex: "D4A843")))
            }
            .frame(maxHeight: .infinity)

            Button("Lock In") {
                onSubmit(longitude)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "D4A843"))
            .padding(.top, 4)
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

    private func lngToX(_ lng: Double, center: Double, width: Double) -> Double {
        let adjusted = ((lng - center + 540).truncatingRemainder(dividingBy: 360)) - 180
        return (adjusted / 360) * width * 2.5 + width / 2
    }

    private func latToY(_ lat: Double, height: Double) -> Double {
        let maxLat: Double = 78.0
        let clamped = max(-maxLat, min(maxLat, lat))
        let rad = clamped * .pi / 180
        let mercY = log(tan(.pi / 4 + rad / 2))
        let maxMercY = log(tan(.pi / 4 + (maxLat * .pi / 180) / 2))
        return height / 2 - (mercY / maxMercY) * (height / 2) * 0.85
    }

    private func buildPath(points: [(Double, Double)], lngOffset: Double, center: Double, width: Double, height: Double) -> Path {
        var path = Path()
        var prevX: Double? = nil
        let halfWidth = width / 2

        for (lng, lat) in points {
            let x = lngToX(lng + lngOffset, center: center, width: width)
            let y = latToY(lat, height: height)
            let pt = CGPoint(x: x, y: y)

            if let px = prevX, abs(x - px) > halfWidth {
                path.move(to: pt)
            } else if path.isEmpty {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
            prevX = x
        }
        return path
    }
}
