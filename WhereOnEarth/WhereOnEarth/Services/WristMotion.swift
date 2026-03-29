import CoreMotion
import SwiftUI

@Observable
final class WristMotion {
    private let motion = CMMotionManager()

    /// Lamp position on screen, normalized 0–1.
    /// Default (wrist flat): (0.5, 0.3) — lamp slightly above center.
    var lampX: Double = 0.5
    var lampY: Double = 0.3

    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 20 // 20 Hz
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let attitude = data?.attitude, let self else { return }
            self.lampX = 0.5 + sin(attitude.roll) * 0.25
            self.lampY = 0.3 + sin(attitude.pitch) * 0.2
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
    }
}
