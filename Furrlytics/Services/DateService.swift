import Foundation

enum DateService {

    // MARK: - Day Boundary

    static let dayBoundaryHour = 4

    /// Returns the logical date for a given timestamp using the 4 AM day boundary.
    ///
    /// Events occurring before 4 AM are grouped with the previous calendar day.
    /// The returned date has its time components zeroed out — it represents the logical day only.
    static func calculateLogicalDate(from timestamp: Date) -> Date {
        let calendar = Calendar.current
        let shifted = calendar.date(byAdding: .hour, value: -dayBoundaryHour, to: timestamp)!
        return calendar.startOfDay(for: shifted)
    }

    /// Returns the start of the logical day (4 AM) for the given logical date.
    static func logicalDayStart(for logicalDate: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: dayBoundaryHour, to: calendar.startOfDay(for: logicalDate))!
    }

    /// Returns the end of the logical day (next day at 4 AM) for the given logical date.
    static func logicalDayEnd(for logicalDate: Date) -> Date {
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: logicalDate)!
        return calendar.date(byAdding: .hour, value: dayBoundaryHour, to: calendar.startOfDay(for: nextDay))!
    }
}
