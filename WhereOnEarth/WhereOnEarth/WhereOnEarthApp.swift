import SwiftUI

@main
struct WhereOnEarthApp: App {
    private let geoData = GeoData()
    private let wristMotion = WristMotion()

    var body: some Scene {
        WindowGroup {
            MenuView(geoData: geoData, wristMotion: wristMotion)
                .background(TimeHider())
        }
    }
}
