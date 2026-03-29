import WatchKit

enum HapticsService {
    static func play(for result: ScoreResult) {
        switch result.points {
        case 4500...5000:
            WKInterfaceDevice.current().play(.success)
        case 3500..<4500:
            WKInterfaceDevice.current().play(.directionUp)
        case 2000..<3500:
            WKInterfaceDevice.current().play(.click)
        default:
            WKInterfaceDevice.current().play(.failure)
        }
    }
}
