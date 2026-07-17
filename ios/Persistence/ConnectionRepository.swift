import Foundation
import SwiftData

@MainActor
final class ConnectionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        ensureRows()
    }

    private func ensureRows() {
        for provider in ProviderId.allCases {
            if fetch(provider: provider) == nil {
                let row = SDProviderConnection(
                    provider: provider,
                    status: .disconnected,
                    keychainAccount: KeychainSessionStore.account(for: provider)
                )
                context.insert(row)
            }
        }
        try? context.save()
    }

    func all() -> [ProviderConnection] {
        ensureRows()
        let descriptor = FetchDescriptor<SDProviderConnection>()
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows
            .map(map)
            .sorted { $0.provider.rawValue < $1.provider.rawValue }
    }

    func fetch(provider: ProviderId) -> SDProviderConnection? {
        let raw = provider.rawValue
        var descriptor = FetchDescriptor<SDProviderConnection>(
            predicate: #Predicate { $0.providerRaw == raw }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func upsertConnected(provider: ProviderId, loginHint: String) throws {
        guard let row = fetch(provider: provider) else { return }
        row.statusRaw = ConnectionStatus.connected.rawValue
        row.displayLoginHint = loginHint
        row.lastErrorMessage = nil
        row.lastSuccessAt = Date()
        try context.save()
    }

    func setStatus(provider: ProviderId, status: ConnectionStatus, errorMessage: String?) throws {
        guard let row = fetch(provider: provider) else { return }
        row.statusRaw = status.rawValue
        row.lastErrorMessage = errorMessage
        if status == .disconnected {
            row.displayLoginHint = nil
        }
        try context.save()
    }

    func markRefreshSuccess(provider: ProviderId) throws {
        guard let row = fetch(provider: provider) else { return }
        row.statusRaw = ConnectionStatus.connected.rawValue
        row.lastSuccessAt = Date()
        row.lastErrorMessage = nil
        try context.save()
    }

    private func map(_ row: SDProviderConnection) -> ProviderConnection {
        ProviderConnection(
            id: row.id,
            provider: row.provider,
            status: row.status,
            displayLoginHint: row.displayLoginHint,
            lastSuccessAt: row.lastSuccessAt,
            lastErrorMessage: row.lastErrorMessage,
            keychainAccount: row.keychainAccount
        )
    }
}
