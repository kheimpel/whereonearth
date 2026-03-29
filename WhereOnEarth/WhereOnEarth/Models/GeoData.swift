import Foundation

struct GeoPolygon: Sendable {
    let points: [(Double, Double)]  // (lng, lat) pairs
}

struct GeoLine: Sendable {
    let points: [(Double, Double)]  // (lng, lat) pairs
}

struct ContinentRegion: Sendable {
    let name: String
    let polygons: [[(Double, Double)]]  // array of rings, each ring is [(lng, lat)]
}

final class GeoData: Sendable {
    let landPolygons: [GeoPolygon]
    let coastlines: [GeoLine]
    let continents: [ContinentRegion]

    init() {
        landPolygons = Self.loadPolygons(resource: "ne_50m_land")
        coastlines = Self.loadLines(resource: "ne_50m_coastline")
        continents = Self.loadContinents()
    }

    /// Find which continent a lat/lng point is on. Returns nil if over ocean.
    func continentAt(lat: Double, lng: Double) -> String? {
        for continent in continents {
            if continent.name == "Antarctica" || continent.name == "Seven seas (open ocean)" {
                continue
            }
            for ring in continent.polygons {
                if Self.pointInPolygon(lat: lat, lng: lng, polygon: ring) {
                    return continent.name
                }
            }
        }
        return nil
    }

    /// Ray-casting point-in-polygon test
    private static func pointInPolygon(lat: Double, lng: Double, polygon: [(Double, Double)]) -> Bool {
        var inside = false
        let n = polygon.count
        var j = n - 1
        for i in 0..<n {
            let (xi, yi) = polygon[i]  // (lng, lat)
            let (xj, yj) = polygon[j]
            if ((yi > lat) != (yj > lat)) &&
                (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
                inside.toggle()
            }
            j = i
        }
        return inside
    }

    private static func loadContinents() -> [ContinentRegion] {
        guard let url = Bundle.main.url(forResource: "continents", withExtension: "json"),
              let data = (try? Data(contentsOf: url)),
              let arr = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] else {
            return []
        }
        return arr.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let polygons = dict["polygons"] as? [[[Any]]] else { return nil }
            let rings: [[(Double, Double)]] = polygons.compactMap { ring in
                ring.compactMap { coord in
                    guard let pair = coord as? [Double], pair.count >= 2 else { return nil }
                    return (pair[0], pair[1])
                }
            }
            return ContinentRegion(name: name, polygons: rings)
        }
    }

    private static func loadPolygons(resource: String) -> [GeoPolygon] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "geojson"),
              let data = (try? Data(contentsOf: url)),
              let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let features = json["features"] as? [[String: Any]] else {
            return []
        }

        var result: [GeoPolygon] = []
        for feature in features {
            guard let geometry = feature["geometry"] as? [String: Any],
                  let type_ = geometry["type"] as? String else { continue }

            if type_ == "Polygon" {
                guard let rings = geometry["coordinates"] as? [[[Any]]],
                      let ring = rings.first else { continue }
                let points = ring.compactMap { coord -> (Double, Double)? in
                    guard let arr = coord as? [Double], arr.count >= 2 else { return nil }
                    return (arr[0], arr[1])
                }
                if !points.isEmpty { result.append(GeoPolygon(points: points)) }

            } else if type_ == "MultiPolygon" {
                guard let polygons = geometry["coordinates"] as? [[[[Any]]]] else { continue }
                for polygon in polygons {
                    guard let ring = polygon.first else { continue }
                    let points = ring.compactMap { coord -> (Double, Double)? in
                        guard let arr = coord as? [Double], arr.count >= 2 else { return nil }
                        return (arr[0], arr[1])
                    }
                    if !points.isEmpty { result.append(GeoPolygon(points: points)) }
                }
            }
        }
        return result
    }

    private static func loadLines(resource: String) -> [GeoLine] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "geojson"),
              let data = (try? Data(contentsOf: url)),
              let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let features = json["features"] as? [[String: Any]] else {
            return []
        }

        var result: [GeoLine] = []
        for feature in features {
            guard let geometry = feature["geometry"] as? [String: Any],
                  let type_ = geometry["type"] as? String else { continue }

            if type_ == "LineString" {
                guard let coords = geometry["coordinates"] as? [[Any]] else { continue }
                let points = coords.compactMap { coord -> (Double, Double)? in
                    guard let arr = coord as? [Double], arr.count >= 2 else { return nil }
                    return (arr[0], arr[1])
                }
                if !points.isEmpty { result.append(GeoLine(points: points)) }

            } else if type_ == "MultiLineString" {
                guard let lines = geometry["coordinates"] as? [[[Any]]] else { continue }
                for line in lines {
                    let points = line.compactMap { coord -> (Double, Double)? in
                        guard let arr = coord as? [Double], arr.count >= 2 else { return nil }
                        return (arr[0], arr[1])
                    }
                    if !points.isEmpty { result.append(GeoLine(points: points)) }
                }
            }
        }
        return result
    }
}
