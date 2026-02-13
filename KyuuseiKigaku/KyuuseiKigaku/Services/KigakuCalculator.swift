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
///
/// **Architecture:**
/// This calculator uses dependency injection for boundary services, allowing for:
/// - Precise Sekki-based month calculations
/// - Testability with mock providers
/// - Future extensibility
class KigakuCalculator {

    // MARK: - Properties

    private let yearBoundaryService: YearBoundaryService
    private let monthBoundaryService: MonthBoundaryService

    /// Shared singleton instance using production Sekki data.
    static let shared: KigakuCalculator = {
        let sekkiProvider = TableSekkiProvider()
        let yearService = YearBoundaryService(sekkiProvider: sekkiProvider)
        let monthService = MonthBoundaryService(sekkiProvider: sekkiProvider)
        return KigakuCalculator(yearBoundaryService: yearService, monthBoundaryService: monthService)
    }()

    // MARK: - Initialization

    /// Initializes calculator with custom boundary services (primarily for testing).
    ///
    /// - Parameters:
    ///   - yearBoundaryService: Service for determining astrological year boundaries
    ///   - monthBoundaryService: Service for determining astrological month boundaries
    init(yearBoundaryService: YearBoundaryService, monthBoundaryService: MonthBoundaryService) {
        self.yearBoundaryService = yearBoundaryService
        self.monthBoundaryService = monthBoundaryService
    }

    // MARK: - Public Interface

    /// Calculates Honmei (本命) and Getsumei (月命) for the given birth date.
    ///
    /// - Parameter birthDate: The person's birth date and time
    /// - Returns: KigakuResult containing Honmei and Getsumei numbers with their names
    ///
    /// - Note: All calculations use Asia/Tokyo timezone (JST) as this is the traditional
    ///         reference timezone for Kyusei Kigaku, regardless of where the person was born.
    func calculate(birthDate: Date) -> KigakuResult {
        // Determine the Kigaku year using Risshun boundary
        let kigakuYear = yearBoundaryService.kigakuYear(for: birthDate)

        // Calculate Honmei based on Kigaku year
        let honmei = Self.calculateHonmei(year: kigakuYear)

        // Determine astrological month using Sekki boundaries
        let astrologicalMonth = monthBoundaryService.astrologicalMonth(for: birthDate) ?? 1

        // Calculate Getsumei based on Honmei and astrological month
        let getsumei = Self.calculateGetsumei(honmei: honmei, astrologicalMonth: astrologicalMonth)

        return KigakuResult(
            honmeiNum: honmei,
            honmeiName: Self.getKigakuName(honmei),
            getsumeiNum: getsumei,
            getsumeiName: Self.getKigakuName(getsumei)
        )
    }

    /// Static convenience method for backward compatibility.
    ///
    /// Uses the shared singleton instance with production Sekki data.
    ///
    /// - Parameter birthDate: The person's birth date and time
    /// - Returns: KigakuResult containing Honmei and Getsumei numbers with their names
    static func calculate(birthDate: Date) -> KigakuResult {
        return shared.calculate(birthDate: birthDate)
    }

    // MARK: - Backward Compatibility Methods

    /// Determines if a given date is before the Risshun (立春 / Start of Spring) boundary.
    ///
    /// **Deprecated:** Use YearBoundaryService.isBeforeRisshun directly for new code.
    ///
    /// This method is retained for backward compatibility and uses the shared singleton's
    /// year boundary service.
    ///
    /// - Parameter date: The date to check (typically a birth date)
    /// - Returns: `true` if the date is before Risshun, `false` if at or after Risshun
    static func isBeforeRisshun(_ date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return false
        }
        calendar.timeZone = jst

        let year = calendar.component(.year, from: date)
        return shared.yearBoundaryService.isBeforeRisshun(date, inYear: year)
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

