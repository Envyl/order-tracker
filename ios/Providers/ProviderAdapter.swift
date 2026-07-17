import Foundation

enum ProviderCredentials: Sendable {
    case wildberries(phone: String, smsCode: String?, password: String?)
    case aliexpress(login: String, password: String, challengeCode: String?)
    case cdek(login: String, codeOrPassword: String)
}

enum ConnectionResult: Sendable {
    case success
    case failure(message: String)
}

enum RefreshFailureKind: Sendable {
    case authExpired
    case unavailable
    case parseError
}

enum RefreshResult: Sendable {
    case success(orders: [NormalizedOrderDraft])
    case failure(kind: RefreshFailureKind, message: String)
}

struct NormalizedOrderItemDraft: Sendable {
    var title: String
    var imageURL: URL?
    var quantity: Int
}

struct NormalizedOrderDraft: Sendable {
    var providerOrderId: String
    var status: OrderStatus
    var statusRawLabel: String?
    var lastUpdatedAt: Date
    var items: [NormalizedOrderItemDraft]
}

protocol ProviderAdapter: AnyObject, Sendable {
    var providerId: ProviderId { get }
    var displayName: String { get }

    func connect(credentials: ProviderCredentials) async -> ConnectionResult
    func disconnect() async
    func refreshRecentOrders(horizonDays: Int) async -> RefreshResult
}
