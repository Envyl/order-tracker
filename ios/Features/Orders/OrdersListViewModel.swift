import Foundation

@MainActor
@Observable
final class OrdersListViewModel {
    private let services: AppServices
    var orders: [Order] = []
    var connections: [ProviderConnection] = []
    var lastRefreshAt: Date?
    var isRefreshing = false
    var bannerMessages: [String] = []

    init(services: AppServices) {
        self.services = services
        reload()
    }

    func reload() {
        orders = services.orders.allVisible()
        connections = services.connections.all()
        bannerMessages = connections.compactMap { connection in
            guard connection.status == .error || connection.status == .needsReauth else { return nil }
            let detail = connection.lastErrorMessage ?? connection.status.labelRU
            return "\(connection.provider.displayName): \(detail)"
        }
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        _ = await services.refresh.refreshAll()
        lastRefreshAt = Date()
        reload()
    }
}
