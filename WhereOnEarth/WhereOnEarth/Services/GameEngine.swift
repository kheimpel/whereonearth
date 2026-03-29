import Foundation

struct ScoreResult: Sendable {
    /// Points scored, 0–5000. Exponential decay based on distance.
    let points: Int
    /// Distance from guess to answer in kilometers
    let distanceKm: Double

    /// Human-readable accuracy tier (derived from points, for display)
    var tier: String {
        switch points {
        case 4500...5000: return "SPOT ON"
        case 3500..<4500: return "EXCELLENT"
        case 2000..<3500: return "CLOSE"
        case 500..<2000: return "FAR"
        default: return "WAY OFF"
        }
    }
}

enum GameEngine {
    /// Maximum points per round
    static let maxPoints = 5000

    /// Earth's half-circumference in km — the "map diagonal" for our global game
    private static let mapDiagonal: Double = 20_000.0

    /// GeoGuessr-style exponential scoring.
    /// score = 5000 × e^(-10 × distance / mapDiagonal)
    /// - 0 km → 5000
    /// - 150 km → ~4638
    /// - 500 km → ~3894
    /// - 1000 km → ~3033
    /// - 2000 km → ~1839
    /// - 5000 km → ~410
    /// - 10000 km → ~34
    static func score(guessLat: Double, guessLng: Double, for clue: Clue) -> ScoreResult {
        let km = haversineDistance(
            lat1: guessLat, lng1: guessLng,
            lat2: clue.answerLatitude, lng2: clue.answerLongitude
        )

        // Perfect score for < 25m (same as GeoGuessr)
        if km < 0.025 {
            return ScoreResult(points: maxPoints, distanceKm: km)
        }

        let raw = Double(maxPoints) * exp(-10.0 * km / mapDiagonal)
        let points = max(0, min(maxPoints, Int(round(raw))))

        return ScoreResult(points: points, distanceKm: km)
    }

    /// Haversine formula — great circle distance in km
    static func haversineDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let R = 6371.0
        let phi1 = lat1 * .pi / 180
        let phi2 = lat2 * .pi / 180
        let dPhi = (lat2 - lat1) * .pi / 180
        var dLam = (lng2 - lng1) * .pi / 180
        if dLam > .pi { dLam -= 2 * .pi }
        if dLam < -.pi { dLam += 2 * .pi }

        let a = sin(dPhi / 2) * sin(dPhi / 2) +
                cos(phi1) * cos(phi2) * sin(dLam / 2) * sin(dLam / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
