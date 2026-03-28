import WatchKit

enum HapticsService {
    static func play(for accuracy: ScoreResult.Accuracy) {
        switch accuracy {
        case .country:
            WKInterfaceDevice.current().play(.success)
        case .region:
            WKInterfaceDevice.current().play(.directionUp)
        case .continent:
            WKInterfaceDevice.current().play(.click)
        case .wrong:
            WKInterfaceDevice.current().play(.failure)
        }
    }
}
