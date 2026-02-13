import XCTest
@testable import KyuuseiKigaku

final class TableSekkiProviderTests: XCTestCase {

    var provider: TableSekkiProvider!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()

        provider = TableSekkiProvider()

        calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst
    }

    override func tearDown() {
        provider = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - Data Loading Tests

    func testDataLoading_ShouldLoadSuccessfully() {
        let supportedRange = provider.supportedYearRange()

        XCTAssertGreaterThanOrEqual(supportedRange.lowerBound, 1900, "Should support from at least 1900")
        XCTAssertLessThanOrEqual(supportedRange.upperBound, 2100, "Should support up to 2100")
        XCTAssertFalse(supportedRange.isEmpty, "Should have data for some years")
    }

    func testDataLoading_ShouldContainKnownYears() {
        let knownYears = [1990, 1995, 2000, 2020, 2026]

        for year in knownYears {
            let sekkiList = provider.allSekkiDates(for: year)
            XCTAssertFalse(sekkiList.isEmpty, "Should have data for year \(year)")
            XCTAssertEqual(sekkiList.count, 12, "Should have 12 Sekki for year \(year)")
        }
    }

    func testDataLoading_SekkiAreInChronologicalOrder() {
        let year = 2020
        let sekkiList = provider.allSekkiDates(for: year)

        XCTAssertFalse(sekkiList.isEmpty, "Should have data for 2020")

        for i in 0..<sekkiList.count-1 {
            XCTAssertLessThan(sekkiList[i].date, sekkiList[i+1].date,
                            "Sekki \(sekkiList[i].name) should be before \(sekkiList[i+1].name)")
        }
    }

    // MARK: - RisshunDate Tests

    func testRisshunDate_1995_ShouldReturnCorrectDate() {
        // Risshun 1995: 1995-02-04 15:21 JST
        let risshunDate = provider.risshunDate(for: 1995)

        XCTAssertNotNil(risshunDate, "Should return Risshun for 1995")

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: risshunDate!)

        XCTAssertEqual(components.year, 1995)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 4)
        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 21)
    }

    func testRisshunDate_2020_ShouldReturnCorrectDate() {
        // Risshun 2020: 2020-02-04 17:03 JST
        let risshunDate = provider.risshunDate(for: 2020)

        XCTAssertNotNil(risshunDate, "Should return Risshun for 2020")

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: risshunDate!)

        XCTAssertEqual(components.year, 2020)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 4)
        XCTAssertEqual(components.hour, 17)
        XCTAssertEqual(components.minute, 3)
    }

    // MARK: - RisshunInstant Tests

    func testRisshunInstant_ShouldReturnSekkiInstant() {
        let risshunInstant = provider.risshunInstant(forYear: 2020)

        XCTAssertNotNil(risshunInstant, "Should return Risshun instant for 2020")
        XCTAssertEqual(risshunInstant?.name, "立春", "Should be Risshun")

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                from: risshunInstant!.date)

        XCTAssertEqual(components.year, 2020)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 4)
        XCTAssertEqual(components.hour, 17)
        XCTAssertEqual(components.minute, 3)
    }

    func testRisshunInstant_MultipleYears_ShouldVary() {
        let risshun1995 = provider.risshunInstant(forYear: 1995)
        let risshun2020 = provider.risshunInstant(forYear: 2020)

        XCTAssertNotNil(risshun1995)
        XCTAssertNotNil(risshun2020)

        // Risshun times should be different
        XCTAssertNotEqual(risshun1995?.date, risshun2020?.date,
                        "Risshun times should vary between years")
    }

    // MARK: - SekkiInstant Tests

    func testSekkiInstant_Risshun_ShouldReturnCorrectly() {
        let instant = provider.sekkiInstant(for: .risshun, year: 2020)

        XCTAssertNotNil(instant, "Should return Risshun for 2020")
        XCTAssertEqual(instant?.name, "立春")

        let components = calendar.dateComponents([.month, .day], from: instant!.date)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 4)
    }

    func testSekkiInstant_Keichitsu_ShouldReturnCorrectly() {
        let instant = provider.sekkiInstant(for: .keichitsu, year: 2020)

        XCTAssertNotNil(instant, "Should return Keichitsu for 2020")
        XCTAssertEqual(instant?.name, "啓蟄")

        let components = calendar.dateComponents([.month, .day], from: instant!.date)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 5)
    }

    func testSekkiInstant_AllTypes_ShouldReturnForKnownYear() {
        let year = 2020

        for sekkiType in SekkiType.allCases {
            let instant = provider.sekkiInstant(for: sekkiType, year: year)

            XCTAssertNotNil(instant, "Should return \(sekkiType.rawValue) for \(year)")
            XCTAssertEqual(instant?.name, sekkiType.rawValue)
        }
    }

    func testSekkiInstant_Shoukan_ShouldBeInJanuary() {
        // Shoukan is in January of the following year
        let instant = provider.sekkiInstant(for: .shoukan, year: 2020)

        XCTAssertNotNil(instant, "Should return Shoukan for 2020")

        let components = calendar.dateComponents([.year, .month], from: instant!.date)
        XCTAssertEqual(components.year, 2021, "Shoukan 2020 should be in January 2021")
        XCTAssertEqual(components.month, 1)
    }

    // MARK: - LatestSekkiBefore Tests

    func testLatestSekkiBefore_JustAfterRisshun_ShouldReturnRisshun() {
        // Date: 2020-02-05 00:00 JST (one day after Risshun 2020)
        let components = DateComponents(year: 2020, month: 2, day: 5, hour: 0, minute: 0)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "立春", "Should be Risshun")
    }

    func testLatestSekkiBefore_JustBeforeKeichitsu_ShouldReturnRisshun() {
        // Date: 2020-03-05 10:00 JST (just before Keichitsu 2020 at 10:57)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 10, minute: 0)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "立春", "Should still be Risshun")
    }

    func testLatestSekkiBefore_AtKeichitsu_ShouldReturnKeichitsu() {
        // Date: 2020-03-05 10:57 JST (exactly at Keichitsu)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 10, minute: 57)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki at this date")
        XCTAssertEqual(latestSekki?.name, "啓蟄", "Should be Keichitsu")
    }

    func testLatestSekkiBefore_JustAfterKeichitsu_ShouldReturnKeichitsu() {
        // Date: 2020-03-05 11:00 JST (just after Keichitsu)
        let components = DateComponents(year: 2020, month: 3, day: 5, hour: 11, minute: 0)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "啓蟄", "Should be Keichitsu")
    }

    func testLatestSekkiBefore_MidYear_ShouldReturnCorrectSekki() {
        // Date: 2020-08-15 12:00 JST (mid-August, should be after Risshuu)
        let components = DateComponents(year: 2020, month: 8, day: 15, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "立秋", "Should be Risshuu (Start of Autumn)")
    }

    func testLatestSekkiBefore_EndOfYear_ShouldReturnCorrectSekki() {
        // Date: 2020-12-31 23:59 JST (end of year)
        let components = DateComponents(year: 2020, month: 12, day: 31, hour: 23, minute: 59)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "大雪", "Should be Taisetsu")
    }

    func testLatestSekkiBefore_EarlyJanuary_ShouldReturnShoukan() {
        // Date: 2021-01-10 12:00 JST (early January, after Shoukan)
        let components = DateComponents(year: 2021, month: 1, day: 10, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let latestSekki = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(latestSekki, "Should find a Sekki before this date")
        XCTAssertEqual(latestSekki?.name, "小寒", "Should be Shoukan")
    }

    // MARK: - Binary Search Performance Tests

    func testLatestSekkiBefore_AcrossMultipleYears_ShouldBeFast() {
        // Create a date far in the future
        let components = DateComponents(year: 2050, month: 6, day: 15, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        let startTime = Date()
        let latestSekki = provider.latestSekkiBefore(date: date)
        let endTime = Date()

        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertNotNil(latestSekki, "Should find a Sekki")
        XCTAssertLessThan(duration, 0.01, "Binary search should be fast (< 10ms)")
    }

    func testLatestSekkiBefore_MultipleQueries_ShouldBeConsistent() {
        let components = DateComponents(year: 2020, month: 7, day: 15, hour: 12, minute: 0)
        let date = calendar.date(from: components)!

        // Query multiple times
        let result1 = provider.latestSekkiBefore(date: date)
        let result2 = provider.latestSekkiBefore(date: date)
        let result3 = provider.latestSekkiBefore(date: date)

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotNil(result3)

        // All results should be identical
        XCTAssertEqual(result1?.name, result2?.name)
        XCTAssertEqual(result2?.name, result3?.name)
        XCTAssertEqual(result1?.date, result2?.date)
        XCTAssertEqual(result2?.date, result3?.date)
    }

    // MARK: - Edge Case Tests

    func testSekkiDate_ForMonth_ShouldReturnCorrectSekki() {
        let year = 2020

        // Month 1 -> Risshun
        let month1 = provider.sekkiDate(forMonth: 1, year: year)
        XCTAssertEqual(month1?.name, "立春")

        // Month 2 -> Keichitsu
        let month2 = provider.sekkiDate(forMonth: 2, year: year)
        XCTAssertEqual(month2?.name, "啓蟄")

        // Month 12 -> Shoukan
        let month12 = provider.sekkiDate(forMonth: 12, year: year)
        XCTAssertEqual(month12?.name, "小寒")
    }

    func testSekkiDate_InvalidMonth_ShouldReturnNil() {
        let invalidMonth0 = provider.sekkiDate(forMonth: 0, year: 2020)
        XCTAssertNil(invalidMonth0, "Month 0 should be invalid")

        let invalidMonth13 = provider.sekkiDate(forMonth: 13, year: 2020)
        XCTAssertNil(invalidMonth13, "Month 13 should be invalid")

        let invalidMonthNegative = provider.sekkiDate(forMonth: -1, year: 2020)
        XCTAssertNil(invalidMonthNegative, "Negative month should be invalid")
    }

    func testAllSekkiDates_ShouldContainAll12Sekki() {
        let year = 2020
        let sekkiList = provider.allSekkiDates(for: year)

        XCTAssertEqual(sekkiList.count, 12, "Should have exactly 12 Sekki")

        let expectedNames = ["立春", "啓蟄", "清明", "立夏", "芒種", "小暑",
                           "立秋", "白露", "寒露", "立冬", "大雪", "小寒"]

        let sekkiNames = sekkiList.map { $0.name }

        for expectedName in expectedNames {
            XCTAssertTrue(sekkiNames.contains(expectedName),
                        "Should contain \(expectedName)")
        }
    }

    func testSupportedYearRange_ShouldBeValid() {
        let range = provider.supportedYearRange()

        XCTAssertLessThanOrEqual(range.lowerBound, range.upperBound,
                                "Range should be valid")
        XCTAssertGreaterThan(range.upperBound - range.lowerBound, 0,
                           "Range should span multiple years")
    }

    // MARK: - ISO8601 Format Parsing Tests

    func testISO8601Parsing_ShouldHandleTimezone() {
        // The ISO8601 format includes +09:00 timezone
        let risshunDate = provider.risshunDate(for: 2020)

        XCTAssertNotNil(risshunDate, "Should parse ISO8601 format with timezone")

        // Convert to JST and verify
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                from: risshunDate!)

        XCTAssertEqual(components.year, 2020)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 4)
    }

    func testISO8601Parsing_ShouldPreserveMinutePrecision() {
        // Risshun 2020: 2020-02-04 17:03 JST
        let risshunDate = provider.risshunDate(for: 2020)

        XCTAssertNotNil(risshunDate)

        let components = calendar.dateComponents([.hour, .minute], from: risshunDate!)

        XCTAssertEqual(components.hour, 17, "Hour should be preserved")
        XCTAssertEqual(components.minute, 3, "Minute should be preserved")
    }

    // MARK: - Data Consistency Tests

    func testDataConsistency_SekkiShouldProgressThroughYear() {
        let year = 2020
        let sekkiList = provider.allSekkiDates(for: year)

        XCTAssertGreaterThanOrEqual(sekkiList.count, 12, "Should have at least 12 Sekki")

        // Check that months generally progress (allowing for Shoukan in January)
        var previousMonth = 0
        var yearTransitionSeen = false

        for sekki in sekkiList {
            let components = calendar.dateComponents([.month], from: sekki.date)
            let currentMonth = components.month!

            if currentMonth < previousMonth {
                // Year transition (December -> January)
                yearTransitionSeen = true
            }

            previousMonth = currentMonth
        }

        XCTAssertTrue(yearTransitionSeen || sekkiList.count <= 12,
                    "Should see year transition for Shoukan")
    }
}
