import SwiftUI
import CoreLocation

/// Navigation view showing arrow-based guidance back to saved item
struct NavigationView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var locationService = LocationService()
    @State private var updateTimer: Timer?
    @State private var bearing: Double = 0
    
    let pin: SavedItemPin
    private let logger = Logger()
    
    var body: some View {
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
            
            VStack(spacing: 12) {
                // Header
                HStack {
                    Button(action: {
                        NotificationService.shared.playClickHaptic()
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Text("Navigate")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 28, height: 28)
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                
                Spacer()
                
                // Direction Arrow & Distance
                VStack(spacing: 14) {
                    // Arrow with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.2),
                                        Color.blue.opacity(0.08)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 55))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(bearing))
                            .shadow(color: .blue.opacity(0.5), radius: 10)
                    }
                    
                    // Item Name
                    Text(pin.title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Distance
                    if locationService.currentLocation != nil {
                        let dist = pin.distance(from: (locationService.currentLocation!.latitude, locationService.currentLocation!.longitude))
                        
                        VStack(spacing: 6) {
                            Text("Distance")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            
                            if dist < 100 {
                                Text(String(format: "%.0f m", dist))
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                            } else {
                                Text(String(format: "%.2f km", dist / 100))
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                            }
                            
                            if dist < 10 {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("You're here!")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.green)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    } else {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Getting location...")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.orange)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                
                Spacer()
                
                // Category badge
                Text(pin.category)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .foregroundColor(.blue)
                
                // Help Text
                Text("Follow the arrow")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 10)
            }
            .padding()
        }
        .onAppear {
            locationService.startUpdatingLocation()
            startUpdateTimer()
            logger.log("Navigation started for \(pin.title)")
            NotificationService.shared.playSuccessHaptic()
        }
        .onDisappear {
            locationService.stopUpdatingLocation()
            updateTimer?.invalidate()
        }
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateNavigation()
        }
    }
    
    private func updateNavigation() {
        guard let currentLocation = locationService.currentLocation else { return }
        
        let pinLat = pin.latitude
        let pinLon = pin.longitude
        let currentLat = currentLocation.latitude
        let currentLon = currentLocation.longitude
        
        // Calculate bearing
        let dLon = (pinLon - currentLon) * .pi / 180
        let currentLatRad = currentLat * .pi / 180
        let pinLatRad = pinLat * .pi / 180
        
        let y = sin(dLon) * cos(pinLatRad)
        let x = cos(currentLatRad) * sin(pinLatRad) - sin(currentLatRad) * cos(pinLatRad) * cos(dLon)
        var calculatedBearing = atan2(y, x) * 180 / .pi
        
        // Normalize to 0-360
        calculatedBearing = (calculatedBearing + 360).truncatingRemainder(dividingBy: 360)
        
        bearing = calculatedBearing
    }
}

#Preview {
    NavigationView(
        pin: SavedItemPin(
            title: "My Car",
            category: "Car",
            latitude: 40.7128,
            longitude: -74.0060
        )
    )
}

