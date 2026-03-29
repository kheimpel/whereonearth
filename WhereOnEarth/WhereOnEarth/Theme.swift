import SwiftUI

/// App-wide design system.
/// See docs/design-system.md for the full reference.
enum Theme {
    // MARK: - Colors

    static let ocean = Color(hex: "0C1425")
    static let gold = Color(hex: "D4A843")
    static let parchment = Color(hex: "E8DCC8")
    static let land = Color(hex: "152240")

    // MARK: - Type Scale (all serif, min 11pt)

    /// 40pt light — score numbers, hero text
    static let display = Font.system(size: 40, weight: .light, design: .serif)
    /// 20pt light — app title
    static let title = Font.system(size: 20, weight: .light, design: .serif)
    /// 15pt regular — clue text, country names
    static let body = Font.system(size: 15, weight: .regular, design: .serif)
    /// 12pt medium — button labels (PLAY, GUESS, LOCK IN)
    static let label = Font.system(size: 12, weight: .medium, design: .serif)
    /// 11pt regular — coordinates, distance, metadata (minimum readable)
    static let caption = Font.system(size: 11, weight: .regular, design: .serif)

    /// Custom serif font for sizes not in the scale
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: max(size, 11), weight: weight, design: .serif)
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat = 2
    static let spacingSM: CGFloat = 4
    static let spacingMD: CGFloat = 8
    static let spacingLG: CGFloat = 12
    static let spacingXL: CGFloat = 16
    static let margin: CGFloat = 10

    // MARK: - Button Helpers

    /// Primary button modifier (full-width capsule, gold bg)
    struct PrimaryButton: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Theme.label)
                .tracking(3)
                .foregroundStyle(Theme.ocean)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.gold.opacity(0.8))
                .clipShape(Capsule())
        }
    }

    /// Ghost button modifier (text only)
    struct GhostButton: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Theme.caption)
                .fontWeight(.medium)
                .tracking(2)
                .foregroundStyle(Theme.gold.opacity(0.5))
        }
    }
}

extension View {
    func primaryButton() -> some View { modifier(Theme.PrimaryButton()) }
    func ghostButton() -> some View { modifier(Theme.GhostButton()) }
}
