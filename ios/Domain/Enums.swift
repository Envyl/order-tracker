import Foundation

enum ProviderId: String, Codable, CaseIterable, Identifiable, Sendable {
    case wildberries
    case aliexpress
    case cdek

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wildberries: return "Wildberries"
        case .aliexpress: return "AliExpress"
        case .cdek: return "СДЭК"
        }
    }
}

enum ConnectionStatus: String, Codable, Sendable {
    case disconnected
    case connected
    case needsReauth
    case error

    var labelRU: String {
        switch self {
        case .disconnected: return "не подключено"
        case .connected: return "подключено"
        case .needsReauth: return "нужно войти снова"
        case .error: return "ошибка"
        }
    }
}

enum OrderStatus: String, Codable, Sendable {
    case placed
    case paid
    case assembling
    case inTransit
    case readyForPickup
    case delivered
    case cancelled
    case unknown

    var labelRU: String {
        switch self {
        case .placed: return "Оформлен"
        case .paid: return "Оплачен"
        case .assembling: return "Собирается"
        case .inTransit: return "В пути"
        case .readyForPickup: return "Готов к выдаче"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменён"
        case .unknown: return "Статус неизвестен"
        }
    }
}
