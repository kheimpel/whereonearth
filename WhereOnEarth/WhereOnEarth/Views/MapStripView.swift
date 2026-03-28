import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: (Double) -> Void
    let geoData: GeoData

    @State private var scrollT: Double = 0.0

    var body: some View {
        ZStack {
            // Full-screen map canvas
            Canvas { context, size in
                let w = size.width
                let h = size.height

                let pos = greatCirclePosition(t: scrollT)
                let centerLat = pos.lat
                let centerLng = pos.lng

                // 1. Ocean background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color(hex: "0C1425"))
                )

                // 2. Graticule
                drawGraticule(context: context, w: w, h: h,
                              centerLat: centerLat, centerLng: centerLng)

                // 3. Land fills
                for polygon in geoData.landPolygons {
                    let path = buildProjectedPath(
                        points: polygon.points,
                        centerLat: centerLat, centerLng: centerLng,
                        w: w, h: h, close: true
                    )
                    context.fill(path, with: .color(Color(hex: "1A2A4A").opacity(0.8)))
                }

                // 4. Coastline strokes
                for line in geoData.coastlines {
                    let path = buildProjectedPath(
                        points: line.points,
                        centerLat: centerLat, centerLng: centerLng,
                        w: w, h: h, close: false
                    )
                    context.stroke(
                        path,
                        with: .color(Color(hex: "D4A843").opacity(0.7)),
                        lineWidth: 1.2
                    )
                }

                // 5. Globe edge vignette — radial gradient from center (transparent) to edges (black)
                drawVignette(context: context, w: w, h: h)

                // 6. Center pin
                drawPin(context: context, w: w, h: h)
            }
            .ignoresSafeArea()

            // Overlay UI
            VStack {
                Text(longitudeLabel)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: "D4A843").opacity(0.8))
                    .padding(.top, 8)

                Spacer()

                Button(action: {
                    let currentLng = greatCirclePosition(t: scrollT).lng
                    onSubmit(currentLng)
                }) {
                    Text("Lock In")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "D4A843").opacity(0.7))
                .controlSize(.small)
                .padding(.bottom, 2)
            }
        }
        .focusable()
        .digitalCrownRotation(
            $scrollT,
            from: -180.0,
            through: 180.0,
            by: 1.0,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
    }

    // MARK: - Great Circle Navigation

    private func greatCirclePosition(t: Double) -> (lat: Double, lng: Double) {
        let tRad = t * .pi / 180
        let lat0 = clue.scrollCenterLat * .pi / 180
        let lng0 = clue.scrollCenterLng * .pi / 180
        let bearing = clue.scrollBearing * .pi / 180

        let lat = asin(sin(lat0) * cos(tRad) + cos(lat0) * sin(tRad) * cos(bearing))
        let lng = lng0 + atan2(sin(bearing) * sin(tRad) * cos(lat0),
                                cos(tRad) - sin(lat0) * sin(lat))

        return (lat: lat * 180 / .pi, lng: lng * 180 / .pi)
    }

    // MARK: - Orthographic Projection

    private let visibleRange: Double = 18.0

    private func project(_ lat: Double, _ lng: Double,
                         centerLat: Double, centerLng: Double,
                         w: Double, h: Double) -> (x: Double, y: Double, visible: Bool) {
        let phi = lat * .pi / 180
        let lam = lng * .pi / 180
        let phi1 = centerLat * .pi / 180
        let lam0 = centerLng * .pi / 180

        let cosC = sin(phi1) * sin(phi) + cos(phi1) * cos(phi) * cos(lam - lam0)
        let visible = cosC > 0

        let x = cos(phi) * sin(lam - lam0)
        let y = cos(phi1) * sin(phi) - sin(phi1) * cos(phi) * cos(lam - lam0)

        let scale = min(w, h) / 2 / sin(visibleRange * .pi / 180)

        return (x: w / 2 + x * scale, y: h / 2 - y * scale, visible: visible)
    }

    // MARK: - Path Building

    private func buildProjectedPath(points: [(Double, Double)],
                                     centerLat: Double, centerLng: Double,
                                     w: Double, h: Double, close: Bool) -> Path {
        var path = Path()
        var started = false
        var prevVisible = false

        for (lng, lat) in points {
            let proj = project(lat, lng, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
            let pt = CGPoint(x: proj.x, y: proj.y)

            if !proj.visible {
                prevVisible = false
                started = false
                continue
            }

            // Skip points way off screen
            if pt.x < -w || pt.x > w * 2 || pt.y < -h || pt.y > h * 2 {
                prevVisible = false
                started = false
                continue
            }

            if !started || !prevVisible {
                path.move(to: pt)
                started = true
            } else {
                path.addLine(to: pt)
            }
            prevVisible = true
        }
        if close { path.closeSubpath() }
        return path
    }

    // MARK: - Drawing

    private func drawGraticule(context: GraphicsContext, w: Double, h: Double,
                                centerLat: Double, centerLng: Double) {
        // Latitude lines every 10° from -80 to 80
        for lat in stride(from: -80.0, through: 80.0, by: 10.0) {
            var line = Path()
            var lineStarted = false
            var prevVisible = false

            for lngSample in stride(from: -180.0, through: 180.0, by: 5.0) {
                let proj = project(lat, lngSample, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
                let pt = CGPoint(x: proj.x, y: proj.y)

                if !proj.visible {
                    prevVisible = false
                    lineStarted = false
                    continue
                }

                if !lineStarted || !prevVisible {
                    line.move(to: pt)
                    lineStarted = true
                } else {
                    line.addLine(to: pt)
                }
                prevVisible = true
            }

            let opacity: Double = lat == 0 ? 0.12 : 0.04
            context.stroke(line, with: .color(Color(hex: "D4A843").opacity(opacity)), lineWidth: 0.5)
        }

        // Longitude lines every 15°
        for lngLine in stride(from: -180.0, through: 165.0, by: 15.0) {
            var line = Path()
            var lineStarted = false
            var prevVisible = false

            for latSample in stride(from: -90.0, through: 90.0, by: 5.0) {
                let proj = project(latSample, lngLine, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
                let pt = CGPoint(x: proj.x, y: proj.y)

                if !proj.visible {
                    prevVisible = false
                    lineStarted = false
                    continue
                }

                if !lineStarted || !prevVisible {
                    line.move(to: pt)
                    lineStarted = true
                } else {
                    line.addLine(to: pt)
                }
                prevVisible = true
            }

            let opacity: Double = lngLine == 0 ? 0.12 : 0.04
            context.stroke(line, with: .color(Color(hex: "D4A843").opacity(opacity)), lineWidth: 0.5)
        }
    }

    private func drawVignette(context: GraphicsContext, w: Double, h: Double) {
        let center = CGPoint(x: w / 2, y: h / 2)
        let radius = max(w, h) / 2

        let gradient = Gradient(stops: [
            .init(color: .black.opacity(0), location: 0),
            .init(color: .black.opacity(0.5), location: 1),
        ])

        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                                   width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
    }

    private func drawPin(context: GraphicsContext, w: Double, h: Double) {
        let centerX = w / 2
        let pinTop = h * 0.05
        let pinBottom = h * 0.95

        var pinLine = Path()
        pinLine.move(to: CGPoint(x: centerX, y: pinTop))
        pinLine.addLine(to: CGPoint(x: centerX, y: pinBottom))
        context.stroke(pinLine, with: .color(Color(hex: "D4A843").opacity(0.7)), lineWidth: 1.5)

        let dotSize: CGFloat = 6
        let dotY = h * 0.5
        let dotRect = CGRect(
            x: centerX - dotSize / 2,
            y: dotY - dotSize / 2,
            width: dotSize,
            height: dotSize
        )
        context.fill(Circle().path(in: dotRect), with: .color(Color(hex: "D4A843")))
    }

    private var longitudeLabel: String {
        let pos = greatCirclePosition(t: scrollT)
        let lng = pos.lng
        let absLng = abs(lng)
        let dir = lng >= 0 ? "E" : "W"
        return String(format: "%.0f\u{00B0}%@", absLng, dir)
    }
}
