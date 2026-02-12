import Foundation

struct KigakuResult {
    let honmeiNum: Int
    let honmeiName: String
    let getsumeiNum: Int
    let getsumeiName: String
}

/// Calculates Kyusei Kigaku (Nine Star Ki) numbers based on birth date.
///
/// Kyusei Kigaku is a traditional Japanese divination system based on the Chinese Nine Star Ki.
/// The system uses the astrological year boundary (Risshun/立春) rather than the calendar year,
/// meaning births before Risshun belong to the previous year for calculation purposes.
class KigakuCalculator {

    // MARK: - Public Interface

    /// Calculates Honmei (本命) and Getsumei (月命) for the given birth date.
    ///
    /// - Parameter birthDate: The person's birth date and time
    /// - Returns: KigakuResult containing Honmei and Getsumei numbers with their names
    ///
    /// - Note: All calculations use Asia/Tokyo timezone (JST) as this is the traditional
    ///         reference timezone for Kyusei Kigaku, regardless of where the person was born.
    static func calculate(birthDate: Date) -> KigakuResult {
        var calendar = Calendar(identifier: .gregorian)
        if let jst = TimeZone(identifier: "Asia/Tokyo") {
            calendar.timeZone = jst
        }
        let components = calendar.dateComponents([.year, .month], from: birthDate)

        guard let year = components.year,
              let month = components.month else {
            return KigakuResult(honmeiNum: 1, honmeiName: getKigakuName(1), getsumeiNum: 1, getsumeiName: getKigakuName(1))
        }

        let kigakuYear = determineKigakuYear(birthDate: birthDate, birthYear: year)
        let honmei = calculateHonmei(year: kigakuYear)
        let getsumei = calculateSimplifiedGetsumei(honmei: honmei, month: month)

        return KigakuResult(
            honmeiNum: honmei,
            honmeiName: getKigakuName(honmei),
            getsumeiNum: getsumei,
            getsumeiName: getKigakuName(getsumei)
        )
    }

    // MARK: - Risshun Boundary Logic

    /// Determines if a given date is before the Risshun (立春 / Start of Spring) boundary.
    ///
    /// **Why Risshun Matters:**
    /// In Kyusei Kigaku, the astrological new year begins at Risshun, not January 1st.
    /// Risshun marks the first of the 24 solar terms (二十四節気) in the traditional
    /// East Asian lunisolar calendar. Anyone born before Risshun belongs to the previous
    /// astrological year for Honmei calculation purposes.
    ///
    /// **Timezone Consistency:**
    /// All Risshun times are expressed in Asia/Tokyo timezone (JST/UTC+9) because:
    /// 1. Kyusei Kigaku originated in Japan and uses Japanese astronomical calculations
    /// 2. Historical Risshun tables are published in JST
    /// 3. Ensures consistent calculations regardless of user's device timezone
    ///
    /// **Implementation:**
    /// - Risshun datetime is retrieved from RisshunProvider's astronomical table
    /// - Comparison uses Date's absolute time (timezone-independent)
    /// - Boundary is precise to the minute (e.g., 15:20 is before Risshun at 15:21)
    ///
    /// - Parameter date: The date to check (typically a birth date)
    /// - Returns: `true` if the date is before Risshun, `false` if at or after Risshun
    ///
    /// - Note: If Risshun data is unavailable for the year, returns `false` (assumes after Risshun)
    ///         to use the fallback Feb 4 00:00 JST boundary.
    static func isBeforeRisshun(_ date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return false
        }
        calendar.timeZone = jst

        let components = calendar.dateComponents([.year], from: date)
        guard let year = components.year else {
            return false
        }

        guard let risshunDate = RisshunProvider.risshunDate(for: year) else {
            return false
        }

