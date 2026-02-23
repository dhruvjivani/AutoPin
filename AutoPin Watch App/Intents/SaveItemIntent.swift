import SwiftUI
import SwiftData
import AppIntents

/// App Intent for saving item location via Siri
struct SaveItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Item Location"
    static var description = IntentDescription("Save your current location as a pin")
    
    @Parameter(title: "Item Name")
    var itemName: String
    
    @Parameter(title: "Category", default: "Other")
    var category: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Save \(\.$itemName) location")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // The actual saving will be handled by the app
        return .result(dialog: "Saving location for \(itemName)")
    }
}

/// App Intent for finding saved items via Siri
struct FindItemsIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Saved Items"
    static var description = IntentDescription("Find your saved item locations")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Find my saved items")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Opening your saved items")
    }
}

/// App Shortcuts provider
struct AutoPinShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SaveItemIntent(),
            phrases: [
                "Save my location in \(.applicationName)",
                "Save this location in \(.applicationName)",
                "Mark this spot in \(.applicationName)"
            ],
            shortTitle: "Save Location",
            systemImageName: "mappin.circle.fill"
        )
        
        AppShortcut(
            intent: FindItemsIntent(),
            phrases: [
                "Find my items in \(.applicationName)",
                "Show my saved items in \(.applicationName)",
                "Where are my saved items in \(.applicationName)"
            ],
            shortTitle: "Find Items",
            systemImageName: "list.bullet.circle.fill"
        )
    }
}

