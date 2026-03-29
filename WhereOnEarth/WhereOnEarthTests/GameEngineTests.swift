import Testing
@testable import WhereOnEarth

@Test func perfectScore() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerLatitude: 35.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1,
        scrollBearing: 90, scrollCenterLat: 35, scrollCenterLng: 100
    )
    let result = GameEngine.score(guessLat: 35.7, guessLng: 139.7, for: clue)
    #expect(result.points == 5000)
    #expect(result.tier == "SPOT ON")
}

@Test func closeGuess() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerLatitude: 35.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1,
        scrollBearing: 90, scrollCenterLat: 35, scrollCenterLng: 100
    )
    let result = GameEngine.score(guessLat: 35.7, guessLng: 135.0, for: clue)
    #expect(result.points > 3500)
    #expect(result.points < 4500)
    #expect(result.tier == "EXCELLENT")
}

@Test func continentLevel() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerLatitude: 35.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1,
        scrollBearing: 90, scrollCenterLat: 35, scrollCenterLng: 100
    )
    let result = GameEngine.score(guessLat: 35.7, guessLng: 120.0, for: clue)
    #expect(result.points > 1500)
    #expect(result.points < 3000)
    #expect(result.tier == "CLOSE")
}

@Test func veryFarOff() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 139.7, answerLatitude: 35.7, answerCountry: "Japan",
        answerRegion: "East Asia", answerContinent: "Asia",
        difficulty: 1,
        scrollBearing: 90, scrollCenterLat: 35, scrollCenterLng: 100
    )
    let result = GameEngine.score(guessLat: -35.0, guessLng: -40.0, for: clue)
    #expect(result.points < 100)
    #expect(result.tier == "WAY OFF")
}

@Test func scoringWrapsAroundAntimeridian() {
    let clue = Clue(
        id: "test", type: .cultural, text: "Test",
        answerLongitude: 170.0, answerLatitude: -17.7, answerCountry: "Fiji",
        answerRegion: "Oceania", answerContinent: "Oceania",
        difficulty: 1,
        scrollBearing: 90, scrollCenterLat: 35, scrollCenterLng: 100
    )
    let result = GameEngine.score(guessLat: -17.7, guessLng: -175.0, for: clue)
    // 15° of longitude at lat -17.7 ≈ 1589 km → ~2260 points
    #expect(result.points > 2000)
    #expect(result.points < 2500)
}
