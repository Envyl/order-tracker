import Foundation

enum AliExpressStatusMapper {
    static func map(_ raw: String?) -> (OrderStatus, String?) {
        guard let raw, !raw.isEmpty else { return (.unknown, nil) }
        let lower = raw.lowercased()
        if lower.contains("cancel") || lower.contains("отмен") { return (.cancelled, raw) }
        if lower.contains("pickup") || lower.contains("выдач") { return (.readyForPickup, raw) }
        if lower.contains("ship") || lower.contains("transit") || lower.contains("путь") { return (.inTransit, raw) }
        if lower.contains("process") || lower.contains("prepar") || lower.contains("сбор") { return (.assembling, raw) }
        if lower.contains("paid") || lower.contains("оплач") { return (.paid, raw) }
        if lower.contains("deliver") || lower.contains("доставлен") { return (.delivered, raw) }
        return (.unknown, raw)
    }
}
