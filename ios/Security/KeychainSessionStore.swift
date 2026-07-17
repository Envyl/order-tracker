import Foundation
import Security

struct ProviderSessionBlob: Codable, Sendable {
    var provider: ProviderId
    var obtainedAt: Date
    var expiresAt: Date?
    var loginHint: String
    var accessToken: String?
    var cookieHeader: String?
    var offlineLinked: Bool
    /// Opaque extras (never log).
    var extras: [String: String]
}

enum KeychainSessionStore {
    private static let service = "com.personal.ordertracker.sessions"

    static func account(for provider: ProviderId) -> String {
        "session.\(provider.rawValue)"
    }

    static func save(_ blob: ProviderSessionBlob) throws {
        let data = try JSONEncoder().encode(blob)
        let account = account(for: blob.provider)
        delete(provider: blob.provider)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status)
        }
        RedactingLog.info("Saved session for \(blob.provider.rawValue)")
    }

    static func load(provider: ProviderId) throws -> ProviderSessionBlob? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account(for: provider),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError.unhandled(status)
        }
        return try JSONDecoder().decode(ProviderSessionBlob.self, from: data)
    }

    static func delete(provider: ProviderId) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account(for: provider)
        ]
        SecItemDelete(query as CFDictionary)
        RedactingLog.info("Deleted session for \(provider.rawValue)")
    }

    enum KeychainError: Error {
        case unhandled(OSStatus)
    }
}
