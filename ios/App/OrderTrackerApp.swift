import SwiftUI
import SwiftData

@main
struct OrderTrackerApp: App {
    private let services = AppServices()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(services)
                .modelContainer(PersistenceController.sharedModelContainer)
        }
    }
}
