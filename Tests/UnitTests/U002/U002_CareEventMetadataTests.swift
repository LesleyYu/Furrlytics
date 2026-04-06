import XCTest
@testable import Furrlytics

final class U002_CareEventMetadataTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCareEvent_defaultInitialization_hasExpectedDefaults() {
        let event = CareEvent(eventType: .feeding)

        XCTAssertNotNil(event.id)
        XCTAssertEqual(event.eventType, .feeding)
        XCTAssertEqual(event.source, .manual)
        XCTAssertNil(event.catId)
        XCTAssertTrue(event.metadata.isEmpty)
    }

    func testCareEvent_fullInitialization_storesAllProperties() {
        let catId = UUID()
        let metadata = [FeedingMetadataKey.foodType: "wet", FeedingMetadataKey.grams: "100"]

        let event = CareEvent(
            eventType: .feeding,
            source: .petlibro,
            catId: catId,
            metadata: metadata
        )

        XCTAssertEqual(event.eventType, .feeding)
        XCTAssertEqual(event.source, .petlibro)
        XCTAssertEqual(event.catId, catId)
        XCTAssertEqual(event.metadata[FeedingMetadataKey.foodType], "wet")
        XCTAssertEqual(event.metadata[FeedingMetadataKey.grams], "100")
    }

    // MARK: - Feeding Metadata

    func testFeedingMetadataKeys_areCorrectStrings() {
        XCTAssertEqual(FeedingMetadataKey.foodType, "foodType")
        XCTAssertEqual(FeedingMetadataKey.foodName, "foodName")
        XCTAssertEqual(FeedingMetadataKey.grams, "grams")
        XCTAssertEqual(FeedingMetadataKey.petlibroRecordId, "petlibroRecordId")
    }

    // MARK: - Play Metadata

    func testPlayMetadataKey_isCorrectString() {
        XCTAssertEqual(PlayMetadataKey.durationMinutes, "durationMinutes")
    }

    // MARK: - Away Metadata

    func testAwayMetadataKeys_areCorrectStrings() {
        XCTAssertEqual(AwayMetadataKey.durationMinutes, "durationMinutes")
        XCTAssertEqual(AwayMetadataKey.isLongTrip, "isLongTrip")
    }

    // MARK: - Outing Metadata

    func testOutingMetadataKeys_areCorrectStrings() {
        XCTAssertEqual(OutingMetadataKey.durationMinutes, "durationMinutes")
        XCTAssertEqual(OutingMetadataKey.catBroughtAlong, "catBroughtAlong")
    }

    // MARK: - Deworming Metadata

    func testDewormingMetadataKeys_areCorrectStrings() {
        XCTAssertEqual(DewormingMetadataKey.drugName, "drugName")
        XCTAssertEqual(DewormingMetadataKey.drugType, "drugType")
    }

    // MARK: - EventType Enum

    func testEventType_allCasesExist() {
        let allCases: [EventType] = [.feeding, .treat, .play, .training, .away, .outing, .deworming]
        XCTAssertEqual(EventType.allCases.count, allCases.count)
    }

    func testEventType_rawValues_areCorrectStrings() {
        XCTAssertEqual(EventType.feeding.rawValue, "feeding")
        XCTAssertEqual(EventType.treat.rawValue, "treat")
        XCTAssertEqual(EventType.play.rawValue, "play")
        XCTAssertEqual(EventType.training.rawValue, "training")
        XCTAssertEqual(EventType.away.rawValue, "away")
        XCTAssertEqual(EventType.outing.rawValue, "outing")
        XCTAssertEqual(EventType.deworming.rawValue, "deworming")
    }

    // MARK: - DataSource Enum

    func testDataSource_rawValues_areCorrectStrings() {
        XCTAssertEqual(DataSource.manual.rawValue, "manual")
        XCTAssertEqual(DataSource.petlibro.rawValue, "petlibro")
        XCTAssertEqual(DataSource.location.rawValue, "location")
    }
}
