import Foundation
import Testing
@testable import WhereOnEarth

@Test func clueDecodesFromJSON() throws {
    let json = """
    {
        "id": "clue_001",
        "type": "cultural",
        "text": "Trains arrive within 7 seconds of schedule on average.",
        "answer_longitude": 139.7,
        "answer_country": "Japan",
        "answer_region": "East Asia",
        "answer_continent": "Asia",
        "difficulty": 2
    }
    """.data(using: .utf8)!

    let clue = try JSONDecoder().decode(Clue.self, from: json)
    #expect(clue.id == "clue_001")
    #expect(clue.type == .cultural)
    #expect(clue.answerLongitude == 139.7)
    #expect(clue.answerCountry == "Japan")
    #expect(clue.difficulty == 2)
}
