import SwiftUI
import SwiftData

/// Home view - Main screen with quick actions and saved items - Responsive design
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationService = LocationService()
    @StateObject private var motionService = MotionService()
    
    @Query(sort: \SavedItemPin.timestamp, order: .reverse) private var pins: [SavedItemPin]
    
    @State private var navigateToItem: SavedItemPin?
    
    private let logger = Logger()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
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
                        VStack(spacing: 10) {
                            // Header
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 44, height: 44)
                                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                    
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("AutoPin")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 4)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            // Quick Actions
                            VStack(spacing: 8) {
                                NavigationLink(destination: NewPinView()) {
                                    quickActionButton(icon: "mappin.circle.fill", title: "Save Location", color: .blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .simultaneousGesture(TapGesture().onEnded { NotificationService.shared.playClickHaptic() })
                                
                                NavigationLink(destination: PinListView()) {
                                    quickActionButton(icon: "list.bullet.circle.fill", title: "My Items", color: .green, count: pins.count)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .simultaneousGesture(TapGesture().onEnded { NotificationService.shared.playClickHaptic() })
                            }
                            .padding(.horizontal, 10)
                            
                            // Recent Items
                            if !pins.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "clock.fill").font(.system(size: 9)).foregroundColor(.white.opacity(0.5))
                                        Text("Recent").font(.system(size: 10, weight: .semibold)).foregroundColor(.white.opacity(0.6))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    
                                    VStack(spacing: 4) {
                                        ForEach(pins.prefix(3)) { pin in
                                            NavigationLink(destination: PinDetailView(pin: pin)) {
                                                recentItemRow(pin: pin)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .simultaneousGesture(TapGesture().onEnded { NotificationService.shared.playClickHaptic() })
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                            
                            Spacer()
                            
                            // Status
                            statusBar
                                .padding(.horizontal, 10)
                                .padding(.bottom, 8)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            locationService.setModelContext(modelContext)
            motionService.startMonitoring()
            logger.log("HomeView appeared")
        }
        .onDisappear {
            motionService.stopMonitoring()
        }
    }
    
    private func quickActionButton(icon: String, title: String, color: Color, count: Int? = nil) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [color.opacity(0.3), color.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            if let count = count, count > 0 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.25), lineWidth: 1))
        )
    }
    
    private func recentItemRow(pin: SavedItemPin) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
                
                Image(systemName: categoryIcon(pin.category))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pin.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(pin.timestamp.relativeTimeString)
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
    
    private var statusBar: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            
            Text(locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways ? "Active" : "Off")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            if locationService.isApproaching || locationService.nearbyItem != nil {
                HStack(spacing: 3) {
                    Image(systemName: "bell.fill").font(.system(size: 7))
                    Text("Nearby")
                }
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
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
    return HomeView()
        .modelContainer(container)
}

