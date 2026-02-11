import Foundation

/// Provides precise Risshun (立春 / Start of Spring) datetime data for Kyusei Kigaku calculations.
///
/// **What is Risshun?**
/// Risshun marks the beginning of spring in the traditional East Asian lunisolar calendar
/// and represents the astrological new year boundary in Kyusei Kigaku (Nine Star Ki).
/// It is the first of the 24 solar terms (二十四節気 / Nijūshi Sekki).
///
/// **Astronomical Definition:**
/// Risshun occurs when the Sun reaches exactly 315° of solar longitude. This moment
/// varies from year to year due to Earth's orbital mechanics and typically falls on
/// February 3rd, 4th, or 5th in the Gregorian calendar.
///
/// **Implementation Strategy:**
/// This provider uses a lookup table of pre-calculated Risshun datetimes with minute-level
/// precision. All times are expressed in Asia/Tokyo timezone (JST/UTC+9) to maintain
/// consistency with traditional Japanese astronomical calculations.
///
/// **Current Table Status:**
/// - Contains 6 sample years: 1990, 1991, 1995, 2000, 2020, 2026
/// - Sufficient for testing and initial deployment
/// - Full 1900-2100 range can be generated using `Scripts/RisshunTableGenerator.swift`
///
/// **Fallback Behavior:**
/// Years not in the table use February 4 at 00:00 JST as a reasonable approximation.
/// This fallback ensures the app remains functional even for years outside the table.
///
/// **Future Expansion:**
/// The table structure supports easy expansion. The generation script uses solar longitude
/// 315° calculations to produce astronomically accurate Risshun times for any year range.
class RisshunProvider {

    // MARK: - Risshun Datetime Table

    /// Lookup table of Risshun datetimes by year.
    ///
    /// Each entry contains the precise moment when Risshun begins for that year.
    /// Times are accurate to the minute and expressed in JST (Asia/Tokyo timezone).
    ///
    /// **Data Source:**
    /// Generated from astronomical calculations of solar longitude 315°.
    /// See `Scripts/RisshunTableGenerator.swift` for generation details.
    ///
    /// **Table Coverage:**
    /// Currently contains 6 years for testing and validation. Can be expanded to
    /// cover 1900-2100 or any other desired range using the generator script.
    private static let risshunTable: [Int: DateComponents] = [
        1990: DateComponents(year: 1990, month: 2, day: 4, hour: 10, minute: 14),
        1991: DateComponents(year: 1991, month: 2, day: 4, hour: 16, minute: 8),
        1995: DateComponents(year: 1995, month: 2, day: 4, hour: 15, minute: 21),
        2000: DateComponents(year: 2000, month: 2, day: 4, hour: 20, minute: 40),
        2020: DateComponents(year: 2020, month: 2, day: 4, hour: 17, minute: 3),
        2026: DateComponents(year: 2026, month: 2, day: 4, hour: 3, minute: 56)
    ]

    // MARK: - Public Interface

    /// Retrieves the Risshun datetime for a given year.
    ///
    /// This method first checks the lookup table for precise astronomical data.
    /// If the year is not in the table, it returns a fallback date of February 4 at 00:00 JST.
    ///
    /// **Usage in Kigaku Calculations:**
    /// The returned date is used to determine whether a birth occurred before or after
    /// the astrological new year boundary. Births before Risshun belong to the previous
    /// year's Honmei calculation.
    ///
    /// **Timezone Handling:**
    /// All returned dates are anchored in Asia/Tokyo timezone (JST/UTC+9) to ensure
    /// consistency with traditional Japanese astronomical calculations, regardless of
    /// the user's device timezone.
    ///
    /// - Parameter year: The calendar year to look up
    /// - Returns: Date object representing the Risshun moment in JST, or nil if timezone unavailable
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

    // MARK: - Fallback Logic

    /// Provides a fallback Risshun date for years not in the lookup table.
    ///
    /// **Fallback Strategy:**
    /// Returns February 4 at 00:00 (midnight) JST, which is a reasonable approximation
    /// since Risshun typically falls on February 3-5, most commonly on February 4.
    ///
    /// **Accuracy Tradeoff:**
    /// The fallback may be off by up to 24 hours from the true astronomical Risshun moment.
    /// For production use with important date ranges, expand the lookup table to include
    /// all required years for full accuracy.
    ///
    /// - Parameter year: The calendar year needing a fallback
    /// - Returns: Date object for February 4 at 00:00 JST, or nil if timezone unavailable
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
