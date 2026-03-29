import SwiftUI

/// The brass meridian wire hovering above the globe surface.
/// Uses SwiftUI views with real `.shadow()` for depth separation,
/// and `.drawingGroup()` for Metal-backed compositing.
struct BrassArmatureView: View {
    let lampX: Double
    let lampY: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let flicker = 1.0 + sin(time * 2.5) * 0.02
            let glowBreath = 0.15 + 0.05 * sin(time * 2.0)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h / 2

                // Shadow offset from lamp (parallax — shadow falls away from light)
                let shadowDx = (cx - lampX * w) * 0.08
                let shadowDy = (cy - lampY * h) * 0.08

                ZStack {
                    // -- VERTICAL BRASS WIRE --

                    // The wire itself — ultra thin gold line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                stops: wireGradientStops(lampY: lampY, flicker: flicker),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.0, height: h)
                        .position(x: cx, y: cy)
                        // Real shadow — blurred, offset, creates depth
                        .shadow(
                            color: .black.opacity(0.4),
                            radius: 3,
                            x: shadowDx,
                            y: shadowDy
                        )

                    // -- CENTER INDICATOR (the brass pointer) --

                    // Outer glow
                    Circle()
                        .fill(Color(hex: "D4A843").opacity(glowBreath * flicker))
                        .frame(width: 20, height: 20)
                        .position(x: cx, y: cy)

                    // Gold body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFD959").opacity(0.9 * flicker),  // bright center
                                    Color(hex: "D9A621").opacity(0.8 * flicker),  // mid gold
                                    Color(hex: "8C5914").opacity(0.7 * flicker),  // dark edge
                                ],
                                center: UnitPoint(
                                    x: lampX,
                                    y: lampY
                                ),
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 10, height: 10)
                        .position(x: cx, y: cy)
                        .shadow(
                            color: .black.opacity(0.5),
                            radius: 4,
                            x: shadowDx * 1.5,
                            y: shadowDy * 1.5
                        )

                    // Specular hot spot on indicator — gold-tinted, NOT white
                    Circle()
                        .fill(Color(hex: "FFF2B3").opacity(specularIntensity(cx: cx, cy: cy, flicker: flicker)))
                        .frame(width: 4, height: 4)
                        .position(
                            x: cx + (lampX - 0.5) * 3,  // specular shifts toward lamp
                            y: cy + (lampY - 0.5) * 3
                        )

                    // -- HORIZONTAL TICK MARKS (subtle, for precision) --
                    Rectangle()
                        .fill(Color(hex: "8C5914").opacity(0.3 * flicker))
                        .frame(width: 8, height: 0.5)
                        .position(x: cx - 9, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: shadowDx, y: shadowDy)

                    Rectangle()
                        .fill(Color(hex: "8C5914").opacity(0.3 * flicker))
                        .frame(width: 8, height: 0.5)
                        .position(x: cx + 9, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: shadowDx, y: shadowDy)
                }
                .drawingGroup() // Metal-backed compositing for all the layers
            }
        }
    }

    /// Gradient stops for the vertical wire — specular slides with lamp Y
    private func wireGradientStops(lampY: Double, flicker: Double) -> [Gradient.Stop] {
        let darkGold = Color(hex: "8C5914").opacity(0.5 * flicker)
        let midGold = Color(hex: "D9A621").opacity(0.6 * flicker)
        let brightGold = Color(hex: "FFD959").opacity(0.7 * flicker)

        // Specular band centered at lampY
        let specCenter = lampY
        let specWidth = 0.08

        return [
            .init(color: darkGold, location: 0),
            .init(color: darkGold, location: max(0, specCenter - specWidth * 2)),
            .init(color: midGold, location: max(0, specCenter - specWidth)),
            .init(color: brightGold, location: specCenter),
            .init(color: midGold, location: min(1, specCenter + specWidth)),
            .init(color: darkGold, location: min(1, specCenter + specWidth * 2)),
            .init(color: darkGold, location: 1),
        ]
    }

    /// Specular intensity on the center indicator
    private func specularIntensity(cx: Double, cy: Double, flicker: Double) -> Double {
        let lampPx = lampX * cx * 2
        let lampPy = lampY * cy * 2
        let dist = hypot(cx - lampPx, cy - lampPy)
        let maxDist = hypot(cx, cy)
        return max(0, (1.0 - dist / maxDist) * 0.7 * flicker)
    }
}
