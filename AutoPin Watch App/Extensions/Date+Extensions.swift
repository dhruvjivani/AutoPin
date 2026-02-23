import Foundation

extension Date {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    func formattedTime() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: self)
    }
    
    var shortDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var relativeTimeString: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            let components = calendar.dateComponents([.hour, .minute], from: self, to: now)
            if let hours = components.hour, hours > 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            }
            if let minutes = components.minute, minutes > 0 {
                return "\(minutes) min ago"
            }
            return "just now"
        } else if calendar.isDateInYesterday(self) {
            return "yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            return dateFormatter.string(from: self)
        }
    }
    
    func daysBetween(_ date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day
    }
    
}
