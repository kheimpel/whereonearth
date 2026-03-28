import Foundation

@Observable
final class GameSession {
    let clues: [Clue]
    private(set) var currentIndex: Int = 0
    private(set) var results: [ScoreResult] = []
    private(set) var phase: Phase = .showingClue

    enum Phase {
        case showingClue
        case guessing
        case showingResult
        case finished
    }

    var currentClue: Clue? {
        guard currentIndex < clues.count else { return nil }
        return clues[currentIndex]
    }

    var totalScore: Int {
        results.reduce(0) { $0 + $1.points }
    }

    var maxPossibleScore: Int {
        clues.count * 3
    }

    var isFinished: Bool {
        phase == .finished
    }

    init(clues: [Clue]) {
        self.clues = clues
    }

    func startGuessing() {
        phase = .guessing
    }

    func submitGuess(lat: Double, lng: Double) {
        guard let clue = currentClue else { return }
        let result = GameEngine.score(guessLat: lat, guessLng: lng, for: clue)
        results.append(result)
        phase = .showingResult
    }

    func nextClue() {
        currentIndex += 1
        if currentIndex >= clues.count {
            phase = .finished
        } else {
            phase = .showingClue
        }
    }
}
