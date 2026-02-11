import Foundation

class RisshunProvider {
    //
    // RISSHUN DATETIME TABLE
    //
    // This is the runtime lookup table for exact Risshun (立春 / Start of Spring) datetimes.
    //
    // SOURCE OF TRUTH:
    // - The authoritative source will be a generated table from solar longitude calculations
    // - Solar longitude 315° marks the exact Risshun moment (astronomical definition)
    // - Generation code will be added separately to compute this table programmatically
    //
    // CURRENT STATUS:
    // - Placeholder table with sample years: 1990, 1991, 1995, 2000, 2020, 2026
    // - Datetimes are in JST (Japan Standard Time) with minute-level precision
    // - Structure designed for easy expansion to full range (1900-2100)
    //
    // STRUCTURE:
    // - Key: Year (Int)
    // - Value: DateComponents with year, month, day, hour, minute in JST
    // - Risshun typically falls on Feb 3, 4, or 5
    // - Time varies from early morning to late evening depending on astronomical cycles
    //
    // EXPANSION PLAN:
    // - Generate full table (1900-2100) using solar longitude algorithm
    // - Replace this placeholder table with comprehensive generated data
    // - Maintain same dictionary structure for backward compatibility
    //
    private static let risshunTable: [Int: DateComponents] = [
        1990: DateComponents(year: 1990, month: 2, day: 4, hour: 10, minute: 14),
        1991: DateComponents(year: 1991, month: 2, day: 4, hour: 16, minute: 8),
        1995: DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 21),
        2000: DateComponents(year: 2000, month: 2, day: 4, hour: 20, minute: 40),
        2020: DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 3),
        2026: DateComponents(year: 2026, month: 2, day: 4, hour: 3, minute: 56)
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
