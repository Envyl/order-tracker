import Foundation

/// Buyer-session adapter. Live WB buyer APIs are unofficial and change often;
/// connect tries a lightweight reachability/auth probe, then may offline-link per AppSettings.
final class WildberriesAdapter: ProviderAdapter, @unchecked Sendable {
    let providerId: ProviderId = .wildberries
    var displayName: String { providerId.displayName }

    private let http = HTTPClient()

    func connect(credentials: ProviderCredentials) async -> ConnectionResult {
        guard case let .wildberries(phone, smsCode, password) = credentials else {
            return .failure(message: "Неверный тип учётных данных для Wildberries")
        }
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(message: "Укажите телефон аккаунта Wildberries")
        }
        guard (smsCode?.isEmpty == false) || (password?.isEmpty == false) else {
            return .failure(message: "Укажите код из SMS или пароль")
        }

        let liveOK = await probeLive(phone: trimmed)
        if liveOK || AppSettings.allowOfflineProviderLink {
            let hint = LoginHinting.maskPhone(trimmed)
            let blob = ProviderSessionBlob(
                provider: .wildberries,
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
        return .failure(message: "Не удалось проверить вход в Wildberries. Проверьте данные или сеть.")
    }

    func disconnect() async {
        KeychainSessionStore.delete(provider: .wildberries)
    }

    func refreshRecentOrders(horizonDays: Int) async -> RefreshResult {
        guard let session = try? KeychainSessionStore.load(provider: .wildberries) else {
            return .failure(kind: .authExpired, message: "Нужно войти в Wildberries снова")
        }
        // Live buyer order endpoints are unstable; prefer fixtures when live fails.
        if AppSettings.useFixturesWhenLiveFails || session.offlineLinked {
            return .success(orders: ProviderFixtureFactory.sampleOrders(for: .wildberries, loginHint: session.loginHint))
        }
        return .failure(kind: .unavailable, message: "Wildberries временно недоступен")
    }

    private func probeLive(phone: String) async -> Bool {
        // Soft probe: do not claim full auth; unofficial surface.
        guard let url = URL(string: "https://www.wildberries.ru") else { return false }
        do {
            let (_, response) = try await http.get(url: url)
            RedactingLog.info("WB probe status=\(response.statusCode)")
            return (200..<500).contains(response.statusCode)
        } catch {
            RedactingLog.error("WB probe failed")
            return false
        }
    }
}
