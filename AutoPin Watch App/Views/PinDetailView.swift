import SwiftUI
import SwiftData
import CoreLocation

/// Detailed view for a saved pin with navigation and actions
struct PinDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var locationService = LocationService()
    
    let pin: SavedItemPin
    
    @State private var showDeleteConfirm = false
    
    private let logger = Logger()
    
    // Gradient colors
    private let gradientColors: [Color] = [
        Color(red: 0.05, green: 0.05, blue: 0.1),
        Color(red: 0.02, green: 0.02, blue: 0.05)
    ]
    
    private let iconGradientColors: [Color] = [
        Color.blue.opacity(0.3),
        Color.blue.opacity(0.15)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 10) {
                    headerSection
                    locationSection
                    distanceSection
                    actionButtons
                    Spacer(minLength: 16)
                }
                .padding(12)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationService.requestCurrentLocation()
        }
        .alert("Delete Item?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                deletePin()
                NotificationService.shared.playSuccessHaptic()
            }
            Button("Cancel", role: .cancel) {
                NotificationService.shared.playClickHaptic()
            }
        } message: {
            Text("Delete '\(pin.title)'?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: iconGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .shadow(color: .blue.opacity(0.3), radius: 8)
                
                Image(systemName: categoryIcon(pin.category))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pin.title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(pin.category)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                Text("Location")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 6) {
                locationRow(label: "Latitude", value: String(format: "%.6f", pin.latitude))
                locationRow(label: "Longitude", value: String(format: "%.6f", pin.longitude))
                if pin.altitude != 0 {
                    locationRow(label: "Altitude", value: String(format: "%.1f m", pin.altitude))
                }
                locationRow(label: "Saved", value: pin.timestamp.shortDateTimeString)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private func locationRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Distance Section
    @ViewBuilder
    private var distanceSection: some View {
        if locationService.currentLocation != nil {
            let dist = pin.distance(from: (locationService.currentLocation!.latitude, locationService.currentLocation!.longitude))
            
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                    Text("Distance")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack {
                    Text(dist < 100 ? String(format: "%.0f m", dist) : String(format: "%.2f km", dist / 100))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Spacer()
                    if dist < 10 {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Nearby!")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 8) {
            NavigationLink(destination: NavigationView(pin: pin)) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.turn.up.right")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Navigate")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 8)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(TapGesture().onEnded {
                NotificationService.shared.playClickHaptic()
            })
            
            Button(action: {
                showDeleteConfirm = true
                NotificationService.shared.playClickHaptic()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Delete")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func deletePin() {
        modelContext.delete(pin)
        do {
            try modelContext.save()
            logger.log("Pin deleted: \(pin.title)")
            dismiss()
        } catch {
            logger.logError(error)
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
    return PinDetailView(
        pin: SavedItemPin(title: "My Car", category: "Car", latitude: 40.7128, longitude: -74.0060)
    )
    .modelContainer(container)
}

