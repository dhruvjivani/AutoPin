import Foundation
import CoreMotion
import Combine

/// Monitors device motion to detect when user has stopped moving
class MotionService: NSObject, ObservableObject {
    @Published var isMoving: Bool = false
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
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        guard let motionManager = motionManager else { return }
        
        // Check if accelerometer is available
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
        }
    }
    
    /// Start monitoring movement
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
    
    /// Stop monitoring movement
    func stopMonitoring() {
        motionManager?.stopAccelerometerUpdates()
        accelerometerData.removeAll()
        logger.log("Motion monitoring stopped")
    }
    
    /// Process accelerometer data to detect movement
    private func processAccelerometerData(_ data: CMAccelerometerData) {
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
    func resetStoppedFlag() {
        hasStoppedMoving = false
    }
}
