import Foundation

@MainActor
@Observable
final class ConnectionsViewModel {
    private let services: AppServices
    var connections: [ProviderConnection] = []
    var errorMessage: String?
    var isWorking = false

    init(services: AppServices) {
        self.services = services
        reload()
    }

    func reload() {
        connections = services.connections.all()
    }

    func connect(provider: ProviderId, credentials: ProviderCredentials) async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        let adapter = services.registry.adapter(for: provider)
        let result = await adapter.connect(credentials: credentials)
        switch result {
        case .success:
            let hint: String
            switch credentials {
            case .wildberries(let phone, _, _):
                hint = LoginHinting.maskPhone(phone)
            case .aliexpress(let login, _, _):
                hint = LoginHinting.maskLogin(login)
            case .cdek(let login, _):
                hint = LoginHinting.maskLogin(login)
            }
            try? services.connections.upsertConnected(provider: provider, loginHint: hint)
            reload()
        case .failure(let message):
            try? services.connections.setStatus(provider: provider, status: .disconnected, errorMessage: message)
            errorMessage = message
            reload()
        }
    }

    func disconnect(provider: ProviderId) async {
        isWorking = true
        defer { isWorking = false }
        await services.registry.adapter(for: provider).disconnect()
        try? services.connections.setStatus(provider: provider, status: .disconnected, errorMessage: nil)
        reload()
    }
}
