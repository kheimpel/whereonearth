import SwiftUI

struct MapStripView: View {
    let clue: Clue
    let onSubmit: ((Double, Double)) -> Void
    let geoData: GeoData
    let wristMotion: WristMotion

    @State private var scrollT: Double = 0.0
    @State private var isScrolling = false
    @State private var lastScrollT: Double = 0.0
    @State private var initialized = false

    private let visibleRange: Double = 18.0

    private var currentPosition: (lat: Double, lng: Double) {
        greatCirclePosition(t: scrollT)
    }

    var body: some View {
        ZStack {
            // Canvas map
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
                    drawLand(context: context, w: w, h: h,
                             centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawCoastlines(context: context, w: w, h: h,
                                   centerLat: pos.lat, centerLng: pos.lng, bearing: brng,
                                   flicker: flicker, time: time)
                    drawGreatCirclePath(context: context, w: w, h: h,
                                        centerLat: pos.lat, centerLng: pos.lng, bearing: brng)
                    drawLampVignette(context: context, w: w, h: h, lamp: lamp, flicker: flicker)
                }
            }
            .focusable()
            .digitalCrownRotation($scrollT, from: -180.0, through: 180.0,
                                   by: 2.0, sensitivity: .high,
                                   isContinuous: true, isHapticFeedbackEnabled: true)
            .ignoresSafeArea()

            // Brass armature overlay
            BrassArmatureView(lampX: wristMotion.lampX, lampY: wristMotion.lampY)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Bottom floating pill — compact, hugs bottom edge
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(continentLabel ?? " ")
                            .font(Theme.caption)
                            .tracking(1.5)
                            .foregroundStyle(Theme.gold.opacity(continentLabel != nil ? 0.4 : 0))
                        Text(coordinateLabel)
                            .font(Theme.caption)
                            .foregroundStyle(Theme.parchment.opacity(0.65))
                    }

                    Spacer()

