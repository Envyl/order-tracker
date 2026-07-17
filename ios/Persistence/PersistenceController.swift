import Foundation
import SwiftData

enum PersistenceController {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SDProviderConnection.self,
            SDOrder.self,
            SDOrderItem.self,
            SDStatusSnapshot.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }()
}
