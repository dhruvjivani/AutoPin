import Foundation
import CoreLocation
import SwiftData
import Combine

/// Manages location acquisition for saving item locations
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentAltitude: Double = 0.0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocating: Bool = false
    @Published var nearbyItem: SavedItemPin?
    @Published var isApproaching: Bool = false
    
    private var locationManager: CLLocationManager?
    private let logger = Logger()
    private var modelContext: ModelContext?
    private var hasTriggeredProximity: Set<UUID> = []
    private var lastProximityCheck: Date = Date()
    private let proximityCheckInterval: TimeInterval = 5.0 // Check every 5 seconds
    private let proximityThreshold: Double = 10.0 // meters - max detection range (start detecting from 10m)
    private let minimumTriggerDistance: Double = 2.0 // stop triggering when within 2m (near)
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 20 // Update every 20 meters
        
        // Check and request permission
        let status = locationManager?.authorizationStatus ?? .notDetermined
        if status == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
    
    /// Set the model context for proximity checking
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Request a single location update
    func requestCurrentLocation() {
        isLocating = true
        locationManager?.requestLocation()
    }
    
    /// Start continuous location updates
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    /// Stop continuous location updates
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    
    /// Reset proximity triggers (e.g., when user dismisses notification)
    func resetProximityTriggers() {
        hasTriggeredProximity.removeAll()
        nearbyItem = nil
        isApproaching = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.currentAltitude = location.altitude
            self.isLocating = false
            
            // Check proximity to saved items (with debounce)
            self.checkProximity(to: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocating = false
            // Only log significant errors
            if let clError = error as? CLError, clError.code != .locationUnknown {
                self.logger.logError(error)
            }
        }
    }
    
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

