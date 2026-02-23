import SwiftUI
import SwiftData
import CoreLocation
import WidgetKit

/// View for saving a new pin location - Responsive design with scrolling
struct NewPinView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var locationService = LocationService()
    
    @State private var title: String = ""
    @State private var category: String = "Car"
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCategoryPicker = false
    
    private let logger = Logger()
    private let categories = ["Car", "Bag", "Laptop", "Jacket", "Other"]
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && locationService.currentLocation != nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Premium dark gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        // Header
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Save Location")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        
                        // Title Input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Item Name")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., My Car", text: $title)
                                .font(.system(size: 13))
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .onChange(of: title) { _, _ in
                                    NotificationService.shared.playClickHaptic()
                                }
                        }
                        .padding(.horizontal, 12)
                        
                        // Category Picker - Compact Menu Style
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button(action: {
                                showCategoryPicker = true
                                NotificationService.shared.playClickHaptic()
                            }) {
                                HStack {
                                    Image(systemName: categoryIcon(category))
                                        .font(.system(size: 12))
                                    Text(category)
                                        .font(.system(size: 12, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                            }
                            .confirmationDialog("Select Category", isPresented: $showCategoryPicker) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: {
                                        category = cat
                                        NotificationService.shared.playClickHaptic()
                                    }) {
                                        Label(cat, systemImage: categoryIcon(cat))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        // Location Status - Compact
                        HStack(spacing: 8) {
                            if let location = locationService.currentLocation {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Ready")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.6))
                                        .lineLimit(1)
                                        .monospaced()
                                }
                            } else if isLoading {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    ProgressView()
                                        .scaleEffect(0.6)
                                }
                                Text("Getting location...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "location.slash")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                Text("Location needed")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Button(action: {
                                    locationService.requestCurrentLocation()
                                    NotificationService.shared.playClickHaptic()
                                }) {
                                    Text("Retry")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 12)
                        
                        Spacer(minLength: 4)
                        
                        // Save Button
                        Button(action: {
                            savePin()
                            NotificationService.shared.playClickHaptic()
                        }) {
                            HStack(spacing: 6) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                Text("Save Pin")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                isValid && !isLoading ? Color.blue : Color.gray,
                                                isValid && !isLoading ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: isValid && !isLoading ? .blue.opacity(0.4) : .clear, radius: 6)
                        }
                        .disabled(!isValid || isLoading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationTitle("Save")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationService.requestCurrentLocation()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func savePin() {
        guard let location = locationService.currentLocation else {
            errorMessage = "Unable to get current location. Please try again."
            showError = true
            NotificationService.shared.playErrorHaptic()
            return
        }
        
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter an item name."
            showError = true
            NotificationService.shared.playErrorHaptic()
            return
        }
        
        isLoading = true
        
        let newPin = SavedItemPin(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: locationService.currentAltitude,
            timestamp: Date()
        )
        
        do {
            modelContext.insert(newPin)
            try modelContext.save()
            
            // Update widget data
            let sharedDefaults = UserDefaults(suiteName: "group.com.autopin.shared")
            let currentCount = sharedDefaults?.integer(forKey: "savedItemsCount") ?? 0
            sharedDefaults?.set(currentCount + 1, forKey: "savedItemsCount")
            sharedDefaults?.set(newPin.title, forKey: "lastItemTitle")
            
            // Reload widget
            WidgetCenter.shared.reloadAllTimelines()
            
            logger.log("Pin saved: \(newPin.title)")
            NotificationService.shared.playSuccessHaptic()
            NotificationService.shared.sendSaveSuccessNotification(itemTitle: newPin.title)
            
            isLoading = false
            dismiss()
        } catch {
            logger.logError(error)
            errorMessage = "Failed to save location. Please try again."
            showError = true
            isLoading = false
            NotificationService.shared.playErrorHaptic()
        }
    }
    
    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "car": return "car.fill"
        case "bag": return "bag.fill"
        case "laptop": return "laptopcomputer"
        case "jacket": return "tshirt.fill"
        default: return "mappin.circle.fill"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedItemPin.self, configurations: config)
    return NavigationStack {
        NewPinView()
            .modelContainer(container)
    }
}

