import Foundation
import SwiftData

@MainActor
@Observable
final class AppServices {
    let registry: ProviderRegistry
    let connections: ConnectionRepository
    let orders: OrderRepository
    let refresh: RefreshOrchestrator

    init(container: ModelContainer = PersistenceController.sharedModelContainer) {
        let context = ModelContext(container)
        self.registry = ProviderRegistry()
        self.connections = ConnectionRepository(context: context)
        self.orders = OrderRepository(context: context)
        self.refresh = RefreshOrchestrator(
            adapters: registry.adapters,
            connections: connections,
            orders: orders
        )
    }
}
