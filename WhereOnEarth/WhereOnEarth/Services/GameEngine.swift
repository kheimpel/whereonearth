import Foundation

struct ScoreResult: Sendable {
    let points: Int
    let accuracy: Accuracy
    let distanceKm: Double

    enum Accuracy: Sendable {
        case country
        case region
        case continent
        case wrong
    }
}

enum GameEngine {
    static let countryThreshold: Double = 200.0
    static let regionThreshold: Double = 800.0
    static let continentThreshold: Double = 2500.0

    static func haversineDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let R = 6371.0
        let phi1 = lat1 * .pi / 180
        let phi2 = lat2 * .pi / 180
        let dPhi = (lat2 - lat1) * .pi / 180
        var dLam = (lng2 - lng1) * .pi / 180
        // Wrap longitude difference to [-π, π]
        if dLam > .pi { dLam -= 2 * .pi }
        if dLam < -.pi { dLam += 2 * .pi }

        let a = sin(dPhi / 2) * sin(dPhi / 2) +
                cos(phi1) * cos(phi2) * sin(dLam / 2) * sin(dLam / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    static func score(guessLat: Double, guessLng: Double, for clue: Clue) -> ScoreResult {
        let answerLat = clue.scrollCenterLat
        let km = haversineDistance(lat1: guessLat, lng1: guessLng,
                                   lat2: answerLat, lng2: clue.answerLongitude)

        if km <= countryThreshold {
            return ScoreResult(points: 3, accuracy: .country, distanceKm: km)
        } else if km <= regionThreshold {
            return ScoreResult(points: 2, accuracy: .region, distanceKm: km)
        } else if km <= continentThreshold {
            return ScoreResult(points: 1, accuracy: .continent, distanceKm: km)
        } else {
            return ScoreResult(points: 0, accuracy: .wrong, distanceKm: km)
        }
    }

    // Backward-compatible: uses scrollCenterLat as the guess latitude
    static func score(guessLongitude: Double, for clue: Clue) -> ScoreResult {
        return score(guessLat: clue.scrollCenterLat, guessLng: guessLongitude, for: clue)
    }
}
