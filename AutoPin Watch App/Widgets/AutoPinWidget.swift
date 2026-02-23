import WidgetKit
import SwiftUI
import SwiftData

/// Widget provider for AutoPin complication
struct AutoPinWidgetProvider: TimelineProvider {
    
    typealias Entry = AutoPinWidgetEntry
    
    func placeholder(in context: Context) -> AutoPinWidgetEntry {
        AutoPinWidgetEntry(date: Date(), itemCount: 0, lastItemTitle: "No items")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AutoPinWidgetEntry) -> ()) {
        let entry = AutoPinWidgetEntry(date: Date(), itemCount: 0, lastItemTitle: "No items")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AutoPinWidgetEntry>) -> ()) {
        var entries: [AutoPinWidgetEntry] = []
        
        // Get item count from shared UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.autopin.shared")
        let itemCount = sharedDefaults?.integer(forKey: "savedItemsCount") ?? 0
        let lastTitle = sharedDefaults?.string(forKey: "lastItemTitle") ?? "No items"
        
        // Generate entries for next 24 hours
        let currentDate = Date()
        for hourOffset in 0 ..< 24 {
            if let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                let entry = AutoPinWidgetEntry(
                    date: entryDate,
                    itemCount: itemCount,
                    lastItemTitle: lastTitle
                )
                entries.append(entry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AutoPinWidgetEntry: TimelineEntry {
    let date: Date
    let itemCount: Int
    let lastItemTitle: String
}

/// Main widget view
struct AutoPinWidgetEntryView: View {
    var entry: AutoPinWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("AutoPin")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Items Saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(entry.itemCount)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

/// AutoPin Widget Bundle
struct AutoPinWidgets: WidgetBundle {
    var body: some Widget {
        AutoPinWidget()
    }
}

/// AutoPin Widget
struct AutoPinWidget: Widget {
    let kind: String = "com.autopin.widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: AutoPinWidgetProvider()
        ) { entry in
            AutoPinWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AutoPin Items")
        .description("See how many items you've saved with AutoPin")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular])
    }
}

#Preview(as: .accessoryRectangular) {
    AutoPinWidget()
} timeline: {
    AutoPinWidgetEntry(date: .now, itemCount: 5, lastItemTitle: "My Car")
}
