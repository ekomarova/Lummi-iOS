import Testing
import Foundation
@testable import Lummi

struct DeviceClockCheckTests {

    @Test func implausible_beforeEarliestSupportedDate() {
        let year1990 = Date(timeIntervalSince1970: 631_152_000)
        #expect(!DeviceClockCheck.isPlausible(now: year1990))
    }

    @Test func plausible_atEarliestSupportedDate() {
        #expect(DeviceClockCheck.isPlausible(now: DeviceClockCheck.earliestSupportedDate))
    }

    @Test func earliestSupportedDate_isGregorianJanuary2026_regardlessOfRegionCalendar() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = .current
        let components = gregorian.dateComponents([.year, .month, .day, .hour], from: DeviceClockCheck.earliestSupportedDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
        #expect(components.hour == 0)
    }

    @Test func plausible_afterEarliestSupportedDate() {
        #expect(DeviceClockCheck.isPlausible(now: Date(timeIntervalSince1970: 1_790_000_000)))
    }
}
