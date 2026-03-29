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
                VStack(spacing: 12) {
                    Text("SESSION\nCOMPLETE")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: "D4A843"))

                    Text("\(session.totalScore)/\(session.maxPossibleScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "E8DCC8"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "0C1425"))
            }
        }
        .navigationBarBackButtonHidden(session.phase != .finished)
    }
}
