import AVKit
import SwiftUI

/// Hides the watchOS system time by exploiting the VideoPlayer behavior.
/// When a VideoPlayer is visible, watchOS automatically hides the clock.
/// We make the player invisible and use it as a background view.
struct TimeHider: View {
    var body: some View {
        VideoPlayer(player: nil, videoOverlay: {})
            .focusable(false)
            .disabled(true)
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
