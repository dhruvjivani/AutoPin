import Foundation

/// Simple logging utility for debugging and development
///
/// Logger provides a centralized way to log messages with timestamps and log levels.
/// Useful for debugging and understanding app behavior.
///
/// ## Log Levels
/// - `log()`: Informational messages (ℹ️)
/// - `logWarning()`: Warning messages (⚠️)
/// - `logError()`: Error messages (❌)
///
/// ## Usage
/// ```swift
/// let logger = Logger()
/// logger.log("User saved a new location")
/// logger.logWarning("Location accuracy is low")
/// logger.logError(error)
/// ```
struct Logger {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    /// Log informational message
    /// - Parameter message: Message to log
    func log(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ℹ️ \(message)")
    }
    
    /// Log error with error description
    /// - Parameter error: Error to log
    func logError(_ error: Error) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ❌ Error: \(error.localizedDescription)")
    }
    
    /// Log warning message
    /// - Parameter message: Warning message to log
    func logWarning(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ⚠️ \(message)")
    }
}

