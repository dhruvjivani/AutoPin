import Foundation
import UserNotifications
import WatchKit

/// Manages local notifications and haptic feedback for AutoPin
///
/// NotificationService handles:
/// - Local notification delivery with interactive actions
/// - Haptic feedback patterns for different scenarios
/// - Notification permission management
/// - Widget updates via WidgetKit
///
/// ## Notification Categories
/// - `ITEM_NEARBY`: Triggered when user approaches a saved location
/// - `MOVEMENT_DETECTED`: Triggered when motion detection stops
///
/// ## Haptic Feedback Patterns
/// - Click: Light feedback for button taps
/// - Success: Positive feedback for completed actions
/// - Failure: Negative feedback for errors
/// - Notification: Alert feedback
/// - Proximity: Urgent triple-tap for important alerts
///
/// ## Usage
/// ```swift
/// NotificationService.shared.requestNotificationPermissions()
/// NotificationService.shared.sendMovementDetectedNotification(itemTitle: "My Car", distance: 5.0)
/// NotificationService.shared.playSuccessHaptic()
/// ```
class NotificationService {
    static let shared = NotificationService()
    private let logger = Logger()
    private var isAuthorized = false
    
    private init() {}
    
    /// Request notification permissions from user
    ///
    /// Requests permission for alerts, sounds, and badges.
    /// Sets up notification categories with interactive actions.
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            self?.isAuthorized = granted
            if granted {
                DispatchQueue.main.async {
                    WKApplication.shared().registerForRemoteNotifications()
                }
                self?.setupNotificationCategories()
            }
            if let error = error {
                self?.logger.logError(error)
            }
        }
    }
    
    /// Setup notification categories with interactive actions
    /// Creates notification categories for different alert types
    private func setupNotificationCategories() {
        // Navigate action
        let navigateAction = UNNotificationAction(
            identifier: "NAVIGATE_ACTION",
            title: "Navigate",
            options: [.foreground]
        )
        
        // Dismiss action
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        
        // Item nearby category
        let nearbyCategory = UNNotificationCategory(
            identifier: "ITEM_NEARBY",
            actions: [navigateAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Save location category
        let saveAction = UNNotificationAction(
            identifier: "SAVE_ACTION",
            title: "Save",
            options: [.foreground]
        )
        let cancelAction = UNNotificationAction(
            identifier: "CANCEL_ACTION",
            title: "Cancel",
            options: [.destructive]
        )
        
        let movementCategory = UNNotificationCategory(
            identifier: "MOVEMENT_DETECTED",
            actions: [saveAction, cancelAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            nearbyCategory,
            movementCategory
        ])
    }
    
    // MARK: - Haptic Feedback
    
    /// Play light click haptic feedback
    /// Used for button taps and UI interactions
    func playClickHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    /// Play success haptic pattern
    /// Used to confirm successful actions
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
    
    /// Play error/failure haptic pattern
    /// Used to indicate errors or failed operations
    func playErrorHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    /// Play notification haptic for alerts
    func playNotificationHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    /// Play direction haptic for navigation
    func playDirectionHaptic() {
        WKInterfaceDevice.current().play(.directionUp)
    }
    
    /// Play movement detected haptic with custom pattern
    /// Double-tap pattern for movement detection alerts
    func playMovementDetectedHaptic() {
        WKInterfaceDevice.current().play(.notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            WKInterfaceDevice.current().play(.notification)
        }
        
        logger.log("Movement detected haptic played")
    }
    
    /// Play proximity alert haptic - stronger triple-tap pattern
    /// Used when user is approaching a saved item
    func playProximityAlertHaptic() {
        WKInterfaceDevice.current().play(.notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            WKInterfaceDevice.current().play(.notification)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            WKInterfaceDevice.current().play(.notification)
        }
        
        logger.log("Proximity alert haptic played")
    }
    
    // MARK: - Notifications
    
    /// Send notification when approaching a saved item
    /// - Parameters:
    ///   - itemTitle: Title of the nearby item
    ///   - distance: Current distance in meters
    func sendMovementDetectedNotification(itemTitle: String, distance: Double) {
        guard isAuthorized else {
            logger.log("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Item Nearby!"
        content.body = "\(itemTitle) is \(Int(distance))m away"
        content.sound = .default
        content.categoryIdentifier = "ITEM_NEARBY"
        content.interruptionLevel = .active
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "nearby_\(itemTitle)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.logError(error)
            } else {
                self?.logger.log("Item nearby notification sent for \(itemTitle)")
            }
        }
    }
    
    /// Send notification when movement is detected
    func sendMovementDetectedNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Movement Stopped"
        content.body = "Save this item's location?"
        content.sound = .default
        content.categoryIdentifier = "MOVEMENT_DETECTED"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.logError(error)
            }
        }
    }
    
    /// Send save successful notification
    /// - Parameter itemTitle: Title of the saved item
    func sendSaveSuccessNotification(itemTitle: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "✅ Saved!"
        content.body = "\(itemTitle) location saved"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "save_\(itemTitle)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.logError(error)
            }
        }
    }
    
    /// Clear all pending and delivered notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        logger.log("All notifications cleared")
    }
}

