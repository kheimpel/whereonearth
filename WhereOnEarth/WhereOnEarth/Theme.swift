import SwiftUI

/// App-wide design constants.
/// Every view uses serif fonts and the gold/parchment/navy palette.
enum Theme {
    // MARK: - Colors

    static let ocean = Color(hex: "0C1425")
    static let gold = Color(hex: "D4A843")
    static let parchment = Color(hex: "E8DCC8")

    // MARK: - Fonts

    /// All text in the app uses serif design to match the nautical chart aesthetic.
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
