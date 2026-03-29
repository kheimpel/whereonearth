import Foundation

struct Clue: Codable, Identifiable, Sendable {
    let id: String
    let type: ClueType
    let text: String
    let answerLongitude: Double
    let answerLatitude: Double
    let answerCountry: String
    let answerRegion: String
    let answerContinent: String
    let difficulty: Int
    let scrollBearing: Double
    let scrollCenterLat: Double
    let scrollCenterLng: Double

    enum ClueType: String, Codable, Sendable {
        case cultural
        case landmark
        case food
        case language
        case flag
        case street
    }

    enum CodingKeys: String, CodingKey {
        case id, type, text, difficulty
        case answerLongitude = "answer_longitude"
        case answerLatitude = "answer_latitude"
        case answerCountry = "answer_country"
        case answerRegion = "answer_region"
        case answerContinent = "answer_continent"
        case scrollBearing = "scroll_bearing"
        case scrollCenterLat = "scroll_center_lat"
        case scrollCenterLng = "scroll_center_lng"
    }
}
