import Foundation

// MARK: - Error Types

enum PetlibroError: Error, LocalizedError {
    case notAuthenticated
    case invalidCredentials
    case apiError(statusCode: Int)
    case decodingFailed
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with Petlibro"
        case .invalidCredentials:
            return "Invalid Petlibro credentials"
        case .apiError(let code):
            return "Petlibro API error: \(code)"
        case .decodingFailed:
            return "Failed to decode Petlibro response"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

// MARK: - API Client Protocol

protocol PetlibroAPIClient: Sendable {
    func authenticate(email: String, hashedPassword: String) async -> Result<String, PetlibroError>
    func fetchFeedingData(token: String) async -> Result<[PetlibroFeedingRecord], PetlibroError>
}

// MARK: - Data Types

struct PetlibroFeedingRecord: Sendable {
    let id: String
    let timestamp: Date
    let gramsDispensed: Int
    let foodType: String
}

// MARK: - Credential Keys

enum PetlibroCredentialKeys {
    static let email = "petlibro_email"
    static let passwordHash = "petlibro_password_hash"
}

// MARK: - PetlibroService

@Observable
class PetlibroService {
    private let apiClient: PetlibroAPIClient
    private var authToken: String?

    var isAuthenticated: Bool { authToken != nil }

    init(apiClient: PetlibroAPIClient = StubPetlibroAPIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Authentication

    func authenticate(email: String, hashedPassword: String) async -> Result<Void, PetlibroError> {
        let result = await apiClient.authenticate(email: email, hashedPassword: hashedPassword)
        switch result {
        case .success(let token):
            authToken = token
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    func logout() {
        authToken = nil
    }

    // MARK: - Feeding Data

    func fetchTodayFeedingData() async -> Result<[PetlibroFeedingRecord], PetlibroError> {
        guard let token = authToken else {
            return .failure(.notAuthenticated)
        }
        return await apiClient.fetchFeedingData(token: token)
    }
}

// MARK: - Stub Implementation

struct StubPetlibroAPIClient: PetlibroAPIClient {
    func authenticate(email: String, hashedPassword: String) async -> Result<String, PetlibroError> {
        return .failure(.networkUnavailable)
    }

    func fetchFeedingData(token: String) async -> Result<[PetlibroFeedingRecord], PetlibroError> {
        return .failure(.networkUnavailable)
    }
}
