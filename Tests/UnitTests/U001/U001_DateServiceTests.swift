import XCTest
@testable import Furrlytics

final class U001_DateServiceTests: XCTestCase {

    // MARK: - 4 AM Boundary Tests

    func testCalculateLogicalDate_beforeDayBoundary_returnsPreviousDay() {
        let earlyMorning = makeDate(year: 2026, month: 4, day: 3, hour: 1, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: earlyMorning)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 2)
    }

    func testCalculateLogicalDate_afterDayBoundary_returnsSameDay() {
        let morning = makeDate(year: 2026, month: 4, day: 3, hour: 8, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: morning)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 3)
    }

    func testCalculateLogicalDate_exactlyAtBoundary_returnsSameDay() {
        let exactBoundary = makeDate(year: 2026, month: 4, day: 3, hour: 4, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: exactBoundary)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 3)
    }

    func testCalculateLogicalDate_justBeforeBoundary_returnsPreviousDay() {
        let justBefore = makeDate(year: 2026, month: 4, day: 3, hour: 3, minute: 59)
        let logicalDate = DateService.calculateLogicalDate(from: justBefore)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 2)
    }

    func testCalculateLogicalDate_midnight_returnsPreviousDay() {
        let midnight = makeDate(year: 2026, month: 4, day: 3, hour: 0, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: midnight)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 2)
    }

    func testCalculateLogicalDate_crossMonthBoundary_returnsPreviousMonth() {
        let earlyMay1 = makeDate(year: 2026, month: 5, day: 1, hour: 2, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: earlyMay1)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 30)
    }

    func testCalculateLogicalDate_crossYearBoundary_returnsPreviousYear() {
        let earlyJan1 = makeDate(year: 2027, month: 1, day: 1, hour: 1, minute: 0)
        let logicalDate = DateService.calculateLogicalDate(from: earlyJan1)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logicalDate)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 31)
    }

    // MARK: - Logical Day Range Tests

    func testLogicalDayStart_returnsCorrect4AMTime() {
        let logicalDate = makeDate(year: 2026, month: 4, day: 3, hour: 0, minute: 0)
        let dayStart = DateService.logicalDayStart(for: logicalDate)

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dayStart)
        XCTAssertEqual(components.hour, 4)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.day, 3)
    }

    func testLogicalDayEnd_returnsNext4AM() {
        let logicalDate = makeDate(year: 2026, month: 4, day: 3, hour: 0, minute: 0)
        let dayEnd = DateService.logicalDayEnd(for: logicalDate)

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dayEnd)
        XCTAssertEqual(components.hour, 4)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.day, 4)
    }

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
}
