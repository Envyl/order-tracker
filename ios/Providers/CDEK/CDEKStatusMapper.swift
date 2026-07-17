import Foundation

enum CDEKStatusMapper {
    static func map(_ raw: String?) -> (OrderStatus, String?) {
        guard let raw, !raw.isEmpty else { return (.unknown, nil) }
        let lower = raw.lowercased()
        if lower.contains("отмен") { return (.cancelled, raw) }
        if lower.contains("пункт") || lower.contains("выдач") || lower.contains("прибыл") { return (.readyForPickup, raw) }
        if lower.contains("путь") || lower.contains("транзит") { return (.inTransit, raw) }
        if lower.contains("создан") || lower.contains("оформ") { return (.placed, raw) }
        if lower.contains("вручен") || lower.contains("доставлен") { return (.delivered, raw) }
        return (.unknown, raw)
    }
}
