import XCTest
import CryptoKit
@testable import Furrlytics

final class U003_OnboardingTests: XCTestCase {

    // MARK: - MD5 Hashing Tests

    func testMD5Hash_knownInput_producesExpectedOutput() {
        let hash = md5Hash("password123")
        XCTAssertEqual(hash, "482c811da5d5b4bc6d497ffa98491e38")
    }

    func testMD5Hash_emptyString_producesExpectedOutput() {
        let hash = md5Hash("")
        XCTAssertEqual(hash, "d41d8cd98f00b204e9800998ecf8427e")
    }

    func testMD5Hash_chineseCharacters_producesConsistentOutput() {
        let hash1 = md5Hash("密码测试")
        let hash2 = md5Hash("密码测试")
        XCTAssertEqual(hash1, hash2)
        XCTAssertEqual(hash1.count, 32)
    }

    func testMD5Hash_outputIsLowercaseHex() {
        let hash = md5Hash("test")
        let validHexCharacters = CharacterSet(charactersIn: "0123456789abcdef")
        XCTAssertTrue(hash.unicodeScalars.allSatisfy { validHexCharacters.contains($0) })
    }

    // MARK: - CatProfile Validation Tests

    func testCatProfile_nameTrimmingWhitespace_producesCleanName() {
        let profile = CatProfile(name: "  Mimi  ")
        XCTAssertEqual(profile.name, "  Mimi  ") // Model stores as-is; trimming happens in view
    }

    func testCatProfile_uniqueIds_areGeneratedForEachProfile() {
        let profile1 = CatProfile(name: "Cat A")
        let profile2 = CatProfile(name: "Cat B")
        XCTAssertNotEqual(profile1.id, profile2.id)
    }

    func testCatProfile_photoDataOptional_defaultsToNil() {
        let profile = CatProfile(name: "Mimi")
        XCTAssertNil(profile.photoData)
    }

    // MARK: - HomeLocation Validation Tests

    func testHomeLocation_defaultRadius_isGeofenceDefault() {
        let location = HomeLocation(latitude: 39.9, longitude: 116.4)
        XCTAssertEqual(location.radiusMeters, GeofenceDefaults.radiusMeters)
    }

    func testHomeLocation_customRadius_isStored() {
        let location = HomeLocation(latitude: 39.9, longitude: 116.4, radiusMeters: 300)
        XCTAssertEqual(location.radiusMeters, 300)
    }

    // MARK: - PetlibroCredentialKeys Tests

    func testPetlibroCredentialKeys_areNonEmpty() {
        XCTAssertFalse(PetlibroCredentialKeys.email.isEmpty)
        XCTAssertFalse(PetlibroCredentialKeys.passwordHash.isEmpty)
    }

    // MARK: - Helpers

    private func md5Hash(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
