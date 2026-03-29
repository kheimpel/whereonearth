import SwiftUI

struct GameView: View {
    let geoData: GeoData
    let wristMotion: WristMotion
    @State private var session: GameSession

    init(clues: [Clue], geoData: GeoData, wristMotion: WristMotion) {
        self.geoData = geoData
        self.wristMotion = wristMotion
        _session = State(initialValue: GameSession(clues: clues))
    }

    var body: some View {
        Group {
            switch session.phase {
            case .showingClue:
                if let clue = session.currentClue {
                    ClueView(clue: clue) {
                        session.startGuessing()
                    }
                }
            case .guessing:
                if let clue = session.currentClue {
                    MapStripView(clue: clue, onSubmit: { (lat, lng) in
                        session.submitGuess(lat: lat, lng: lng)
                        if let lastResult = session.results.last {
                            HapticsService.play(for: lastResult)
                        }
                    }, geoData: geoData, wristMotion: wristMotion)
                }
            case .showingResult:
                if let clue = session.currentClue, let result = session.results.last {
                    ResultView(clue: clue, result: result) {
                        session.nextClue()
                    }
                }
            case .finished:
                VStack(spacing: Theme.spacingSM) {
                    Spacer()
                    Text(formattedScore(session.totalScore))
                        .font(Theme.display)
                        .foregroundStyle(Theme.gold)
                        .minimumScaleFactor(0.6)
                    Text("out of \(formattedScore(session.maxPossibleScore))")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.parchment.opacity(0.4))
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Rectangle()
                        .fill(Theme.gold.opacity(0.15))
                        .frame(width: 40, height: 0.5)
                    Spacer()
                        .frame(height: Theme.spacingLG)
                    Text("SESSION COMPLETE")
                        .font(Theme.caption)
                        .fontWeight(.medium)
                        .tracking(3)
                        .foregroundStyle(Theme.parchment.opacity(0.35))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.ocean)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .navigationBarBackButtonHidden(session.phase != .finished)
    }

    private func formattedScore(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
