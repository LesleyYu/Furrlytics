import Foundation
import SwiftData

// MARK: - Event Type

enum EventType: String, Codable, CaseIterable {
    case feeding
    case treat
    case play
    case training
    case away
    case outing
    case deworming
}

// MARK: - Data Source

enum DataSource: String, Codable, CaseIterable {
    case manual
    case petlibro
    case location
}

// MARK: - CareEvent Model

@Model
class CareEvent {
    var id: UUID
    var timestamp: Date
    var eventType: EventType
    var source: DataSource
    var catId: UUID?
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        eventType: EventType,
        source: DataSource = .manual,
        catId: UUID? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.source = source
        self.catId = catId
        self.metadata = metadata
    }
}

// MARK: - Metadata Keys

enum FeedingMetadataKey {
    static let foodType = "foodType"
    static let foodName = "foodName"
    static let grams = "grams"
    static let petlibroRecordId = "petlibroRecordId"
}

enum TreatMetadataKey {
    static let treatName = "treatName"
    static let photoPath = "photoPath"
    static let productLink = "productLink"
}

enum PlayMetadataKey {
    static let durationMinutes = "durationMinutes"
}

enum TrainingMetadataKey {
    static let milestoneName = "milestoneName"
    static let photoPath = "photoPath"
    static let videoAssetId = "videoAssetId"
}

enum AwayMetadataKey {
    static let durationMinutes = "durationMinutes"
    static let isLongTrip = "isLongTrip"
}

enum OutingMetadataKey {
    static let durationMinutes = "durationMinutes"
    static let catBroughtAlong = "catBroughtAlong"
}

enum DewormingMetadataKey {
    static let drugName = "drugName"
    static let drugType = "drugType"
}
