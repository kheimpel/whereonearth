import Testing
@testable import WhereOnEarth

@Test func scoreRightCountry() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: 140.0, for: clue)
    #expect(result.points == 3)
    #expect(result.accuracy == .country)
}

@Test func scoreRightRegion() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: 120.0, for: clue)
    #expect(result.points == 2)
    #expect(result.accuracy == .region)
}

@Test func scoreRightContinent() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: 80.0, for: clue)
    #expect(result.points == 1)
    #expect(result.accuracy == .continent)
}

@Test func scoreWrongContinent() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: -80.0, for: clue)
    #expect(result.points == 0)
    #expect(result.accuracy == .wrong)
}

@Test func scoringWrapsAroundAntimeridian() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 170.0, answerCountry: "Fiji",
        answerRegion: "Oceania", answerContinent: "Oceania",
        difficulty: 1
    )
    let result = GameEngine.score(guessLongitude: -175.0, for: clue)
    #expect(result.points == 2)
}
