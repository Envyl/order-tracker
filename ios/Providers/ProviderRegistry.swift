import Foundation

@MainActor
final class ProviderRegistry {
    let adapters: [ProviderAdapter]
    let wildberries: WildberriesAdapter
    let aliexpress: AliExpressAdapter
    let cdek: CDEKAdapter

    init() {
        let wb = WildberriesAdapter()
        let ae = AliExpressAdapter()
        let cd = CDEKAdapter()
        self.wildberries = wb
        self.aliexpress = ae
        self.cdek = cd
        self.adapters = [wb, ae, cd]
    }

    func adapter(for provider: ProviderId) -> ProviderAdapter {
        switch provider {
        case .wildberries: return wildberries
        case .aliexpress: return aliexpress
        case .cdek: return cdek
        }
    }
}
