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

        let birthDate = calendar.date(from: components)!
        let result = KigakuCalculator.calculate(birthDate: birthDate)

        let rawValue = 11 - (1995 % 9)
        let expectedHonmei = (rawValue == 0) ? 9 : ((rawValue == 10) ? 1 : rawValue)
        XCTAssertEqual(result.honmeiNum, expectedHonmei, "Feb 4 should use current year (Risshun day)")
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
