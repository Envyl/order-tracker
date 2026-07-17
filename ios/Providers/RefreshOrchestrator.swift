import Foundation

struct ProviderRefreshOutcome: Sendable {
    var provider: ProviderId
    var result: RefreshResult
}

@MainActor
final class RefreshOrchestrator {
    private let adapters: [ProviderAdapter]
    private let connections: ConnectionRepository
    private let orders: OrderRepository

    init(adapters: [ProviderAdapter], connections: ConnectionRepository, orders: OrderRepository) {
        self.adapters = adapters
        self.connections = connections
        self.orders = orders
    }

    func refreshAll(horizonDays: Int = 30) async -> [ProviderRefreshOutcome] {
        let connected = connections.all().filter { $0.status == .connected || $0.status == .error || $0.status == .needsReauth }
        let targets = adapters.filter { adapter in
            connected.contains { $0.provider == adapter.providerId && $0.status != .disconnected }
        }

        var outcomes: [ProviderRefreshOutcome] = []
        await withTaskGroup(of: ProviderRefreshOutcome.self) { group in
            for adapter in targets {
                group.addTask { [adapter] in
                    let result = await adapter.refreshRecentOrders(horizonDays: horizonDays)
                    return ProviderRefreshOutcome(provider: adapter.providerId, result: result)
                }
            }
            for await outcome in group {
                outcomes.append(outcome)
            }
        }

        for outcome in outcomes {
            switch outcome.result {
            case .success(let drafts):
                try? orders.upsert(provider: outcome.provider, drafts: drafts, markStaleOthers: true)
                try? connections.markRefreshSuccess(provider: outcome.provider)
            case .failure(let kind, let message):
                try? orders.markStale(provider: outcome.provider)
                let status: ConnectionStatus = (kind == .authExpired) ? .needsReauth : .error
                try? connections.setStatus(provider: outcome.provider, status: status, errorMessage: message)
                RedactingLog.error("Refresh failed for \(outcome.provider.rawValue): \(message)")
            }
        }
        return outcomes
    }
}
