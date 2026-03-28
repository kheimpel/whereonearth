import Foundation

@Observable
final class ClueBank {
    private(set) var allClues: [Clue] = []

    init() {
        loadClues()
    }

    func loadClues() {
        guard let url = Bundle.main.url(forResource: "clues", withExtension: "json") else {
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        allClues = (try? JSONDecoder().decode([Clue].self, from: data)) ?? []
    }

    func cluesForSession(count: Int = 5) -> [Clue] {
        Array(allClues.shuffled().prefix(count))
    }
}
