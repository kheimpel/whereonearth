import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: ((Double, Double)) -> Void
    let geoData: GeoData
    let wristMotion: WristMotion

    @State private var scrollT: Double = 0.0
    @State private var isScrolling = false
    @State private var lastScrollT: Double = 0.0

    private let visibleRange: Double = 18.0

    private var currentPosition: (lat: Double, lng: Double) {
        greatCirclePosition(t: scrollT)
    }

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let lampX = wristMotion.lampX
                let lampY = wristMotion.lampY
                Canvas { context, size in
                    let w = size.width
                    let h = size.height
                    let pos = currentPosition
                    let brng = localBearing(at: scrollT)
                    let lamp = CGPoint(x: lampX * w, y: lampY * h)
                    let flicker = 1.0 + sin(time * 2.5) * 0.02

                    drawOcean(context: context, w: w, h: h, lamp: lamp, flicker: flicker)
                    drawGraticule(context: context, w: w, h: h,
                                  centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawLand(context: context, w: w, h: h,
                             centerLat: pos.lat, centerLng: pos.lng, bearing: brng,
                             lamp: lamp, flicker: flicker)
                    drawCoastlines(context: context, w: w, h: h,
                                   centerLat: pos.lat, centerLng: pos.lng, bearing: brng,
                                   lamp: lamp, flicker: flicker, time: time)
                    drawGreatCirclePath(context: context, w: w, h: h,
                                        centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawLampVignette(context: context, w: w, h: h, lamp: lamp, flicker: flicker)
                    drawCompass(context: context, w: w, h: h,
                                centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                }
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
            .ignoresSafeArea()

            // Brass armature overlay (SwiftUI — real shadows + compositing)
            BrassArmatureView(lampX: wristMotion.lampX, lampY: wristMotion.lampY)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Overlay UI
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Text(latLabel)
                    Text("·")
                    Text(lngLabel)
                }
                .font(.system(size: 10, weight: .regular, design: .serif))
                .foregroundStyle(Color(hex: "D4A843").opacity(0.35))
                .padding(.top, 6)

                Spacer()

                Text(distanceLabel)
                    .font(.system(size: 9, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(Color(hex: "D4A843").opacity(distanceOpacity))
                    .padding(.bottom, 2)

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
        .onChange(of: scrollT) {
            isScrolling = true
            lastScrollT = scrollT
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if lastScrollT == scrollT {
                    isScrolling = false
                }
            }
        }
        .onAppear { wristMotion.start() }
        .onDisappear { wristMotion.stop() }
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

        var lngDeg = lng * 180 / .pi
        while lngDeg > 180 { lngDeg -= 360 }
        while lngDeg < -180 { lngDeg += 360 }
        return (lat: lat * 180 / .pi, lng: lngDeg)
    }

    // MARK: - Distance

    private func distanceToGoalKm() -> Double {
        let pos = currentPosition
        let lat1 = pos.lat * .pi / 180
        let lat2 = clue.scrollCenterLat * .pi / 180
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
        if km < 100 { return String(format: "%.0f km", km) }
        if km < 1000 { return String(format: "%.0f km", km) }
        return String(format: "%.1fk km", km / 1000)
    }

    private var distanceOpacity: Double {
        let km = distanceToGoalKm()
        if km < 500 { return 0.7 }
        if km < 2000 { return 0.4 }
        return 0.25
    }

    // MARK: - Orthographic Projection

    private func localBearing(at t: Double) -> Double {
        let dt = 0.5
        let p1 = greatCirclePosition(t: t - dt)
        let p2 = greatCirclePosition(t: t + dt)
        let lat1 = p1.lat * .pi / 180
        let lat2 = p2.lat * .pi / 180
        let dLng = (p2.lng - p1.lng) * .pi / 180
        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)
        return atan2(y, x)
    }

    private func project(_ lat: Double, _ lng: Double,
                         centerLat: Double, centerLng: Double,
                         bearing: Double,
                         w: Double, h: Double) -> (x: Double, y: Double, visible: Bool) {
        let phi = lat * .pi / 180
        let lam = lng * .pi / 180
        let phi1 = centerLat * .pi / 180
        let lam0 = centerLng * .pi / 180

        let cosC = sin(phi1) * sin(phi) + cos(phi1) * cos(phi) * cos(lam - lam0)
        let visible = cosC > 0

        let xOrtho = cos(phi) * sin(lam - lam0)
        let yOrtho = cos(phi1) * sin(phi) - sin(phi1) * cos(phi) * cos(lam - lam0)

        let rotation = bearing - .pi / 2
        let xRot = xOrtho * cos(rotation) - yOrtho * sin(rotation)
        let yRot = xOrtho * sin(rotation) + yOrtho * cos(rotation)

        let scale = min(w, h) / 2 / sin(visibleRange * .pi / 180)
        return (x: w / 2 + xRot * scale, y: h / 2 - yRot * scale, visible: visible)
    }

    // MARK: - Path Building

    private func buildProjectedPath(points: [(Double, Double)],
                                     centerLat: Double, centerLng: Double, bearing: Double,
                                     w: Double, h: Double, close: Bool) -> Path {
        var path = Path()
        var started = false
        var prevVisible = false

        for (lng, lat) in points {
            let proj = project(lat, lng, centerLat: centerLat, centerLng: centerLng,
                              bearing: bearing, w: w, h: h)
            let pt = CGPoint(x: proj.x, y: proj.y)

            if !proj.visible { prevVisible = false; started = false; continue }
            if pt.x < -w || pt.x > w * 2 || pt.y < -h || pt.y > h * 2 {
                prevVisible = false; started = false; continue
            }
            if !started || !prevVisible { path.move(to: pt); started = true }
            else { path.addLine(to: pt) }
            prevVisible = true
        }
        if close { path.closeSubpath() }
        return path
    }

    // MARK: - Drawing Layers

    private func drawOcean(context: GraphicsContext, w: Double, h: Double,
                           lamp: CGPoint, flicker: Double) {
        // Deep ocean with warm pool near lamp
        let bgGrad = Gradient(stops: [
            .init(color: Color(hex: "0F1A2E"), location: 0),
            .init(color: Color(hex: "080E1A"), location: 1),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(bgGrad, center: lamp,
                                  startRadius: 0, endRadius: max(w, h))
        )

        // Warm lamp pool — subtle gold tint near lamp
        let warmSize = max(w, h) * 0.7
        let warmGrad = Gradient(stops: [
            .init(color: Color(hex: "D4A843").opacity(0.05 * flicker), location: 0),
            .init(color: .clear, location: 0.7),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(warmGrad, center: lamp,
                                  startRadius: 0, endRadius: warmSize)
        )
    }

    private func drawGraticule(context: GraphicsContext, w: Double, h: Double,
                                centerLat: Double, centerLng: Double, bearing: Double) {
        for lat in stride(from: -80.0, through: 80.0, by: 10.0) {
            var line = Path()
            var lineStarted = false
            var prevVis = false
            for lngSample in stride(from: -180.0, through: 180.0, by: 5.0) {
                let proj = project(lat, lngSample, centerLat: centerLat, centerLng: centerLng,
                                  bearing: bearing, w: w, h: h)
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
                let proj = project(latSample, lngLine, centerLat: centerLat, centerLng: centerLng,
                                  bearing: bearing, w: w, h: h)
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
                          centerLat: Double, centerLng: Double, bearing: Double,
                          lamp: CGPoint, flicker: Double) {
        for polygon in geoData.landPolygons {
            let path = buildProjectedPath(
                points: polygon.points,
                centerLat: centerLat, centerLng: centerLng, bearing: bearing,
                w: w, h: h, close: true
            )
            context.fill(path, with: .color(Color(hex: "152240").opacity(0.9)))
        }
    }

    private func drawCoastlines(context: GraphicsContext, w: Double, h: Double,
                                 centerLat: Double, centerLng: Double, bearing: Double,
                                 lamp: CGPoint, flicker: Double, time: Double) {
        let shimmer = isScrolling ? 0.7 : (0.6 + 0.15 * sin(time * 1.2))
        for line in geoData.coastlines {
            let path = buildProjectedPath(
                points: line.points,
                centerLat: centerLat, centerLng: centerLng, bearing: bearing,
                w: w, h: h, close: false
            )
            // Glow layer
            context.stroke(path,
                with: .color(Color(hex: "D4A843").opacity(0.12 * flicker)),
                style: StrokeStyle(lineWidth: 3.0, lineCap: .round))
            // Bright line
            context.stroke(path,
                with: .color(Color(hex: "D4A843").opacity(shimmer * flicker)),
                style: StrokeStyle(lineWidth: 0.8, lineCap: .round))
        }
    }

    private func drawGreatCirclePath(context: GraphicsContext, w: Double, h: Double,
                                      centerLat: Double, centerLng: Double, bearing: Double) {
        var path = Path()
        var started = false
        var prevVis = false
        for t in stride(from: -90.0, through: 90.0, by: 1.0) {
            let pos = greatCirclePosition(t: t)
            let proj = project(pos.lat, pos.lng, centerLat: centerLat, centerLng: centerLng,
                              bearing: bearing, w: w, h: h)
            if !proj.visible { prevVis = false; started = false; continue }
            let pt = CGPoint(x: proj.x, y: proj.y)
            if !started || !prevVis { path.move(to: pt); started = true }
            else { path.addLine(to: pt) }
            prevVis = true
        }
        context.stroke(path,
            with: .color(Color(hex: "D4A843").opacity(0.06)),
            style: StrokeStyle(lineWidth: 0.5, dash: [4, 6]))
    }

    // MARK: - Lamp Lighting (replaces old vignette)

    private func drawLampVignette(context: GraphicsContext, w: Double, h: Double,
                                   lamp: CGPoint, flicker: Double) {
        // Directional shadow — darker on the side AWAY from the lamp
        let shadowGrad = Gradient(stops: [
            .init(color: .clear, location: 0.15),
            .init(color: .black.opacity(0.25), location: 0.5),
            .init(color: .black.opacity(0.55 * flicker), location: 1.0),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(shadowGrad, center: lamp,
                                  startRadius: 0, endRadius: max(w, h) * 0.75)
        )

        // Fixed bezel shadow — always darkens the very edges
        let bezelGrad = Gradient(stops: [
            .init(color: .clear, location: 0.4),
            .init(color: .black.opacity(0.12), location: 1.0),
        ])
        let center = CGPoint(x: w / 2, y: h / 2)
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(bezelGrad, center: center,
                                  startRadius: 0, endRadius: max(w, h) * 0.6)
        )
    }


    private func drawCompass(context: GraphicsContext, w: Double, h: Double,
                              centerLat: Double, centerLng: Double, bearing: Double) {
        let compassFont = Font.system(size: 9, weight: .light, design: .serif)
        let compassColor = Color(hex: "D4A843").opacity(0.2)
        let offset = visibleRange * 0.8

        let directions: [(String, Double, Double)] = [
            ("N", centerLat + offset, centerLng),
            ("S", centerLat - offset, centerLng),
            ("E", centerLat, centerLng + offset / max(0.1, cos(centerLat * .pi / 180))),
            ("W", centerLat, centerLng - offset / max(0.1, cos(centerLat * .pi / 180))),
        ]

        for (label, lat, lng) in directions {
            let proj = project(lat, lng,
                              centerLat: centerLat, centerLng: centerLng,
                              bearing: bearing, w: w, h: h)
            guard proj.visible else { continue }
            let pt = CGPoint(x: proj.x, y: proj.y)
            guard pt.x > 5 && pt.x < w - 5 && pt.y > 5 && pt.y < h - 5 else { continue }
            let text = Text(label).font(compassFont).foregroundColor(compassColor)
            context.draw(context.resolve(text), at: pt, anchor: .center)
        }
    }

    // MARK: - Labels

    private var latLabel: String {
        let lat = currentPosition.lat
        return String(format: "%.1f°%@", abs(lat), lat >= 0 ? "N" : "S")
    }

    private var lngLabel: String {
        let lng = currentPosition.lng
        return String(format: "%.1f°%@", abs(lng), lng >= 0 ? "E" : "W")
    }
}
