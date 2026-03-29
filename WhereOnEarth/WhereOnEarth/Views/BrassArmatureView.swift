import SwiftUI

/// The brass meridian wire hovering above the globe surface.
/// A single vertical gold wire with a center indicator dot.
/// Real `.shadow()` creates depth separation from the map below.
/// `.drawingGroup()` enables Metal-backed compositing.
/// All lighting derives from lampX/lampY — the virtual desk lamp position.
struct BrassArmatureView: View {
    let lampX: Double
    let lampY: Double

    // -- Physical constants --

    /// Width of the brass wire in points
    private let wireWidth: CGFloat = 1.0
    /// Diameter of the center indicator dot
    private let indicatorSize: CGFloat = 10
    /// Diameter of the breathing outer glow
    private let glowSize: CGFloat = 20
    /// Length of horizontal precision tick marks
    private let tickLength: CGFloat = 8
    /// Height of horizontal tick marks
    private let tickHeight: CGFloat = 0.5
    /// Shadow parallax factor — how much shadow offsets per pixel of lamp distance
    private let shadowParallaxFactor: Double = 0.08
    /// Indicator gets 1.5× more shadow offset to emphasize depth
    private let indicatorShadowFactor: Double = 0.12
    /// Width of the specular band on the wire (fraction of total height)
    private let specularBandWidth: Double = 0.08

    // -- Gold color palette --
    // Metals have COLORED specular highlights. Gold specular = gold, NOT white.

    /// Shadow zones and wire body
    private let darkGold = Color(hex: "8C5914")
    /// Primary visible tone
    private let midGold = Color(hex: "D9A621")
    /// Near-specular zones
    private let brightGold = Color(hex: "FFD959")
    /// Core of specular hot spot — gold-tinted, never pure white
    private let specularGold = Color(hex: "FFF2B3")
    /// Ambient glow around indicator
    private let glowGold = Color(hex: "D4A843")

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            // Lamp flicker: ±2% intensity at 0.4Hz — barely visible, adds warmth
            let flicker = 1.0 + sin(time * 2.5) * 0.02
            // Breathing glow: 15±5% opacity at 2Hz
            let glowBreath = 0.15 + 0.05 * sin(time * 2.0)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h / 2

                // Shadow offset: parallax from lamp — shadow falls AWAY from light
                let shadowDx = (cx - lampX * w) * shadowParallaxFactor
                let shadowDy = (cy - lampY * h) * shadowParallaxFactor
                let indShadowDx = (cx - lampX * w) * indicatorShadowFactor
                let indShadowDy = (cy - lampY * h) * indicatorShadowFactor

                ZStack {
                    // -- VERTICAL BRASS WIRE --
                    // LinearGradient with specular band that slides to lampY
                    Rectangle()
                        .fill(LinearGradient(
                            stops: wireGradientStops(flicker: flicker),
                            startPoint: .top, endPoint: .bottom
                        ))
                        .frame(width: wireWidth, height: h)
                        .position(x: cx, y: cy)
                        .shadow(color: .black.opacity(0.4), radius: 3,
                                x: shadowDx, y: shadowDy)

                    // -- BREATHING OUTER GLOW --
                    // Warm ambient light around the indicator
                    Circle()
                        .fill(glowGold.opacity(glowBreath * flicker))
                        .frame(width: glowSize, height: glowSize)
                        .position(x: cx, y: cy)

                    // -- GOLD INDICATOR BODY --
                    // RadialGradient with center offset toward lamp
                    // Brighter on the lamp side, darker on the shadow side
                    Circle()
                        .fill(RadialGradient(
                            colors: [
                                brightGold.opacity(0.9 * flicker),
                                midGold.opacity(0.8 * flicker),
                                darkGold.opacity(0.7 * flicker),
                            ],
                            center: UnitPoint(x: lampX, y: lampY),
                            startRadius: 0, endRadius: 8
                        ))
                        .frame(width: indicatorSize, height: indicatorSize)
                        .position(x: cx, y: cy)
                        .shadow(color: .black.opacity(0.5), radius: 4,
                                x: indShadowDx, y: indShadowDy)

                    // -- SPECULAR HOT SPOT --
                    // Gold-tinted (NOT white) — this is what makes it read as metal
                    // Shifts toward lamp position
                    Circle()
                        .fill(specularGold.opacity(specularIntensity(flicker: flicker)))
                        .frame(width: 4, height: 4)
                        .position(
                            x: cx + (lampX - 0.5) * 3,
                            y: cy + (lampY - 0.5) * 3
                        )

                    // -- HORIZONTAL PRECISION TICKS --
                    // Left tick
                    Rectangle()
                        .fill(darkGold.opacity(0.3 * flicker))
                        .frame(width: tickLength, height: tickHeight)
                        .position(x: cx - indicatorSize / 2 - tickLength / 2 - 1, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2,
                                x: shadowDx, y: shadowDy)

                    // Right tick
                    Rectangle()
                        .fill(darkGold.opacity(0.3 * flicker))
                        .frame(width: tickLength, height: tickHeight)
                        .position(x: cx + indicatorSize / 2 + tickLength / 2 + 1, y: cy)
                        .shadow(color: .black.opacity(0.2), radius: 2,
                                x: shadowDx, y: shadowDy)
                }
                .drawingGroup() // Metal-backed compositing for all layers
            }
        }
    }

    /// Gradient stops for the vertical wire.
    /// Dark gold body with a bright specular band centered at lampY.
    /// When wrist tilts, lampY changes and the specular slides along the wire.
    private func wireGradientStops(flicker: Double) -> [Gradient.Stop] {
        let dark = darkGold.opacity(0.5 * flicker)
        let mid = midGold.opacity(0.6 * flicker)
        let bright = brightGold.opacity(0.7 * flicker)
        let bandCenter = lampY
        let halfBand = specularBandWidth

        return [
            .init(color: dark, location: 0),
            .init(color: dark, location: max(0, bandCenter - halfBand * 2)),
            .init(color: mid, location: max(0, bandCenter - halfBand)),
            .init(color: bright, location: bandCenter),
            .init(color: mid, location: min(1, bandCenter + halfBand)),
            .init(color: dark, location: min(1, bandCenter + halfBand * 2)),
            .init(color: dark, location: 1),
        ]
    }

    /// Specular intensity on the center indicator.
    /// Brighter when lamp is closer to screen center (more direct illumination).
    private func specularIntensity(flicker: Double) -> Double {
        let lampDist = hypot(lampX - 0.5, lampY - 0.5)
        return max(0, (1.0 - lampDist * 2.0) * 0.7 * flicker)
    }
}
