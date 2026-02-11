import Foundation

class RisshunProvider {
    private static let risshunTable: [Int: DateComponents] = [
        1985: DateComponents(year: 1985, month: 2, day: 4, hour: 5, minute: 13),
        1986: DateComponents(year: 1986, month: 2, day: 4, hour: 11, minute: 8),
        1987: DateComponents(year: 1987, month: 2, day: 4, hour: 16, minute: 52),
        1988: DateComponents(year: 1988, month: 2, day: 4, hour: 22, minute: 43),
        1989: DateComponents(year: 1989, month: 2, day: 4, hour: 4, minute: 27),
        1990: DateComponents(year: 1990, month: 2, day: 4, hour: 10, minute: 14),
        1991: DateComponents(year: 1991, month: 2, day: 4, hour: 16, minute: 8),
        1992: DateComponents(year: 1992, month: 2, day: 4, hour: 22, minute: 0),
        1993: DateComponents(year: 1993, month: 2, day: 4, hour: 3, minute: 48),
        1994: DateComponents(year: 1994, month: 2, day: 4, hour: 9, minute: 31),
        1995: DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 21),
        1996: DateComponents(year: 1996, month: 2, day: 4, hour: 21, minute: 8),
        1997: DateComponents(year: 1997, month: 2, day: 4, hour: 2, minute: 55),
        1998: DateComponents(year: 1998, month: 2, day: 4, hour: 8, minute: 39),
        1999: DateComponents(year: 1999, month: 2, day: 4, hour: 14, minute: 57),
        2000: DateComponents(year: 2000, month: 2, day: 4, hour: 20, minute: 40),
        2001: DateComponents(year: 2001, month: 2, day: 4, hour: 2, minute: 28),
        2002: DateComponents(year: 2002, month: 2, day: 4, hour: 8, minute: 24),
        2003: DateComponents(year: 2003, month: 2, day: 4, hour: 14, minute: 5),
        2004: DateComponents(year: 2004, month: 2, day: 4, hour: 19, minute: 56),
        2005: DateComponents(year: 2005, month: 2, day: 4, hour: 1, minute: 43),
        2006: DateComponents(year: 2006, month: 2, day: 4, hour: 7, minute: 27),
        2007: DateComponents(year: 2007, month: 2, day: 4, hour: 13, minute: 18),
        2008: DateComponents(year: 2008, month: 2, day: 4, hour: 19, minute: 0),
        2009: DateComponents(year: 2009, month: 2, day: 4, hour: 0, minute: 50),
        2010: DateComponents(year: 2010, month: 2, day: 4, hour: 6, minute: 47),
        2011: DateComponents(year: 2011, month: 2, day: 4, hour: 12, minute: 32),
        2012: DateComponents(year: 2012, month: 2, day: 4, hour: 18, minute: 22),
        2013: DateComponents(year: 2013, month: 2, day: 4, hour: 0, minute: 13),
        2014: DateComponents(year: 2014, month: 2, day: 4, hour: 6, minute: 3),
        2015: DateComponents(year: 2015, month: 2, day: 4, hour: 11, minute: 58),
        2016: DateComponents(year: 2016, month: 2, day: 4, hour: 17, minute: 46),
        2017: DateComponents(year: 2017, month: 2, day: 3, hour: 23, minute: 34),
        2018: DateComponents(year: 2018, month: 2, day: 4, hour: 5, minute: 28),
        2019: DateComponents(year: 2019, month: 2, day: 4, hour: 11, minute: 14),
        2020: DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 3),
        2021: DateComponents(year: 2021, month: 2, day: 3, hour: 22, minute: 58),
        2022: DateComponents(year: 2022, month: 2, day: 4, hour: 4, minute: 50),
        2023: DateComponents(year: 2023, month: 2, day: 4, hour: 10, minute: 42),
        2024: DateComponents(year: 2024, month: 2, day: 4, hour: 16, minute: 26),
        2025: DateComponents(year: 2025, month: 2, day: 3, hour: 22, minute: 10),
        2026: DateComponents(year: 2026, month: 2, day: 4, hour: 3, minute: 56),
        2027: DateComponents(year: 2027, month: 2, day: 4, hour: 9, minute: 46),
        2028: DateComponents(year: 2028, month: 2, day: 4, hour: 15, minute: 30),
        2029: DateComponents(year: 2029, month: 2, day: 3, hour: 21, minute: 20),
        2030: DateComponents(year: 2030, month: 2, day: 4, hour: 3, minute: 8)
    ]

    static func risshunDate(for year: Int) -> Date? {
        guard let components = risshunTable[year] else {
            return fallbackRisshunDate(for: year)
        }

        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return nil
        }
        calendar.timeZone = jst

        return calendar.date(from: components)
    }

    private static func fallbackRisshunDate(for year: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return nil
        }
        calendar.timeZone = jst

        let components = DateComponents(year: year, month: 2, day: 4, hour: 0, minute: 0)
        return calendar.date(from: components)
    }
}
