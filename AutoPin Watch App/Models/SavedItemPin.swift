import Foundation
import SwiftData

/// Core data model for storing saved item locations
/// Uses SwiftData for local persistence on watchOS
@Model
final class SavedItemPin {
    @Attribute(.unique) var id: UUID
    var title: String
    var category: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    
    init(
        title: String,
        category: String,
        latitude: Double,
        longitude: Double,
        altitude: Double = 0.0,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
    
    /// Calculate distance from current location
    func distance(from current: (lat: Double, lon: Double)) -> Double {
        let lat1Rad = degreesToRadians(current.lat)
        let lat2Rad = degreesToRadians(latitude)
        let lon1Rad = degreesToRadians(current.lon)
        let lon2Rad = degreesToRadians(longitude)
        
        let dLat = lat2Rad - lat1Rad
        let dLon = lon2Rad - lon1Rad
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return 6371000 * c // Earth radius in meters
    }
    
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
}
