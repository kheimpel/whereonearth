import SwiftUI

@main
struct WhereOnEarthApp: App {
    private let geoData = GeoData()

    var body: some Scene {
        WindowGroup {
            MenuView(geoData: geoData)
        }
    }
}
