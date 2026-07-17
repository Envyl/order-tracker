import Foundation

enum ProviderFixtureFactory {
    static func sampleOrders(for provider: ProviderId, loginHint: String) -> [NormalizedOrderDraft] {
        let now = Date()
        switch provider {
        case .wildberries:
            let raw = "В пути на ПВЗ"
            let mapped = WildberriesStatusMapper.map(raw)
            return [
                NormalizedOrderDraft(
                    providerOrderId: "WB-\(abs(loginHint.hashValue % 100000))",
                    status: mapped.0,
                    statusRawLabel: mapped.1,
                    lastUpdatedAt: now.addingTimeInterval(-3600),
                    items: [
                        NormalizedOrderItemDraft(
                            title: "Наушники беспроводные",
                            imageURL: URL(string: "https://via.placeholder.com/120"),
                            quantity: 1
                        ),
                        NormalizedOrderItemDraft(title: "Чехол", imageURL: nil, quantity: 1)
                    ]
                )
            ]
        case .aliexpress:
            let raw = "Seller is preparing"
            let mapped = AliExpressStatusMapper.map(raw)
            return [
                NormalizedOrderDraft(
                    providerOrderId: "AE-\(abs(loginHint.hashValue % 100000))",
                    status: mapped.0,
                    statusRawLabel: mapped.1,
                    lastUpdatedAt: now.addingTimeInterval(-7200),
                    items: [
                        NormalizedOrderItemDraft(
                            title: "USB-C кабель 2м",
                            imageURL: URL(string: "https://via.placeholder.com/120/09f/fff"),
                            quantity: 2
                        )
                    ]
                )
            ]
        case .cdek:
            let raw = "Прибыло в пункт выдачи"
            let mapped = CDEKStatusMapper.map(raw)
            return [
                NormalizedOrderDraft(
                    providerOrderId: "CDEK-\(abs(loginHint.hashValue % 100000))",
                    status: mapped.0,
                    statusRawLabel: mapped.1,
                    lastUpdatedAt: now.addingTimeInterval(-1800),
                    items: [
                        NormalizedOrderItemDraft(
                            title: "Посылка СДЭК",
                            imageURL: nil,
                            quantity: 1
                        )
                    ]
                )
            ]
        }
    }
}

enum LoginHinting {
    static func maskPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count >= 4 else { return "•••" }
        return "•••" + String(digits.suffix(4))
    }

    static func maskLogin(_ login: String) -> String {
        if login.contains("@") {
            let parts = login.split(separator: "@", maxSplits: 1)
            guard parts.count == 2 else { return "•••" }
            let name = String(parts[0])
            let prefix = name.prefix(1)
            return "\(prefix)•••@\(parts[1])"
        }
        return maskPhone(login)
    }
}
