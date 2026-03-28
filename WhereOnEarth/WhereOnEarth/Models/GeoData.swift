import Foundation

struct GeoPolygon: Sendable {
    let points: [(Double, Double)]  // (lng, lat) pairs
}

struct GeoLine: Sendable {
    let points: [(Double, Double)]  // (lng, lat) pairs
}

final class GeoData: Sendable {
    let landPolygons: [GeoPolygon]
    let coastlines: [GeoLine]

    init() {
        landPolygons = Self.loadPolygons(resource: "ne_110m_land")
        coastlines = Self.loadLines(resource: "ne_110m_coastline")
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
