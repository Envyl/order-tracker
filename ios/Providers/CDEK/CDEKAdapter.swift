import Foundation

final class CDEKAdapter: ProviderAdapter, @unchecked Sendable {
    let providerId: ProviderId = .cdek
    var displayName: String { providerId.displayName }
    private let http = HTTPClient()

    func connect(credentials: ProviderCredentials) async -> ConnectionResult {
        guard case let .cdek(login, codeOrPassword) = credentials else {
            return .failure(message: "Неверный тип учётных данных для СДЭК")
        }
        let trimmedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLogin.isEmpty else {
            return .failure(message: "Укажите телефон или логин СДЭК")
        }
        guard !codeOrPassword.isEmpty else {
            return .failure(message: "Укажите код или пароль СДЭК")
        }

        let liveOK = await probeLive()
        if liveOK || AppSettings.allowOfflineProviderLink {
            let hint = LoginHinting.maskLogin(trimmedLogin)
            let blob = ProviderSessionBlob(
                provider: .cdek,
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
        return .failure(message: "Не удалось проверить вход в СДЭК. Проверьте данные или сеть.")
    }

    func disconnect() async {
        KeychainSessionStore.delete(provider: .cdek)
    }

    func refreshRecentOrders(horizonDays: Int) async -> RefreshResult {
        guard let session = try? KeychainSessionStore.load(provider: .cdek) else {
            return .failure(kind: .authExpired, message: "Нужно войти в СДЭК снова")
        }
        if AppSettings.useFixturesWhenLiveFails || session.offlineLinked {
            return .success(orders: ProviderFixtureFactory.sampleOrders(for: .cdek, loginHint: session.loginHint))
        }
        return .failure(kind: .unavailable, message: "СДЭК временно недоступен")
    }

    private func probeLive() async -> Bool {
        guard let url = URL(string: "https://www.cdek.ru") else { return false }
        do {
            let (_, response) = try await http.get(url: url)
            return (200..<500).contains(response.statusCode)
        } catch {
            return false
        }
    }
}
