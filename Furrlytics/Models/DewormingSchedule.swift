import Foundation
import SwiftData

@Model
class DewormingSchedule {
    var id: UUID
    var drugName: String
    var drugType: String
    var intervalDays: Int
    var lastRecordedDate: Date?

    init(
        id: UUID = UUID(),
        drugName: String,
        drugType: String,
        intervalDays: Int,
        lastRecordedDate: Date? = nil
    ) {
        self.id = id
        self.drugName = drugName
        self.drugType = drugType
        self.intervalDays = intervalDays
        self.lastRecordedDate = lastRecordedDate
    }
}
