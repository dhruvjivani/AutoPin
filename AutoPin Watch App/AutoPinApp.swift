//
//  AutoPinApp.swift
//  AutoPin Watch App
//
//  Created by Dhruv Rasikbhai Jivani on 2/23/26.
//

import SwiftUI
import SwiftData
import Intents

@main
struct AutoPin_Watch_AppApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: SavedItemPin.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        
        // Request notification permissions on app launch
        NotificationService.shared.requestNotificationPermissions()
        
        // Donate Siri Shortcuts
        donateSiriShortcuts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContainer.mainContext)
        }
        .modelContainer(modelContainer)
        .environment(\.locale, Locale(identifier: "en_US"))
    }
    
    private func donateSiriShortcuts() {
        // Donate "Save Location" shortcut
        let saveActivity = NSUserActivity(activityType: "com.autopin.save")
        saveActivity.title = "Save My Location"
        saveActivity.suggestedInvocationPhrase = "Save my location"
        saveActivity.isEligibleForPrediction = true
        saveActivity.persistentIdentifier = "saveLocation"
        saveActivity.becomeCurrent()
        
        // Donate "Find Items" shortcut
        let findActivity = NSUserActivity(activityType: "com.autopin.find")
        findActivity.title = "Find My Items"
        findActivity.suggestedInvocationPhrase = "Find my items"
        findActivity.isEligibleForPrediction = true
        findActivity.persistentIdentifier = "findItems"
        findActivity.becomeCurrent()
    }
}

