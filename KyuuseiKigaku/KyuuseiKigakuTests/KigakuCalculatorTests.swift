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
}