                    // Lock In — always visible, small gold circle
                    Button(action: { onSubmit((currentPosition.lat, currentPosition.lng)) }) {
                        Circle()
                            .fill(Theme.gold.opacity(0.5))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .strokeBorder(Theme.ocean, lineWidth: 1)
                                    .frame(width: 10, height: 10)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Theme.ocean.opacity(0.8))
                        .overlay(
                            Capsule()
                                .strokeBorder(Theme.gold.opacity(0.08), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 6)
                .padding(.bottom, 2)
            }
        }
        .onChange(of: scrollT) {
            isScrolling = true
            lastScrollT = scrollT
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if lastScrollT == scrollT { isScrolling = false }
            }
        }
        .onAppear {
            wristMotion.start()
            // Start at a random offset so player must scroll to find the answer (at t=0)
            if !initialized {
                // Random offset — at least 20° away so the answer isn't immediately visible
                var offset = Double.random(in: -180...180)
                if abs(offset) < 20 { offset = offset < 0 ? -20 : 20 }
                scrollT = offset
                initialized = true
            }
        }
        .onDisappear { wristMotion.stop() }
        .toolbar(.hidden, for: .navigationBar)
        .persistentSystemOverlays(.hidden)
    }

    // MARK: - Great Circle Navigation

    /// The great circle is centered on the answer point (t=0 = the answer).
    /// The player starts at a random offset and scrolls to find t=0.
    private func greatCirclePosition(t: Double) -> (lat: Double, lng: Double) {
        let tRad = t * .pi / 180
        let lat0 = clue.answerLatitude * .pi / 180
        let lng0 = clue.answerLongitude * .pi / 180
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



    // MARK: - Labels

    private var coordinateLabel: String {
        let pos = currentPosition
        let latDir = pos.lat >= 0 ? "N" : "S"
        let lngDir = pos.lng >= 0 ? "E" : "W"
        return String(format: "%.1f°%@ · %.1f°%@", abs(pos.lat), latDir, abs(pos.lng), lngDir)
    }

    private var continentLabel: String? {
        let pos = currentPosition
        return geoData.continentAt(lat: pos.lat, lng: pos.lng)?.uppercased()
    }

    // MARK: - Orthographic Projection

    private func localBearing(at t: Double) -> Double {
        let dt = 2.0  // degrees — increased from 0.5 for stability near apex
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
        // Deep ocean base with radial depth
        let bgGrad = Gradient(stops: [
            .init(color: Color(hex: "0F1A2E"), location: 0),
            .init(color: Color(hex: "080E1A"), location: 1),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(bgGrad, center: lamp, startRadius: 0, endRadius: max(w, h))
        )

        // Warm gold pool where the desk lamp hits the globe surface
        let warmGrad = Gradient(stops: [
            .init(color: Color(hex: "D4A843").opacity(0.1 * flicker), location: 0),
            .init(color: Color(hex: "D4A843").opacity(0.03 * flicker), location: 0.4),
            .init(color: .clear, location: 0.7),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(warmGrad, center: lamp, startRadius: 0, endRadius: max(w, h) * 0.7)
        )
    }

    private func drawLand(context: GraphicsContext, w: Double, h: Double,
                          centerLat: Double, centerLng: Double, bearing: Double) {
        for polygon in geoData.landPolygons {
            let path = buildProjectedPath(
                points: polygon.points,
                centerLat: centerLat, centerLng: centerLng, bearing: bearing,
                w: w, h: h, close: true
            )
            context.fill(path, with: .color(Color(hex: "1A2D4A")))
        }
    }

    private func drawCoastlines(context: GraphicsContext, w: Double, h: Double,
                                 centerLat: Double, centerLng: Double, bearing: Double,
                                 flicker: Double, time: Double) {
        // Shimmer: coastlines pulse when Crown is stationary
        let brightOpacity = isScrolling ? 0.7 : (0.6 + 0.15 * sin(time * 1.2))
        for line in geoData.coastlines {
            let path = buildProjectedPath(
                points: line.points,
                centerLat: centerLat, centerLng: centerLng, bearing: bearing,
                w: w, h: h, close: false
            )
            // Variable weight: major landmasses thicker, small islands thinner
            let pointCount = line.points.count
            let brightWidth: Double = pointCount > 100 ? 1.2 : (pointCount > 30 ? 0.8 : 0.5)
            let glowWidth: Double = pointCount > 100 ? 4.0 : (pointCount > 30 ? 3.0 : 2.0)

            // Wide dim glow — simulates light scatter
            context.stroke(path,
                with: .color(Color(hex: "D4A843").opacity(0.15 * flicker)),
                style: StrokeStyle(lineWidth: glowWidth, lineCap: .round))
            // Narrow bright line — the actual coastline
            context.stroke(path,
                with: .color(Color(hex: "D4A843").opacity(brightOpacity * flicker)),
                style: StrokeStyle(lineWidth: brightWidth, lineCap: .round))
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

    private func drawLampVignette(context: GraphicsContext, w: Double, h: Double,
                                   lamp: CGPoint, flicker: Double) {
        // Directional shadow — darker on the side away from the desk lamp
        let shadowGrad = Gradient(stops: [
            .init(color: .clear, location: 0.1),
            .init(color: .black.opacity(0.3), location: 0.4),
            .init(color: .black.opacity(0.6 * flicker), location: 0.7),
            .init(color: .black.opacity(0.75 * flicker), location: 1.0),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(shadowGrad, center: lamp,
                                  startRadius: 0, endRadius: max(w, h) * 0.7)
        )

        // Fixed bezel shadow — globe curvature, always darkens edges
        let bezelGrad = Gradient(stops: [
            .init(color: .clear, location: 0.3),
            .init(color: .black.opacity(0.15), location: 0.6),
            .init(color: .black.opacity(0.3), location: 1.0),
        ])
        let center = CGPoint(x: w / 2, y: h / 2)
        context.fill(
            Path(CGRect(origin: .zero, size: CGSize(width: w, height: h))),
            with: .radialGradient(bezelGrad, center: center,
                                  startRadius: 0, endRadius: max(w, h) * 0.55)
        )
    }
}
