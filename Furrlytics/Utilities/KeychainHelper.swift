import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case invalidInput(String)
    case writeFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case dataConversionFailed

    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .writeFailed(let status):
            return "Keychain write failed: \(status)"
        case .readFailed(let status):
            return "Keychain read failed: \(status)"
        case .deleteFailed(let status):
            return "Keychain delete failed: \(status)"
        case .dataConversionFailed:
            return "Failed to convert Keychain data"
        }
    }
}

enum KeychainHelper {

    private static let serviceName = "com.furrlytics.app"

    // MARK: - Save

    static func save(key: String, value: String) throws {
        guard !key.isEmpty else { throw KeychainError.invalidInput("Key is empty") }
        guard !value.isEmpty else { throw KeychainError.invalidInput("Value is empty") }

        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }

        // Delete existing item first to avoid duplicates
        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.writeFailed(status: status)
        }
    }

    // MARK: - Read

    static func read(key: String) throws -> String? {
        guard !key.isEmpty else { throw KeychainError.invalidInput("Key is empty") }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status: status)
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.dataConversionFailed
        }

        return string
    }

    // MARK: - Delete

    static func delete(key: String) throws {
        guard !key.isEmpty else { throw KeychainError.invalidInput("Key is empty") }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}
