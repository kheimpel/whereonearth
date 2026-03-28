import Foundation

struct ScoreResult: Sendable {
    let points: Int
    let accuracy: Accuracy
    let distanceDegrees: Double

    enum Accuracy: Sendable {
        case country
        case region
        case continent
        case wrong
    }
}

enum GameEngine {
    static let countryThreshold: Double = 10.0
    static let regionThreshold: Double = 30.0
    static let continentThreshold: Double = 60.0

    static func score(guessLongitude: Double, for clue: Clue) -> ScoreResult {
        let distance = longitudeDistance(from: guessLongitude, to: clue.answerLongitude)

        if distance <= countryThreshold {
            return ScoreResult(points: 3, accuracy: .country, distanceDegrees: distance)
        } else if distance <= regionThreshold {
            return ScoreResult(points: 2, accuracy: .region, distanceDegrees: distance)
        } else if distance <= continentThreshold {
            return ScoreResult(points: 1, accuracy: .continent, distanceDegrees: distance)
        } else {
            return ScoreResult(points: 0, accuracy: .wrong, distanceDegrees: distance)
        }
    }

    static func longitudeDistance(from a: Double, to b: Double) -> Double {
        var diff = abs(a - b)
        if diff > 180 {
            diff = 360 - diff
        }
        return diff
    }
}
