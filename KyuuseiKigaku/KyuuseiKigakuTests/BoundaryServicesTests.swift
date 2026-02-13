import XCTest
@testable import KyuuseiKigaku

final class BoundaryServicesTests: XCTestCase {

    var sekkiProvider: SekkiProvider!
    var yearBoundaryService: YearBoundaryService!
    var monthBoundaryService: MonthBoundaryService!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()

        sekkiProvider = TableSekkiProvider()
        yearBoundaryService = YearBoundaryService(sekkiProvider: sekkiProvider)
        monthBoundaryService = MonthBoundaryService(sekkiProvider: sekkiProvider)

        calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst
    }

    override func tearDown() {
        sekkiProvider = nil
        yearBoundaryService = nil
        monthBoundaryService = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - Year Boundary Tests (Risshun)

    func testYearBoundary_1995_OneMinuteBeforeRisshun() throws {
        // Risshun 1995: 1995-02-04 15:21 JST
        let components = DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 20)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 1994, "1 minute before Risshun 1995 should use year 1994")
        XCTAssertTrue(yearBoundaryService.isBeforeRisshun(date, inYear: 1995), "Should be before Risshun")
    }

    func testYearBoundary_1995_AtRisshun() throws {
        // Risshun 1995: 1995-02-04 15:21 JST
        let components = DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 21)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 1995, "At Risshun 1995 should use year 1995")
        XCTAssertFalse(yearBoundaryService.isBeforeRisshun(date, inYear: 1995), "Should not be before Risshun")
    }

    func testYearBoundary_1995_OneMinuteAfterRisshun() throws {
        // Risshun 1995: 1995-02-04 15:21 JST
        let components = DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 22)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 1995, "1 minute after Risshun 1995 should use year 1995")
        XCTAssertFalse(yearBoundaryService.isBeforeRisshun(date, inYear: 1995), "Should not be before Risshun")
    }

    func testYearBoundary_2020_OneMinuteBeforeRisshun() throws {
        // Risshun 2020: 2020-02-04 17:03 JST
        let components = DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 2)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 2019, "1 minute before Risshun 2020 should use year 2019")
        XCTAssertTrue(yearBoundaryService.isBeforeRisshun(date, inYear: 2020), "Should be before Risshun")
    }

    func testYearBoundary_2020_AtRisshun() throws {
        // Risshun 2020: 2020-02-04 17:03 JST
        let components = DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 3)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 2020, "At Risshun 2020 should use year 2020")
        XCTAssertFalse(yearBoundaryService.isBeforeRisshun(date, inYear: 2020), "Should not be before Risshun")
    }

    func testYearBoundary_2020_OneMinuteAfterRisshun() throws {
        // Risshun 2020: 2020-02-04 17:03 JST
        let components = DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 4)
        let date = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: date)

        XCTAssertEqual(kigakuYear, 2020, "1 minute after Risshun 2020 should use year 2020")
        XCTAssertFalse(yearBoundaryService.isBeforeRisshun(date, inYear: 2020), "Should not be before Risshun")
    }

    // MARK: - Month Boundary Tests (Sekki)

    func testMonthBoundary_Keichitsu2020_OneMinuteBefore() throws {
        // Keichitsu 2020: 2020-03-05 10:57 JST (Astrological Month 2)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 10, minute: 56)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 1, "1 minute before Keichitsu should be Month 1 (Risshun)")
    }

    func testMonthBoundary_Keichitsu2020_AtSekki() throws {
        // Keichitsu 2020: 2020-03-05 10:57 JST (Astrological Month 2)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 10, minute: 57)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 2, "At Keichitsu should be Month 2")
    }

    func testMonthBoundary_Keichitsu2020_OneMinuteAfter() throws {
        // Keichitsu 2020: 2020-03-05 10:57 JST (Astrological Month 2)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 10, minute: 58)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 2, "1 minute after Keichitsu should be Month 2")
    }

    func testMonthBoundary_Seimei2020_OneMinuteBefore() throws {
        // Seimei 2020: 2020-04-04 09:38 JST (Astrological Month 3)
        let components = DateComponents(year: 2020, month: 4, day: 4, hour: 9, minute: 37)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 2, "1 minute before Seimei should be Month 2 (Keichitsu)")
    }

    func testMonthBoundary_Seimei2020_AtSekki() throws {
        // Seimei 2020: 2020-04-04 09:38 JST (Astrological Month 3)
        let components = DateComponents(year: 2020, month: 4, day: 4, hour: 9, minute: 38)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 3, "At Seimei should be Month 3")
    }

    func testMonthBoundary_Seimei2020_OneMinuteAfter() throws {
        // Seimei 2020: 2020-04-04 09:38 JST (Astrological Month 3)
        let components = DateComponents(year: 2020, month: 4, day: 4, hour: 9, minute: 39)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 3, "1 minute after Seimei should be Month 3")
    }

    // MARK: - Integration Tests: Year + Month Combined

    func testFullCalculation_BeforeRisshun1995() throws {
        // Birth: 1995-02-03 12:00 JST (before Risshun 1995)
        let components = DateComponents(year: 1995, month: 2, day: 3, hour: 12, minute: 0)
        let birthDate = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: birthDate)
        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: birthDate)

        XCTAssertEqual(kigakuYear, 1994, "Should use Kigaku year 1994")
        XCTAssertEqual(astrologicalMonth, 12, "Should be astrological month 12 (Shoukan)")
    }

    func testFullCalculation_AfterRisshun1995() throws {
        // Birth: 1995-02-05 12:00 JST (after Risshun 1995)
        let components = DateComponents(year: 1995, month: 2, day: 5, hour: 12, minute: 0)
        let birthDate = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: birthDate)
        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: birthDate)

        XCTAssertEqual(kigakuYear, 1995, "Should use Kigaku year 1995")
        XCTAssertEqual(astrologicalMonth, 1, "Should be astrological month 1 (Risshun)")
    }

    func testFullCalculation_AfterKeichitsu2020() throws {
        // Birth: 2020-03-05 12:00 JST (after Keichitsu 2020)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 12, minute: 0)
        let birthDate = calendar.date(from: components)!

        let kigakuYear = yearBoundaryService.kigakuYear(for: birthDate)
        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: birthDate)

        XCTAssertEqual(kigakuYear, 2020, "Should use Kigaku year 2020")
        XCTAssertEqual(astrologicalMonth, 2, "Should be astrological month 2 (Keichitsu)")
    }

    // MARK: - Edge Cases

    func testEarlyJanuary_IsMonth12() throws {
        // 2020-01-05 12:00 JST (before Shoukan 2020 which is on Jan 6)
        let components = DateComponents(year: 2020, month: 1, day: 5, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        // Should be month 12 (Taisetsu) from previous astrological year
        XCTAssertEqual(astrologicalMonth, 12, "Early January before Shoukan should be Month 12")
    }

    func testShoukan_StartsMonth12() throws {
        // Shoukan 2020: 2020-01-06 06:28 JST (starts Astrological Month 12)
        let components = DateComponents(year: 2020, month: 1, day: 6, hour: 6, minute: 30)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 12, "After Shoukan should be Month 12")
    }

    func testLateJanuary_StillMonth12() throws {
        // 2020-01-31 12:00 JST (after Shoukan, before Risshun)
        let components = DateComponents(year: 2020, month: 1, day: 31, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 12, "Late January should still be Month 12")
    }

    func testEarlyFebruary_BeforeRisshun_IsMonth12() throws {
        // 2020-02-03 12:00 JST (before Risshun)
        let components = DateComponents(year: 2020, month: 2, day: 3, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 12, "Early February before Risshun should be Month 12")
    }

    func testEarlyFebruary_AfterRisshun_IsMonth1() throws {
        // 2020-02-05 12:00 JST (after Risshun)
        let components = DateComponents(year: 2020, month: 2, day: 5, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: date)

        XCTAssertEqual(astrologicalMonth, 1, "Early February after Risshun should be Month 1")
    }
}
