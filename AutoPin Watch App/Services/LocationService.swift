import Foundation
import CoreLocation
import SwiftData
import Combine

/// Manages location acquisition and proximity detection for AutoPin
///
/// LocationService handles:
/// - Real-time GPS location tracking
/// - Location authorization management  
/// - Proximity alerts when user approaches saved items
/// - Distance calculations using Haversine formula
///
/// ## Usage
/// ```swift
/// let locationService = LocationService()
/// locationService.requestCurrentLocation()
/// let distance = pin.distance(from: (locationService.currentLocation!.latitude, locationService.currentLocation!.longitude))
/// ```
///
/// - Important: Set model context after initialization for proximity detection to work
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Currently detected GPS coordinate
    @Published var currentLocation: CLLocationCoordinate2D?
    /// Current altitude in meters
    @Published var currentAltitude: Double = 0.0
    /// Current location authorization status
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// Whether location service is currently acquiring location
    @Published var isLocating: Bool = false
    /// The nearest saved item (when proximity alert triggers)
    @Published var nearbyItem: SavedItemPin?
    /// Whether user is approaching a saved item
    @Published var isApproaching: Bool = false
    
    private var locationManager: CLLocationManager?
    private let logger = Logger()
    private var modelContext: ModelContext?
    private var hasTriggeredProximity: Set<UUID> = []
    private var lastProximityCheck: Date = Date()
    private let proximityCheckInterval: TimeInterval = 5.0
    private let proximityThreshold: Double = 10.0
    private let minimumTriggerDistance: Double = 2.0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    /// Initialize location manager with proper configuration
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 20 // Update every 20 meters
        
        let status = locationManager?.authorizationStatus ?? .notDetermined
        if status == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
    
    /// Set the SwiftData model context for proximity checking
    /// - Parameter context: ModelContext from SwiftUI environment
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Request a single location update immediately
    func requestCurrentLocation() {
        isLocating = true
        locationManager?.requestLocation()
    }
    
    /// Start continuous location updates
    /// - Note: Updates are filtered by 20-meter distance filter for battery efficiency
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    /// Stop continuous location updates
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    
    /// Reset proximity triggers (called when user dismisses notification)
    func resetProximityTriggers() {
        hasTriggeredProximity.removeAll()
        nearbyItem = nil
        isApproaching = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// Called when location manager successfully retrieves location
    /// - Parameters:
    ///   - manager: The location manager object
    ///   - locations: Array of CLLocation objects (last is most recent)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.currentAltitude = location.altitude
            self.isLocating = false
            
            self.checkProximity(to: location)
        }
    }
    
    /// Called when location manager fails to retrieve location
    /// - Parameters:
    ///   - manager: The location manager object
    ///   - error: Error describing the failure
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocating = false
            if let clError = error as? CLError, clError.code != .locationUnknown {
                self.logger.logError(error)
            }
        }
    }
    
    /// Called when location authorization status changes
    /// - Parameters:
    ///   - manager: The location manager object
    ///   - status: New authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startUpdatingLocation()
            }
        }
    }
    
    // MARK: - Proximity Detection
    
    private func checkProximity(to location: CLLocation) {
        // Debounce: only check every few seconds
        let now = Date()
        guard now.timeIntervalSince(lastProximityCheck) >= proximityCheckInterval else { return }
        lastProximityCheck = now
        
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<SavedItemPin>()
            let pins = try context.fetch(descriptor)
            
            var foundNearby = false
            
            for pin in pins {
                // Skip if already triggered for this item
                if hasTriggeredProximity.contains(pin.id) {
                    continue
                }
                
                let pinLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
                let distance = location.distance(from: pinLocation)
                
                // Only trigger if distance is between minimum threshold and proximity threshold
                if distance >= minimumTriggerDistance && distance <= proximityThreshold {
                    // Trigger haptic feedback and notification
                    DispatchQueue.main.async {
                        self.nearbyItem = pin
                        self.isApproaching = true
                        self.hasTriggeredProximity.insert(pin.id)
                        
                        // Play stronger proximity haptic
                        NotificationService.shared.playProximityAlertHaptic()
                        
                        // Send notification
                        NotificationService.shared.sendMovementDetectedNotification(
                            itemTitle: pin.title,
                            distance: distance
                        )
                        
                        self.logger.log("Proximity alert: \(pin.title) at \(String(format: "%.0f", distance))m")
                    }
                    foundNearby = true
                    break // Only trigger for one item at a time
                }
            }
            
            if !foundNearby {
                // Update approaching status for UI
                let anyClose = pins.contains { pin in
                    if self.hasTriggeredProximity.contains(pin.id) { return false }
                    let pinLocation = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
                    let dist = location.distance(from: pinLocation)
                    return dist >= self.minimumTriggerDistance && dist <= self.proximityThreshold * 1.5
                }
                DispatchQueue.main.async {
                    self.isApproaching = anyClose
                }
            }
        } catch {
            logger.logError(error)
        }
    }
}

