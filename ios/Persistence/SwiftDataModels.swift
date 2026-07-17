import Foundation
import SwiftData

@Model
final class SDProviderConnection {
    @Attribute(.unique) var providerRaw: String
    var id: UUID
    var statusRaw: String
    var displayLoginHint: String?
    var lastSuccessAt: Date?
    var lastErrorMessage: String?
    var keychainAccount: String

    init(
        id: UUID = UUID(),
        provider: ProviderId,
        status: ConnectionStatus = .disconnected,
        displayLoginHint: String? = nil,
        lastSuccessAt: Date? = nil,
        lastErrorMessage: String? = nil,
        keychainAccount: String
    ) {
        self.id = id
        self.providerRaw = provider.rawValue
        self.statusRaw = status.rawValue
        self.displayLoginHint = displayLoginHint
        self.lastSuccessAt = lastSuccessAt
        self.lastErrorMessage = lastErrorMessage
        self.keychainAccount = keychainAccount
    }

    var provider: ProviderId { ProviderId(rawValue: providerRaw) ?? .wildberries }
    var status: ConnectionStatus { ConnectionStatus(rawValue: statusRaw) ?? .disconnected }
}

@Model
final class SDOrder {
    var id: UUID
    var providerRaw: String
    var providerOrderId: String
    var statusRaw: String
    var statusRawLabel: String?
    var lastUpdatedAt: Date
    var fetchedAt: Date
    var isStale: Bool
    @Relationship(deleteRule: .cascade, inverse: \SDOrderItem.order)
    var items: [SDOrderItem]
    @Relationship(deleteRule: .cascade, inverse: \SDStatusSnapshot.order)
    var snapshots: [SDStatusSnapshot]

    init(
        id: UUID = UUID(),
        provider: ProviderId,
        providerOrderId: String,
        status: OrderStatus,
        statusRawLabel: String? = nil,
        lastUpdatedAt: Date,
        fetchedAt: Date,
        isStale: Bool = false
    ) {
        self.id = id
        self.providerRaw = provider.rawValue
        self.providerOrderId = providerOrderId
        self.statusRaw = status.rawValue
        self.statusRawLabel = statusRawLabel
        self.lastUpdatedAt = lastUpdatedAt
        self.fetchedAt = fetchedAt
        self.isStale = isStale
        self.items = []
        self.snapshots = []
    }

    var provider: ProviderId { ProviderId(rawValue: providerRaw) ?? .wildberries }
    var status: OrderStatus { OrderStatus(rawValue: statusRaw) ?? .unknown }
}

@Model
final class SDOrderItem {
    var id: UUID
    var title: String
    var imageURLString: String?
    var sortIndex: Int
    var quantity: Int
    var order: SDOrder?

    init(id: UUID = UUID(), title: String, imageURL: URL?, sortIndex: Int, quantity: Int) {
        self.id = id
        self.title = title
        self.imageURLString = imageURL?.absoluteString
        self.sortIndex = sortIndex
        self.quantity = quantity
    }
}

@Model
final class SDStatusSnapshot {
    var id: UUID
    var statusRaw: String
    var rawLabel: String?
    var recordedAt: Date
    var order: SDOrder?

    init(id: UUID = UUID(), status: OrderStatus, rawLabel: String?, recordedAt: Date) {
        self.id = id
        self.statusRaw = status.rawValue
        self.rawLabel = rawLabel
        self.recordedAt = recordedAt
    }

    var status: OrderStatus { OrderStatus(rawValue: statusRaw) ?? .unknown }
}
