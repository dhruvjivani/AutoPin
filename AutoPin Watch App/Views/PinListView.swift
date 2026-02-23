import SwiftUI
import SwiftData

/// View displaying list of saved item pins
struct PinListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedItemPin.timestamp, order: .reverse) var pins: [SavedItemPin]
    
    @State private var showAddSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedCategory: String = "All"
    
    private let logger = Logger()
    private let categories = ["All", "Car", "Bag", "Laptop", "Jacket", "Other"]
    
    var filteredPins: [SavedItemPin] {
        if selectedCategory == "All" {
            return pins
        }
        return pins.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
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
                
                VStack(spacing: 0) {
                    if pins.isEmpty {
                        emptyStateView
                    } else {
                        categoryFilterView
                        itemsListView
                    }
                }
            }
            .navigationTitle("My Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    
                }
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    NewPinView()
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "mappin.slash")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 6) {
                Text("No Items Saved")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Save your first location")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Button(action: {
                showAddSheet = true
                NotificationService.shared.playClickHaptic()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add Item")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [Color.blue, Color.blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - Category Filter
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        NotificationService.shared.playClickHaptic()
                    }) {
                        HStack(spacing: 4) {
                            if category != "All" {
                                Image(systemName: categoryIcon(category))
                                    .font(.system(size: 9))
                            }
                            Text(category)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory == category ? Color.blue : Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategory == category ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Items List
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(filteredPins) { pin in
                    NavigationLink(destination: PinDetailView(pin: pin)) {
                        itemRow(pin: pin)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        NotificationService.shared.playClickHaptic()
                    })
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
    
    private func itemRow(pin: SavedItemPin) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                
                Image(systemName: categoryIcon(pin.category))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(pin.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 8))
                    Text(pin.timestamp.relativeTimeString)
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
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
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SavedItemPin.self, configurations: config)
        return PinListView()
            .modelContainer(container)
    } catch {
        return PinListView()
    }
}