    /// Calculates Getsumei (月命 / Month Star) number based on Honmei and astrological month.
    ///
    /// Getsumei represents the secondary star that influences a person's personality
    /// and interpersonal relationships. It is derived from the Honmei star plus a
    /// month-based offset.
    ///
    /// **Important:** This method uses astrological months (1-12) determined by Sekki
    /// boundaries, not calendar months. The astrological month is determined by the
    /// MonthBoundaryService based on the 12 principal Sekki.
    ///
    /// **Monthly Offset Pattern:**
    /// The offset follows a repeating 3-month cycle: [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
    /// - Astrological Months 1, 4, 7, 10: +2
    /// - Astrological Months 2, 5, 8, 11: +5
    /// - Astrological Months 3, 6, 9, 12: +8
    ///
    /// - Parameters:
    ///   - honmei: The Honmei number (1-9)
    ///   - astrologicalMonth: The astrological month (1-12)
    /// - Returns: Getsumei number (1-9)
    private static func calculateGetsumei(honmei: Int, astrologicalMonth: Int) -> Int {
        let monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
        let offset = monthOffset[astrologicalMonth - 1]
        return normalizeToNineStars(honmei + offset)
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

    /// Reference date for Daily Star calculation (1995-02-04 00:00:00 JST = Star 9).
    ///
    /// This date serves as the anchor point for the 9-day cyclic rotation of daily stars.
    /// The reference date is Risshun 1995 (February 4, 1995), and on this date the Daily Star is 9.
    /// All daily star calculations compute the number of days elapsed since this reference
    /// and apply modulo 9 arithmetic to determine the current day's star.
    ///
    /// **C Spec Requirements:**
    /// - Reference date: 1995-02-04 (Risshun 1995)
    /// - Reference star: 9
    /// - Pattern: Decreasing by 1 each day (9→8→7→6→5→4→3→2→1→9...)
    /// - Timezone: JST (Asia/Tokyo)
    /// - Start of day comparison (time of day does not affect result)
    private static let dailyStarReferenceDate: DateComponents = DateComponents(
        year: 1995,
        month: 2,
        day: 4,
        hour: 0,
        minute: 0,
        second: 0
    )

    /// The star number for the reference date (Kyuushi / Nine Purple Fire Star).
    private static let dailyStarReferenceNumber = 9

    /// Calculates the Daily Star (Nichimei / 日命) for a given date.
    ///
    /// **What is Nichimei?**
    /// Nichimei (Daily Star) represents the star that governs a specific day in the
    /// Kyusei Kigaku system. Unlike Honmei (yearly) and Getsumei (monthly), Nichimei
    /// follows a simple 9-day cyclic rotation.
    ///
    /// **Calculation Method (C Spec):**
    /// The daily star cycles through the nine stars in decreasing order:
    /// 9 → 8 → 7 → 6 → 5 → 4 → 3 → 2 → 1 → 9 (repeat)
    ///
    /// Each complete cycle takes exactly 9 days. The calculation:
    /// 1. Determines days elapsed since the reference date (1995-02-04)
    /// 2. Applies floor modulo 9 arithmetic to find offset (0-8)
    /// 3. Calculates star = 9 - offset to get the decreasing pattern
    /// 4. Returns the corresponding star number (1-9)
    ///
    /// **Reference Date:**
    /// Uses February 4, 1995 (Risshun 1995) at 00:00:00 JST as the reference (Star 9).
    /// This provides a deterministic, testable foundation for all calculations.
    ///
    /// **Formula:**
    /// ```
    /// offset = floorMod(daysDiff, 9)  // 0...8
    /// star = 9 - offset               // Returns 9,8,7,6,5,4,3,2,1 for offset 0-8
    /// ```
    ///
    /// **Timezone Handling:**
    /// All calculations use Asia/Tokyo timezone (JST/UTC+9) to ensure:
    /// - Consistent day boundaries regardless of user location
    /// - Alignment with traditional Japanese astrological practice
    /// - Deterministic results for testing and verification
    ///
    /// **Implementation Details:**
    /// - Days are counted using calendar day boundaries in JST (start of day)
    /// - Time of day does not affect the result (only the date matters)
    /// - The cycle is continuous and infinite in both directions
    /// - Dates before the reference date are handled correctly (negative daysDiff)
    /// - floorMod ensures offset is always 0-8, even for negative daysDiff
    ///
    /// - Parameter date: The date to calculate the daily star for
    /// - Returns: Daily star number (1-9), or 9 if calculation fails
    ///
    /// - Note: This implements the stricter C spec for Daily Star calculation.
    static func calculateDailyStar(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return 9
        }
        calendar.timeZone = jst

        guard let referenceDate = calendar.date(from: dailyStarReferenceDate) else {
            return 9
        }

        let components = calendar.dateComponents([.day], from: referenceDate, to: date)
        guard let daysDiff = components.day else {
            return 9
        }

        let offset = floorMod(daysDiff, 9)
        let star = 9 - offset
        return star
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
