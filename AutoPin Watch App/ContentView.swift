import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SavedItemPin.self, configurations: config)
        return ContentView()
            .modelContainer(container)
    } catch {
        return ContentView()
    }
}