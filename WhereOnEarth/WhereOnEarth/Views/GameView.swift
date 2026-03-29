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
                            HapticsService.play(for: lastResult.accuracy)
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
                VStack(spacing: 4) {
                    Spacer()
                    Text("\(session.totalScore)")
                        .font(Theme.font(size: 44, weight: .light))
                        .foregroundStyle(Theme.gold)
                        .minimumScaleFactor(0.6)
                    Text("out of \(session.maxPossibleScore)")
                        .font(Theme.font(size: 11))
                        .foregroundStyle(Theme.parchment.opacity(0.4))
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Rectangle()
                        .fill(Theme.gold.opacity(0.15))
                        .frame(width: 40, height: 0.5)
                    Spacer()
                        .frame(height: 12)
                    Text("SESSION COMPLETE")
                        .font(Theme.font(size: 9, weight: .medium))
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
}
