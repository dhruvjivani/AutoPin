import Foundation
import CoreMotion
import Combine

/// Monitors device motion to detect when user has stopped moving
///
/// MotionService analyzes accelerometer data to determine if the watch is stationary.
/// This enables the app to suggest saving a location when the user stops moving.
///
/// ## How It Works
/// - Samples accelerometer data at 0.1 second intervals
/// - Calculates acceleration magnitude from X, Y, Z axes
/// - Maintains a sliding window of 10 recent samples
/// - Detects stopped movement when average acceleration falls below threshold
///
/// ## Usage
/// ```swift
/// let motionService = MotionService()
/// motionService.startMonitoring()
/// // When hasStoppedMoving becomes true, prompt user to save location
/// motionService.stopMonitoring()
/// ```
///
/// - Note: Accelerometer must be available on device
class MotionService: NSObject, ObservableObject {
    /// Whether device is currently moving
    @Published var isMoving: Bool = false
    
    /// Whether device has just stopped moving (single event)
    @Published var hasStoppedMoving: Bool = false
    
    private var motionManager: CMMotionManager?
    private var accelerometerData: [Double] = []
    private let accelerometerThreshold: Double = 0.5
    private let samplesRequired: Int = 10
    private let logger = Logger()
    
    override init() {
        super.init()
        setupMotionManager()
    }
    
    /// Initialize motion manager with proper configuration
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        guard let motionManager = motionManager else { return }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
        }
    }
    
    /// Start monitoring device movement
    ///
    /// Begins continuous accelerometer updates at 0.1 second intervals.
    /// Call stopMonitoring() when monitoring is no longer needed to save battery.
    func startMonitoring() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else {
            logger.log("Accelerometer not available")
            return
        }
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
            guard let self = self, let data = data else {
                if let error = error {
                    self?.logger.logError(error)
                }
                return
            }
            
            self.processAccelerometerData(data)
        }
        
        logger.log("Motion monitoring started")
    }
    
    /// Stop monitoring device movement
    ///
    /// Halts accelerometer updates and clears data.
    /// Call this when leaving views that don't need motion detection.
    func stopMonitoring() {
        motionManager?.stopAccelerometerUpdates()
        accelerometerData.removeAll()
        logger.log("Motion monitoring stopped")
    }
    
    /// Process accelerometer data to detect movement changes
    /// - Parameter data: Raw accelerometer reading
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        // Calculate magnitude of acceleration vector
        let acceleration = sqrt(
            data.acceleration.x * data.acceleration.x +
            data.acceleration.y * data.acceleration.y +
            data.acceleration.z * data.acceleration.z
        )
        
        accelerometerData.append(acceleration)
        if accelerometerData.count > samplesRequired {
            accelerometerData.removeFirst()
        }
        
        // Check if device has stopped moving
        if accelerometerData.count == samplesRequired {
            let average = accelerometerData.reduce(0, +) / Double(samplesRequired)
            let wasMoving = isMoving
            isMoving = average > accelerometerThreshold
            
            if wasMoving && !isMoving {
                DispatchQueue.main.async {
                    self.hasStoppedMoving = true
                    self.logger.log("Movement stopped detected")
                }
            }
        }
    }
    
    /// Reset the stopped moving flag
    ///
    /// Call this after handling the stopped movement event.
    func resetStoppedFlag() {
        hasStoppedMoving = false
    }
}
