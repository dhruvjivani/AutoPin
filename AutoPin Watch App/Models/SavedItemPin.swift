import Foundation
import SwiftData

/// Core data model for storing saved item locations
///
/// SavedItemPin represents a single saved location for a personal item.
/// Uses SwiftData for local persistence on watchOS.
///
/// ## Features
/// - Unique identifier for each pin
/// - Location coordinates (latitude, longitude, altitude)
/// - Item title and category for organization
/// - Timestamp tracking when location was saved
/// - Built-in distance calculation using Haversine formula
///
/// ## Example
/// ```swift
/// let pin = SavedItemPin(
///     title: "My Car",
///     category: "Car",
///     latitude: 37.7749,
///     longitude: -122.4194,
///     altitude: 10.5
/// )
///
/// let distance = pin.distance(from: (37.7750, -122.4195))
/// ```
@Model
final class SavedItemPin {
    /// Unique identifier for this pin
    @Attribute(.unique) var id: UUID
    
    /// Name of the saved item (e.g., "My Car")
    var title: String
    
    /// Category of the item (e.g., "Car", "Bag", "Laptop")
    var category: String
    
    /// Latitude coordinate of saved location
    var latitude: Double
    
    /// Longitude coordinate of saved location
    var longitude: Double
    
    /// Altitude in meters above sea level
    var altitude: Double
    
    /// Timestamp when location was saved
    var timestamp: Date
    
    /// Initialize a new SavedItemPin with location data
    /// - Parameters:
    ///   - title: Name of the saved item
    ///   - category: Item category for organization
    ///   - latitude: Geographic latitude
    ///   - longitude: Geographic longitude
    ///   - altitude: Altitude above sea level (default: 0.0)
    ///   - timestamp: When the location was saved (default: now)
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
    
    /// Calculate distance from current location using Haversine formula
    ///
    /// The Haversine formula calculates the great-circle distance between two points
    /// on a sphere given their longitudes and latitudes.
    ///
    /// - Parameter current: Tuple containing current latitude and longitude
    /// - Returns: Distance in meters from current location to this pin
    ///
    /// - Note: Accuracy is approximately ±0.5m for distances under 1km
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
    
    /// Convert degrees to radians
    /// - Parameter degrees: Angle in degrees
    /// - Returns: Angle in radians
    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
}
