import Foundation

/// Simple logging utility for debugging
struct Logger {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    func log(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ℹ️ \(message)")
    }
    
    func logError(_ error: Error) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ❌ Error: \(error.localizedDescription)")
    }
    
    func logWarning(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        print("[AutoPin - \(timestamp)] ⚠️ \(message)")
    }
}
