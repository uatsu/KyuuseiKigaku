import XCTest
@testable import KyuuseiKigaku

final class KigakuCalculatorTests: XCTestCase {

    func testHonmeiCalculation_For1990() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1990
        components.month = 5
        components.day = 15

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1990 % 9)
        let expectedHonmei = (rawValue == 10) ? 1 : (rawValue == 0 ? 9 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Honmei calculation for 1990 should be correct (1900-1999 formula)")
    }

    func testHonmeiCalculation_For2000() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000
        components.month = 6
        components.day = 20

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 9 - (2000 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Honmei calculation for 2000 should be correct (2000-2099 formula)")
    }

    func testYearAdjustment_BeforeRisshun() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1990
        components.month = 1
        components.day = 15

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1989 % 9)
        let expectedHonmei = (rawValue == 11) ? 2 : ((rawValue == 0) ? 9 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Year should be adjusted for dates before Risshun")
    }

    func testYearAdjustment_AfterRisshun() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1990
        components.month = 2
        components.day = 10

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1990 % 9)
        let expectedHonmei = (rawValue == 10) ? 1 : (rawValue == 0 ? 9 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Year should not be adjusted for dates after Risshun")
    }

    func testRisshunBoundary_Feb3() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 3

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1994 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Feb 3 should use previous year (before Risshun)")
    }

    func testRisshunBoundary_Feb4() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 16

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1995 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Feb 4 16:00 should use current year (after Risshun at 15:21)")
    }

    func testRisshunBoundary_OneMinuteBefore_1995() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 15
        components.minute = 20

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1994 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "1995-02-04 15:20 JST (1 min before Risshun) should use previous year")
    }

    func testRisshunBoundary_OneMinuteAfter_1995() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 15
        components.minute = 22

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1995 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "1995-02-04 15:22 JST (1 min after Risshun) should use current year")
    }

    func testRisshunBoundary_OneMinuteBefore_2020() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 2020
        components.month = 2
        components.day = 4
        components.hour = 17
        components.minute = 2

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 9 - (2019 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "2020-02-04 17:02 JST (1 min before Risshun) should use previous year")
    }

    func testRisshunBoundary_OneMinuteAfter_2020() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 2020
        components.month = 2
        components.day = 4
        components.hour = 17
        components.minute = 4

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 9 - (2020 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "2020-02-04 17:04 JST (1 min after Risshun) should use current year")
    }

    func testGetsumeiCalculation() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1990
        components.month = 5
        components.day = 15

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        XCTAssertGreaterThan(result.getsumeiNum, 0, "Getsumei should be greater than 0")
        XCTAssertLessThanOrEqual(result.getsumeiNum, 9, "Getsumei should be less than or equal to 9")
    }

    func testResultStructure() throws {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1995
        components.month = 8
        components.day = 25

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        XCTAssertGreaterThan(result.honmeiNum, 0)
        XCTAssertLessThanOrEqual(result.honmeiNum, 9)
        XCTAssertFalse(result.honmeiName.isEmpty)
        XCTAssertGreaterThan(result.getsumeiNum, 0)
        XCTAssertLessThanOrEqual(result.getsumeiNum, 9)
        XCTAssertFalse(result.getsumeiName.isEmpty)
    }

    func testDailyStar_ReferenceDate() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 0
        components.minute = 0

        let referenceDate = calendar.date(from: components)!
        let dailyStar = KigakuCalculator.calculateDailyStar(for: referenceDate)

        XCTAssertEqual(dailyStar, 9, "Reference date (1995-02-04 00:00 JST / Risshun 1995) should be Star 9")
    }

    func testDailyStar_CyclicContinuity() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1

        let testCases: [(day: Int, expectedStar: Int)] = [
            (1, 8),
            (2, 7),
            (3, 6),
            (4, 5),
            (5, 4),
            (6, 3),
            (7, 2),
            (8, 1),
            (9, 9),
            (10, 8),
            (11, 7),
            (18, 9),
            (19, 8)
        ]

        for testCase in testCases {
            components.day = testCase.day
            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "Day \(testCase.day) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_MultipleCycles() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 2000
        components.month = 1

        let testCases: [(day: Int, expectedStar: Int)] = [
            (1, 8),
            (10, 8),
            (19, 8),
            (28, 8),
            (9, 9),
            (18, 9),
            (27, 9),
            (5, 4),
            (14, 4),
            (23, 4)
        ]

        for testCase in testCases {
            components.day = testCase.day
            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "Jan \(testCase.day) should be Star \(testCase.expectedStar)")
        }
    }

    func testDailyStar_DifferentYears() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.month = 3
        components.day = 15
        components.hour = 12
        components.minute = 0

        let testCases: [(year: Int, expectedStar: Int)] = [
            (2000, 6),
            (2001, 1),
            (2020, 9),
            (2025, 1)
        ]

        for testCase in testCases {
            components.year = testCase.year
            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "March 15, \(testCase.year) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_BeforeReferenceDate() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1999
        components.month = 12
        components.day = 31

        let date = calendar.date(from: components)!
        let dailyStar = KigakuCalculator.calculateDailyStar(for: date)

        XCTAssertEqual(dailyStar, 9, "1999-12-31 should be Star 9")

        components.year = 1999
        components.month = 12
        components.day = 30
        let date2 = calendar.date(from: components)!
        let dailyStar2 = KigakuCalculator.calculateDailyStar(for: date2)

        XCTAssertEqual(dailyStar2, 1, "1999-12-30 should be Star 1")
    }

    func testDailyStar_TimeOfDayDoesNotMatter() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 5

        let timesOfDay: [(hour: Int, minute: Int)] = [
            (0, 0),
            (6, 30),
            (12, 0),
            (18, 45),
            (23, 59)
        ]

        for time in timesOfDay {
            components.hour = time.hour
            components.minute = time.minute
            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
            XCTAssertEqual(dailyStar, 4,
                         "Jan 5 at \(time.hour):\(time.minute) should be Star 4 (time should not affect result)")
        }
    }

    func testDailyStar_ResultAlwaysInRange() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.hour = 12

        for year in 1990...2030 {
            for month in 1...12 {
                for day in 1...28 {
                    components.year = year
                    components.month = month
                    components.day = day

                    if let date = calendar.date(from: components) {
                        let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
                        XCTAssertGreaterThanOrEqual(dailyStar, 1,
                                                  "\(year)-\(month)-\(day): Daily star must be >= 1")
                        XCTAssertLessThanOrEqual(dailyStar, 9,
                                               "\(year)-\(month)-\(day): Daily star must be <= 9")
                    }
                }
            }
        }
    }

    func testDailyStar_KnownDates() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        let testCases: [(year: Int, month: Int, day: Int, expectedStar: Int, description: String)] = [
            (2000, 1, 1, 8, "2000-01-01"),
            (2000, 1, 10, 8, "2000-01-10 (9 days after 2000-01-01)"),
            (2000, 2, 1, 4, "2000-02-01"),
            (2020, 2, 4, 4, "Risshun 2020"),
            (1995, 2, 4, 9, "Risshun 1995 (Reference Date)")
        ]

        for testCase in testCases {
            var components = DateComponents()
            components.year = testCase.year
            components.month = testCase.month
            components.day = testCase.day
            components.hour = 12

            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "\(testCase.description) (\(testCase.year)-\(testCase.month)-\(testCase.day)) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_BeforeReferenceDate_December1999() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        let testCases: [(day: Int, expectedStar: Int)] = [
            (25, 6),
            (26, 5),
            (27, 4),
            (28, 3),
            (29, 2),
            (30, 1),
            (31, 9)
        ]

        for testCase in testCases {
            var components = DateComponents()
            components.year = 1999
            components.month = 12
            components.day = testCase.day
            components.hour = 12

            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)

            XCTAssertGreaterThanOrEqual(dailyStar, 1,
                                      "1999-12-\(testCase.day): Daily star must be >= 1, got \(dailyStar)")
            XCTAssertLessThanOrEqual(dailyStar, 9,
                                   "1999-12-\(testCase.day): Daily star must be <= 9, got \(dailyStar)")
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "1999-12-\(testCase.day) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_PatternContinuity() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 12

        let referenceDate = calendar.date(from: components)!
        let previousStar = KigakuCalculator.calculateDailyStar(for: referenceDate)

        XCTAssertEqual(previousStar, 9, "Reference should be Star 9")

        for dayOffset in 1...27 {
            guard let testDate = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) else {
                XCTFail("Could not create date for offset \(dayOffset)")
                continue
            }

            let currentStar = KigakuCalculator.calculateDailyStar(for: testDate)
            XCTAssertGreaterThanOrEqual(currentStar, 1, "Star must be >= 1")
            XCTAssertLessThanOrEqual(currentStar, 9, "Star must be <= 9")

            let expectedPattern = [8, 7, 6, 5, 4, 3, 2, 1, 9, 8, 7, 6, 5, 4, 3, 2, 1, 9, 8, 7, 6, 5, 4, 3, 2, 1, 9]
            XCTAssertEqual(currentStar, expectedPattern[dayOffset - 1],
                         "Day +\(dayOffset) should be Star \(expectedPattern[dayOffset - 1])")
        }
    }

    func testDailyStar_NegativeDayOffsets() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        var components = DateComponents()
        components.year = 1995
        components.month = 2
        components.day = 4
        components.hour = 12

        let referenceDate = calendar.date(from: components)!

        let testCases: [(offset: Int, expectedStar: Int)] = [
            (-1, 1),
            (-2, 2),
            (-3, 3),
            (-8, 8),
            (-9, 9),
            (-10, 1),
            (-18, 9)
        ]

        for testCase in testCases {
            guard let testDate = calendar.date(byAdding: .day, value: testCase.offset, to: referenceDate) else {
                XCTFail("Could not create date for offset \(testCase.offset)")
                continue
            }

            let dailyStar = KigakuCalculator.calculateDailyStar(for: testDate)
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "Day \(testCase.offset) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_VeryDistantDates() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        let testCases: [(year: Int, month: Int, day: Int, expectedStar: Int, description: String)] = [
            (1900, 2, 5, 1, "Start of 20th century (1900-02-05)"),
            (2099, 12, 31, 9, "End of 21st century (2099-12-31)"),
            (1950, 6, 15, 5, "Mid-20th century (1950-06-15)"),
            (2050, 6, 15, 1, "Mid-21st century (2050-06-15)")
        ]

        for testCase in testCases {
            var components = DateComponents()
            components.year = testCase.year
            components.month = testCase.month
            components.day = testCase.day
            components.hour = 12

            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)

            XCTAssertGreaterThanOrEqual(dailyStar, 1,
                                      "\(testCase.description): Must be >= 1")
            XCTAssertLessThanOrEqual(dailyStar, 9,
                                   "\(testCase.description): Must be <= 9")
            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "\(testCase.description) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }

    func testDailyStar_LeapYearBoundaries() throws {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            XCTFail("Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        let testCases: [(year: Int, month: Int, day: Int, expectedStar: Int)] = [
            (2000, 2, 28, 1),
            (2000, 2, 29, 9),
            (2000, 3, 1, 8),
            (2004, 2, 28, 8),
            (2004, 2, 29, 7),
            (2004, 3, 1, 6)
        ]

        for testCase in testCases {
            var components = DateComponents()
            components.year = testCase.year
            components.month = testCase.month
            components.day = testCase.day
            components.hour = 12

            let date = calendar.date(from: components)!
            let dailyStar = KigakuCalculator.calculateDailyStar(for: date)

            XCTAssertEqual(dailyStar, testCase.expectedStar,
                         "\(testCase.year)-\(testCase.month)-\(testCase.day) should be Star \(testCase.expectedStar), got \(dailyStar)")
        }
    }
}
