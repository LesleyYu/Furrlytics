import XCTest
import SwiftData
@testable import Furrlytics

final class IT001_OnboardingPersistenceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([CareEvent.self, CatProfile.self, HomeLocation.self, DewormingSchedule.self, TreatItem.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
    }

    // MARK: - CatProfile Persistence

    func testInsertCatProfile_canBeQueriedBack() throws {
        let cat = CatProfile(name: "Mimi")
        context.insert(cat)
        try context.save()

        let descriptor = FetchDescriptor<CatProfile>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Mimi")
        XCTAssertEqual(results.first?.id, cat.id)
    }

    func testInsertMultipleCatProfiles_allPersist() throws {
        let cat1 = CatProfile(name: "Mimi")
        let cat2 = CatProfile(name: "Doudou")
        let cat3 = CatProfile(name: "Xiaobai")
        context.insert(cat1)
        context.insert(cat2)
        context.insert(cat3)
        try context.save()

        let descriptor = FetchDescriptor<CatProfile>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 3)
        let names = Set(results.map(\.name))
        XCTAssertTrue(names.contains("Mimi"))
        XCTAssertTrue(names.contains("Doudou"))
        XCTAssertTrue(names.contains("Xiaobai"))
    }

    func testCatProfileWithPhoto_photoDataPersists() throws {
        let fakePhoto = Data("fake-photo-data".utf8)
        let cat = CatProfile(name: "Mimi", photoData: fakePhoto)
        context.insert(cat)
        try context.save()

        let descriptor = FetchDescriptor<CatProfile>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.first?.photoData, fakePhoto)
    }

    // MARK: - HomeLocation Persistence

    func testInsertHomeLocation_canBeQueriedBack() throws {
        let location = HomeLocation(latitude: 39.9042, longitude: 116.4074, radiusMeters: 250)
        context.insert(location)
        try context.save()

        let descriptor = FetchDescriptor<HomeLocation>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        let fetched = try XCTUnwrap(results.first)
        XCTAssertEqual(fetched.latitude, 39.9042, accuracy: 0.0001)
        XCTAssertEqual(fetched.longitude, 116.4074, accuracy: 0.0001)
        XCTAssertEqual(fetched.radiusMeters, 250)
    }

    func testUpdateHomeLocation_changesArePersisted() throws {
        let location = HomeLocation(latitude: 39.9042, longitude: 116.4074)
        context.insert(location)
        try context.save()

        location.latitude = 31.2304
        location.longitude = 121.4737
        location.radiusMeters = 300
        try context.save()

        let descriptor = FetchDescriptor<HomeLocation>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        let fetched = try XCTUnwrap(results.first)
        XCTAssertEqual(fetched.latitude, 31.2304, accuracy: 0.0001)
        XCTAssertEqual(fetched.longitude, 121.4737, accuracy: 0.0001)
        XCTAssertEqual(fetched.radiusMeters, 300)
    }

    // MARK: - Delete Operations

    func testDeleteCatProfile_removesFromStore() throws {
        let cat = CatProfile(name: "Mimi")
        context.insert(cat)
        try context.save()

        context.delete(cat)
        try context.save()

        let descriptor = FetchDescriptor<CatProfile>()
        let results = try context.fetch(descriptor)
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Combined Onboarding Flow

    func testFullOnboardingFlow_allDataPersists() throws {
        let cat1 = CatProfile(name: "Mimi")
        let cat2 = CatProfile(name: "Doudou")
        context.insert(cat1)
        context.insert(cat2)

        let location = HomeLocation(latitude: 39.9042, longitude: 116.4074, radiusMeters: 200)
        context.insert(location)

        try context.save()

        let catDescriptor = FetchDescriptor<CatProfile>()
        let cats = try context.fetch(catDescriptor)
        XCTAssertEqual(cats.count, 2)

        let locationDescriptor = FetchDescriptor<HomeLocation>()
        let locations = try context.fetch(locationDescriptor)
        XCTAssertEqual(locations.count, 1)
    }
}
