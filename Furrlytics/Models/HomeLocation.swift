import Foundation
import SwiftData

@Model
class HomeLocation {
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double

    init(
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = GeofenceDefaults.radiusMeters
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
    }
}

enum GeofenceDefaults {
    static let radiusMeters: Double = 200
    static let debounceSeconds: TimeInterval = 300
}
