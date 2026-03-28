import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: ((Double, Double)) -> Void
    let geoData: GeoData

    @State private var scrollT: Double = 0.0
    @State private var isScrolling = false
    @State private var lastScrollT: Double = 0.0
    @State private var pulsePhase: Double = 0.0

    private let visibleRange: Double = 18.0

    private var currentPosition: (lat: Double, lng: Double) {
        greatCirclePosition(t: scrollT)
    }

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    let pos = currentPosition

                    drawOcean(context: context, w: w, h: h)
                    drawGraticule(context: context, w: w, h: h, centerLat: pos.lat, centerLng: pos.lng)
                    drawLand(context: context, w: w, h: h, centerLat: pos.lat, centerLng: pos.lng)
                    drawCoastlines(context: context, w: w, h: h, centerLat: pos.lat, centerLng: pos.lng, time: time)
                    drawGreatCirclePath(context: context, w: w, h: h, centerLat: pos.lat, centerLng: pos.lng)
                    drawVignette(context: context, w: w, h: h, time: time)
                    drawCompass(context: context, w: w, h: h, centerLat: pos.lat, centerLng: pos.lng)
                    drawCrosshair(context: context, w: w, h: h, time: time)
                }
            }
            .ignoresSafeArea()

            // Overlay UI
            VStack(spacing: 0) {
                // Coordinates — subtle
                HStack(spacing: 6) {
                    Text(latLabel)
                    Text("·")
                    Text(lngLabel)
                }
                .font(.system(size: 10, weight: .regular, design: .serif))
                .foregroundStyle(Color(hex: "D4A843").opacity(0.35))
                .padding(.top, 6)

                Spacer()

                // Distance to goal
                Text(distanceLabel)
                    .font(.system(size: 9, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(Color(hex: "D4A843").opacity(distanceOpacity))
                    .padding(.bottom, 2)

                // Lock In — only visible when not scrolling
                if !isScrolling {
                    Button(action: { onSubmit((currentPosition.lat, currentPosition.lng)) }) {
                        Text("LOCK IN")
                            .font(.system(size: 10, weight: .semibold, design: .serif))
                            .tracking(2)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "D4A843").opacity(0.6))
                    .controlSize(.small)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .padding(.bottom, 2)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isScrolling)
        }
        .focusable()
        .digitalCrownRotation(
            $scrollT,
            from: -180.0,
            through: 180.0,
            by: 2.0,
            sensitivity: .high,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: scrollT) {
            isScrolling = true
            lastScrollT = scrollT
            // Debounce: mark as not scrolling after a pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if lastScrollT == scrollT {
                    isScrolling = false
                }
            }
        }
    }

    // MARK: - Great Circle Navigation

    private func greatCirclePosition(t: Double) -> (lat: Double, lng: Double) {
        let tRad = t * .pi / 180
        let lat0 = clue.scrollCenterLat * .pi / 180
        let lng0 = clue.scrollCenterLng * .pi / 180
        let bearing = clue.scrollBearing * .pi / 180

        let lat = asin(sin(lat0) * cos(tRad) + cos(lat0) * sin(tRad) * cos(bearing))
        let lng = lng0 + atan2(
            sin(bearing) * sin(tRad) * cos(lat0),
            cos(tRad) - sin(lat0) * sin(lat)
        )
        return (lat: lat * 180 / .pi, lng: lng * 180 / .pi)
    }

    // MARK: - Distance Calculation

    /// Haversine formula — great circle distance in km
    private func distanceToGoalKm() -> Double {
        let pos = currentPosition
        let lat1 = pos.lat * .pi / 180
        let lat2 = clue.scrollCenterLat * .pi / 180  // approximate — goal is on the great circle
        let lng1 = pos.lng * .pi / 180
        let lng2 = clue.answerLongitude * .pi / 180

        let dlat = lat2 - lat1
        let dlng = lng2 - lng1

        let a = sin(dlat / 2) * sin(dlat / 2) +
                cos(lat1) * cos(lat2) * sin(dlng / 2) * sin(dlng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return 6371.0 * c
    }

    private var distanceLabel: String {
        let km = distanceToGoalKm()
        if km < 100 {
            return String(format: "%.0f km", km)
        } else if km < 1000 {
            return String(format: "%.0f km", km)
        } else {
            return String(format: "%.1fk km", km / 1000)
        }
    }

    private var distanceOpacity: Double {
        let km = distanceToGoalKm()
        // Brighter when closer
        if km < 500 { return 0.7 }
        if km < 2000 { return 0.4 }
        return 0.25
    }

    // MARK: - Orthographic Projection

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

    // MARK: - Drawing Layers

    private func drawOcean(context: GraphicsContext, w: Double, h: Double) {
        // Subtle radial gradient for depth
        let center = CGPoint(x: w / 2, y: h / 2)
        let radius = max(w, h)
        let gradient = Gradient(stops: [
            .init(color: Color(hex: "0F1A2E"), location: 0),
            .init(color: Color(hex: "080E1A"), location: 1),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
    }

    private func drawGraticule(context: GraphicsContext, w: Double, h: Double,
                                centerLat: Double, centerLng: Double) {
        for lat in stride(from: -80.0, through: 80.0, by: 10.0) {
            var line = Path()
            var lineStarted = false
            var prevVis = false

            for lngSample in stride(from: -180.0, through: 180.0, by: 5.0) {
                let proj = project(lat, lngSample, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
                if !proj.visible { prevVis = false; lineStarted = false; continue }
                let pt = CGPoint(x: proj.x, y: proj.y)
                if !lineStarted || !prevVis { line.move(to: pt); lineStarted = true }
                else { line.addLine(to: pt) }
                prevVis = true
            }
            let opacity: Double = lat == 0 ? 0.08 : 0.025
            context.stroke(line, with: .color(Color(hex: "D4A843").opacity(opacity)), lineWidth: 0.3)
        }

        for lngLine in stride(from: -180.0, through: 165.0, by: 15.0) {
            var line = Path()
            var lineStarted = false
            var prevVis = false

            for latSample in stride(from: -90.0, through: 90.0, by: 5.0) {
                let proj = project(latSample, lngLine, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
                if !proj.visible { prevVis = false; lineStarted = false; continue }
                let pt = CGPoint(x: proj.x, y: proj.y)
                if !lineStarted || !prevVis { line.move(to: pt); lineStarted = true }
                else { line.addLine(to: pt) }
                prevVis = true
            }
            let opacity: Double = lngLine == 0 ? 0.08 : 0.025
            context.stroke(line, with: .color(Color(hex: "D4A843").opacity(opacity)), lineWidth: 0.3)
        }
    }

    private func drawLand(context: GraphicsContext, w: Double, h: Double,
                          centerLat: Double, centerLng: Double) {
        for polygon in geoData.landPolygons {
            let path = buildProjectedPath(
                points: polygon.points,
                centerLat: centerLat, centerLng: centerLng,
                w: w, h: h, close: true
            )
            context.fill(path, with: .color(Color(hex: "152240").opacity(0.9)))
        }
    }

    private func drawCoastlines(context: GraphicsContext, w: Double, h: Double,
                                 centerLat: Double, centerLng: Double, time: Double) {
        let brightOpacity = isScrolling ? 0.7 : (0.6 + 0.15 * sin(time * 1.2))
        for line in geoData.coastlines {
            let path = buildProjectedPath(
                points: line.points,
                centerLat: centerLat, centerLng: centerLng,
                w: w, h: h, close: false
            )
            // Coastline with subtle glow effect (draw twice — wider dim + narrow bright)
            context.stroke(
                path,
                with: .color(Color(hex: "D4A843").opacity(0.15)),
                style: StrokeStyle(lineWidth: 3.0, lineCap: .round)
            )
            context.stroke(
                path,
                with: .color(Color(hex: "D4A843").opacity(brightOpacity)),
                style: StrokeStyle(lineWidth: 0.8, lineCap: .round)
            )
        }
    }

    private func drawGreatCirclePath(context: GraphicsContext, w: Double, h: Double,
                                      centerLat: Double, centerLng: Double) {
        // Draw the great circle scroll path as a very subtle dashed line
        var path = Path()
        var started = false
        var prevVis = false

        for t in stride(from: -90.0, through: 90.0, by: 1.0) {
            let pos = greatCirclePosition(t: t)
            let proj = project(pos.lat, pos.lng, centerLat: centerLat, centerLng: centerLng, w: w, h: h)
            if !proj.visible { prevVis = false; started = false; continue }
            let pt = CGPoint(x: proj.x, y: proj.y)
            if !started || !prevVis { path.move(to: pt); started = true }
            else { path.addLine(to: pt) }
            prevVis = true
        }
        context.stroke(
            path,
            with: .color(Color(hex: "D4A843").opacity(0.08)),
            style: StrokeStyle(lineWidth: 0.5, dash: [4, 6])
        )
    }

    private func drawVignette(context: GraphicsContext, w: Double, h: Double, time: Double) {
        let center = CGPoint(x: w / 2, y: h / 2)
        let radius = max(w, h) * 0.7
        let outerOpacity = 0.7 + 0.03 * sin(time * 0.8)

        let gradient = Gradient(stops: [
            .init(color: .clear, location: 0.3),
            .init(color: .black.opacity(0.3), location: 0.7),
            .init(color: .black.opacity(outerOpacity), location: 1.0),
        ])

        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
        )
    }

    private func drawCompass(context: GraphicsContext, w: Double, h: Double,
                              centerLat: Double, centerLng: Double) {
        // Fixed screen-edge compass labels — always visible
        let compassFont = Font.system(size: 9, weight: .light, design: .serif)
        let compassColor = Color(hex: "D4A843").opacity(0.2)
        let margin: Double = 10

        let labels: [(String, CGPoint)] = [
            ("N", CGPoint(x: w / 2, y: margin)),
            ("S", CGPoint(x: w / 2, y: h - margin)),
            ("E", CGPoint(x: w - margin, y: h / 2)),
            ("W", CGPoint(x: margin, y: h / 2)),
        ]

        for (label, pt) in labels {
            let text = Text(label)
                .font(compassFont)
                .foregroundColor(compassColor)
            context.draw(context.resolve(text), at: pt, anchor: .center)
        }

        // Degree ticks along edges
        let tickColor = Color(hex: "D4A843").opacity(0.08)
        let tickFont = Font.system(size: 6, weight: .light, design: .serif)

        // Top/bottom: longitude ticks
        for dLng in stride(from: -15.0, through: 15.0, by: 5.0) {
            let lng = centerLng + dLng
            let proj = project(centerLat + visibleRange * 0.9, lng,
                              centerLat: centerLat, centerLng: centerLng, w: w, h: h)
            if proj.visible && proj.x > 20 && proj.x < w - 20 {
                let degLabel = String(format: "%.0f°", abs(lng.truncatingRemainder(dividingBy: 360)))
                let text = Text(degLabel).font(tickFont).foregroundColor(tickColor)
                context.draw(context.resolve(text),
                            at: CGPoint(x: proj.x, y: 4), anchor: .top)
            }
        }

        // Left/right: latitude ticks
        for dLat in stride(from: -15.0, through: 15.0, by: 5.0) {
            let lat = centerLat + dLat
            let proj = project(lat, centerLng - visibleRange * 0.9,
                              centerLat: centerLat, centerLng: centerLng, w: w, h: h)
            if proj.visible && proj.y > 20 && proj.y < h - 20 {
                let degLabel = String(format: "%.0f°", abs(lat))
                let text = Text(degLabel).font(tickFont).foregroundColor(tickColor)
                context.draw(context.resolve(text),
                            at: CGPoint(x: 4, y: proj.y), anchor: .topLeading)
            }
        }
    }

    private func drawCrosshair(context: GraphicsContext, w: Double, h: Double, time: Double) {
        let cx = w / 2
        let cy = h / 2

        // Horizontal tick marks
        let tickLen: Double = 6
        let tickGap: Double = 4

        var hLine = Path()
        hLine.move(to: CGPoint(x: cx - tickLen - tickGap, y: cy))
        hLine.addLine(to: CGPoint(x: cx - tickGap, y: cy))
        hLine.move(to: CGPoint(x: cx + tickGap, y: cy))
        hLine.addLine(to: CGPoint(x: cx + tickLen + tickGap, y: cy))

        // Vertical tick marks
        hLine.move(to: CGPoint(x: cx, y: cy - tickLen - tickGap))
        hLine.addLine(to: CGPoint(x: cx, y: cy - tickGap))
        hLine.move(to: CGPoint(x: cx, y: cy + tickGap))
        hLine.addLine(to: CGPoint(x: cx, y: cy + tickLen + tickGap))

        context.stroke(
            hLine,
            with: .color(Color(hex: "D4A843").opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.0, lineCap: .round)
        )

        // Center dot with breathing glow
        let glowOpacity = 0.06 + 0.04 * sin(time * 2.0)
        let glowSize: CGFloat = 12
        let glowRect = CGRect(x: cx - glowSize / 2, y: cy - glowSize / 2,
                               width: glowSize, height: glowSize)
        context.fill(
            Circle().path(in: glowRect),
            with: .color(Color(hex: "D4A843").opacity(glowOpacity))
        )

        let dotSize: CGFloat = 3
        let dotRect = CGRect(x: cx - dotSize / 2, y: cy - dotSize / 2,
                              width: dotSize, height: dotSize)
        context.fill(Circle().path(in: dotRect), with: .color(Color(hex: "D4A843").opacity(0.6)))
    }

    // MARK: - Labels

    private var latLabel: String {
        let lat = currentPosition.lat
        let dir = lat >= 0 ? "N" : "S"
        return String(format: "%.1f\u{00B0}%@", abs(lat), dir)
    }

    private var lngLabel: String {
        let lng = currentPosition.lng
        let dir = lng >= 0 ? "E" : "W"
        return String(format: "%.1f\u{00B0}%@", abs(lng), dir)
    }
}
