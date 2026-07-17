import Foundation

struct ProviderConnection: Identifiable, Hashable, Sendable {
    var id: UUID
    var provider: ProviderId
    var status: ConnectionStatus
    var displayLoginHint: String?
    var lastSuccessAt: Date?
    var lastErrorMessage: String?
    var keychainAccount: String
}

struct OrderItem: Identifiable, Hashable, Sendable {
    var id: UUID
    var title: String
    var imageURL: URL?
    var sortIndex: Int
    var quantity: Int
}

struct StatusSnapshot: Identifiable, Hashable, Sendable {
    var id: UUID
    var status: OrderStatus
    var rawLabel: String?
    var recordedAt: Date
}

struct Order: Identifiable, Hashable, Sendable {
    var id: UUID
    var provider: ProviderId
    var providerOrderId: String
    var status: OrderStatus
    var statusRawLabel: String?
    var lastUpdatedAt: Date
    var fetchedAt: Date
    var isStale: Bool
    var items: [OrderItem]
    var latestSnapshot: StatusSnapshot?

    var primaryItem: OrderItem? {
        items.sorted { $0.sortIndex < $1.sortIndex }.first
    }

    var extraItemCount: Int {
        max(0, items.count - 1)
    }
}

enum AppSettings {
    /// When true, connect may succeed after a failed live auth so the personal app remains usable while unofficial buyer APIs are unstable.
    static var allowOfflineProviderLink: Bool {
        get { UserDefaults.standard.object(forKey: "allowOfflineProviderLink") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "allowOfflineProviderLink") }
    }

    static var useFixturesWhenLiveFails: Bool {
        get { UserDefaults.standard.object(forKey: "useFixturesWhenLiveFails") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "useFixturesWhenLiveFails") }
    }
}
