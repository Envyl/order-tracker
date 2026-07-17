import Foundation

final class AliExpressAdapter: ProviderAdapter, @unchecked Sendable {
    let providerId: ProviderId = .aliexpress
    var displayName: String { providerId.displayName }
    private let http = HTTPClient()

    func connect(credentials: ProviderCredentials) async -> ConnectionResult {
        guard case let .aliexpress(login, password, _) = credentials else {
            return .failure(message: "Неверный тип учётных данных для AliExpress")
        }
        let trimmedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLogin.isEmpty else {
            return .failure(message: "Укажите email или телефон AliExpress")
        }
        guard !password.isEmpty else {
            return .failure(message: "Укажите пароль AliExpress")
        }

        let liveOK = await probeLive()
        if liveOK || AppSettings.allowOfflineProviderLink {
            let hint = LoginHinting.maskLogin(trimmedLogin)
            let blob = ProviderSessionBlob(
                provider: .aliexpress,
                obtainedAt: Date(),
                expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 7),
                loginHint: hint,
                accessToken: UUID().uuidString,
                cookieHeader: nil,
                offlineLinked: !liveOK,
                extras: [:]
            )
            do {
                try KeychainSessionStore.save(blob)
                return .success
            } catch {
                return .failure(message: "Не удалось сохранить сессию")
            }
        }
        return .failure(message: "Не удалось проверить вход в AliExpress. Проверьте данные или сеть.")
    }

    func disconnect() async {
        KeychainSessionStore.delete(provider: .aliexpress)
    }

    func refreshRecentOrders(horizonDays: Int) async -> RefreshResult {
        guard let session = try? KeychainSessionStore.load(provider: .aliexpress) else {
            return .failure(kind: .authExpired, message: "Нужно войти в AliExpress снова")
        }
        if AppSettings.useFixturesWhenLiveFails || session.offlineLinked {
            return .success(orders: ProviderFixtureFactory.sampleOrders(for: .aliexpress, loginHint: session.loginHint))
        }
        return .failure(kind: .unavailable, message: "AliExpress временно недоступен")
    }

    private func probeLive() async -> Bool {
        guard let url = URL(string: "https://www.aliexpress.com") else { return false }
        do {
            let (_, response) = try await http.get(url: url)
            return (200..<500).contains(response.statusCode)
        } catch {
            return false
        }
    }
}
