import Foundation

enum WildberriesStatusMapper {
    static func map(_ raw: String?) -> (OrderStatus, String?) {
        guard let raw, !raw.isEmpty else { return (.unknown, nil) }
        let lower = raw.lowercased()
        if lower.contains("отмен") { return (.cancelled, raw) }
        if lower.contains("выдач") || lower.contains("готов") { return (.readyForPickup, raw) }
        if lower.contains("путь") || lower.contains("доставк") { return (.inTransit, raw) }
        if lower.contains("сбор") { return (.assembling, raw) }
        if lower.contains("оплач") { return (.paid, raw) }
        if lower.contains("оформ") { return (.placed, raw) }
        if lower.contains("получен") || lower.contains("доставлен") { return (.delivered, raw) }
        return (.unknown, raw)
    }
}