        return date < risshunDate
    }

    /// Determines the Kigaku year to use for Honmei calculation.
    ///
    /// The Kigaku year may differ from the calendar year due to the Risshun boundary:
    /// - Before Risshun: Use previous calendar year (e.g., 1995-02-03 → Kigaku year 1994)
    /// - At/After Risshun: Use current calendar year (e.g., 1995-02-05 → Kigaku year 1995)
    ///
    /// - Parameters:
    ///   - birthDate: The birth date to evaluate
    ///   - birthYear: The calendar year of birth
    /// - Returns: The Kigaku year to use for Honmei calculation
    private static func determineKigakuYear(birthDate: Date, birthYear: Int) -> Int {
        if isBeforeRisshun(birthDate) {
            return birthYear - 1
        } else {
            return birthYear
        }
    }

    // MARK: - Honmei Calculation

    /// Calculates Honmei (本命 / Life Star) number for a given year.
    ///
    /// Honmei represents the primary star that governs a person's life path and character.
    /// The calculation formula varies by century due to the cyclical nature of the system.
    ///
    /// **Formula by Century:**
    /// - 1900-1999: `11 - (year % 9)`
    /// - 2000-2099: `9 - (year % 9)`
    /// - Others: `11 - (year % 9)` (default fallback)
    ///
    /// The raw value is then normalized to the 1-9 range using modulo arithmetic.
    ///
    /// - Parameter year: The Kigaku year (adjusted for Risshun boundary)
    /// - Returns: Honmei number (1-9)
    private static func calculateHonmei(year: Int) -> Int {
        let rawValue: Int

        if year >= 1900 && year <= 1999 {
            rawValue = 11 - (year % 9)
        } else if year >= 2000 && year <= 2099 {
            rawValue = 9 - (year % 9)
        } else {
            rawValue = 11 - (year % 9)
        }

        return normalizeToNineStars(rawValue)
    }

    /// Normalizes a value to the Nine Stars range (1-9).
    ///
    /// The Nine Star Ki system uses a closed cycle of numbers 1 through 9.
    /// Values outside this range are adjusted using modulo arithmetic.
    ///
    /// - Parameter value: The raw value to normalize
    /// - Returns: Normalized value in the range 1-9
    private static func normalizeToNineStars(_ value: Int) -> Int {
        var normalized = value
        while normalized <= 0 {
            normalized += 9
        }
        while normalized > 9 {
            normalized -= 9
        }
        return normalized
    }

    // MARK: - Getsumei Calculation

    /// Calculates Getsumei (月命 / Month Star) number based on Honmei and birth month.
    ///
    /// Getsumei represents the secondary star that influences a person's personality
    /// and interpersonal relationships. It is derived from the Honmei star plus a
    /// month-based offset.
    ///
    /// **Monthly Offset Pattern:**
    /// The offset follows a repeating 3-month cycle: [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
    /// - Jan/Apr/Jul/Oct: +2
    /// - Feb/May/Aug/Nov: +5
    /// - Mar/Jun/Sep/Dec: +8
    ///
    /// - Parameters:
    ///   - honmei: The Honmei number (1-9)
    ///   - month: The birth month (1-12)
    /// - Returns: Getsumei number (1-9)
    private static func calculateSimplifiedGetsumei(honmei: Int, month: Int) -> Int {
        let monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
        let offset = monthOffset[month - 1]
        var getsumei = honmei + offset
        while getsumei > 9 {
            getsumei -= 9
        }
        return getsumei
    }

    // MARK: - Nichimei (Daily Star) Calculation

    /// Performs floor modulo operation (always returns positive result).
    ///
    /// Swift's `%` operator returns negative values for negative dividends, which is unsuitable
    /// for cyclic calculations. This function implements mathematical floor modulo (also known as
    /// Euclidean modulo) which always returns a value in the range [0, n).
    ///
    /// Examples:
    /// - `floorMod(7, 9)` returns `7`
    /// - `floorMod(-1, 9)` returns `8` (not `-1`)
    /// - `floorMod(-7, 9)` returns `2` (not `-7`)
    ///
    /// - Parameters:
    ///   - a: The dividend (can be negative)
    ///   - n: The divisor (must be positive)
    /// - Returns: Result in range [0, n)
    private static func floorMod(_ a: Int, _ n: Int) -> Int {
        let r = a % n
        return r >= 0 ? r : r + n
    }

    /// Reference date for Daily Star calculation (2000-01-01 00:00:00 JST = Star 1).
    ///
    /// This date serves as the anchor point for the 9-day cyclic rotation of daily stars.
    /// All daily star calculations compute the number of days elapsed since this reference
    /// and apply modulo 9 arithmetic to determine the current day's star.
    private static let dailyStarReferenceDate: DateComponents = DateComponents(
        year: 2000,
        month: 1,
        day: 1,
        hour: 0,
        minute: 0,
        second: 0
    )

    /// The star number for the reference date (Ichihaku / One White Water Star).
    private static let dailyStarReferenceNumber = 1

    /// Calculates the Daily Star (Nichimei / 日命) for a given date.
    ///
    /// **What is Nichimei?**
    /// Nichimei (Daily Star) represents the star that governs a specific day in the
    /// Kyusei Kigaku system. Unlike Honmei (yearly) and Getsumei (monthly), Nichimei
    /// follows a simple 9-day cyclic rotation.
    ///
    /// **Calculation Method:**
    /// The daily star cycles through the nine stars in sequential order:
    /// 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 1 (repeat)
    ///
    /// Each complete cycle takes exactly 9 days. The calculation:
    /// 1. Determines days elapsed since a known reference date
    /// 2. Applies modulo 9 arithmetic to find position in the cycle
    /// 3. Returns the corresponding star number (1-9)
    ///
    /// **Reference Date:**
    /// Uses January 1, 2000 at 00:00:00 JST as the reference (defined as Star 1).
    /// This provides a deterministic, testable foundation for all calculations.
    ///
    /// **Timezone Handling:**
    /// All calculations use Asia/Tokyo timezone (JST/UTC+9) to ensure:
    /// - Consistent day boundaries regardless of user location
    /// - Alignment with traditional Japanese astrological practice
    /// - Deterministic results for testing and verification
    ///
    /// **Implementation Details:**
    /// - Days are counted using calendar day boundaries in JST
    /// - Time of day does not affect the result (only the date matters)
    /// - The cycle is continuous and infinite in both directions
    /// - Dates before the reference date are handled correctly (negative offsets)
    ///
    /// - Parameter date: The date to calculate the daily star for
    /// - Returns: Daily star number (1-9), or 1 if calculation fails
    ///
    /// - Note: This is a simplified deterministic implementation. Traditional Nichimei
    ///         calculations may involve more complex formulas based on month and year stars.
    static func calculateDailyStar(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return 1
        }
        calendar.timeZone = jst

        guard let referenceDate = calendar.date(from: dailyStarReferenceDate) else {
            return 1
        }

        let components = calendar.dateComponents([.day], from: referenceDate, to: date)
        guard let daysSinceReference = components.day else {
            return 1
        }

        let cyclePosition = floorMod(daysSinceReference, 9) + dailyStarReferenceNumber
        return cyclePosition
    }

    // MARK: - Star Names

    /// Retrieves the localized name for a Kigaku star number.
    ///
    /// Each of the nine stars has a traditional name based on the Five Elements
    /// (Wood, Fire, Earth, Metal, Water) and their positions (e.g., "One White Water Star").
    ///
    /// - Parameter number: The star number (1-9)
    /// - Returns: Localized star name from i18n resources
    private static func getKigakuName(_ number: Int) -> String {
        switch number {
        case 1: return I18n.t("kigaku_name_1")
        case 2: return I18n.t("kigaku_name_2")
        case 3: return I18n.t("kigaku_name_3")
        case 4: return I18n.t("kigaku_name_4")
        case 5: return I18n.t("kigaku_name_5")
        case 6: return I18n.t("kigaku_name_6")
        case 7: return I18n.t("kigaku_name_7")
        case 8: return I18n.t("kigaku_name_8")
        case 9: return I18n.t("kigaku_name_9")
        default: return I18n.t("kigaku_name_1")
        }
    }
}
