import Foundation

/// Service for determining astrological year boundaries based on Risshun.
///
/// In Kyusei Kigaku, the astrological year begins at Risshun (立春), not January 1.
/// This service uses a SekkiProvider to obtain precise Risshun instants and determine
/// which astrological year a given date belongs to.
class YearBoundaryService {

    // MARK: - Properties

    private let sekkiProvider: SekkiProvider

    // MARK: - Initialization

    init(sekkiProvider: SekkiProvider) {
        self.sekkiProvider = sekkiProvider
    }

    // MARK: - Public Interface

    /// Determines the Kigaku (astrological) year for a given date.
    ///
    /// **Logic:**
    /// - If the date is before Risshun: use the **previous** calendar year
    /// - If the date is at or after Risshun: use the **current** calendar year
    ///
    /// **Example:**
    /// - 1995-02-03 23:59 JST (before Risshun 1995) → Kigaku year 1994
    /// - 1995-02-04 15:21 JST (at Risshun 1995) → Kigaku year 1995
    /// - 1995-02-04 15:22 JST (after Risshun 1995) → Kigaku year 1995
    ///
    /// - Parameter date: The date to evaluate
    /// - Returns: The Kigaku year (adjusted for Risshun boundary)
    func kigakuYear(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            // Fallback: use calendar year if timezone unavailable
            return Calendar.current.component(.year, from: date)
        }
        calendar.timeZone = jst

        let calendarYear = calendar.component(.year, from: date)

        // Check if date is before Risshun of the calendar year
        if isBeforeRisshun(date, inYear: calendarYear) {
            return calendarYear - 1
        } else {
            return calendarYear
        }
    }

    /// Checks if a date is before the Risshun instant for a given year.
    ///
    /// - Parameters:
    ///   - date: The date to check
    ///   - year: The calendar year to check Risshun for
    /// - Returns: `true` if the date is before Risshun, `false` otherwise
    func isBeforeRisshun(_ date: Date, inYear year: Int) -> Bool {
        guard let risshunDate = sekkiProvider.risshunDate(for: year) else {
            // Fallback: assume date is after Risshun if we can't determine it
            return false
        }

        return date < risshunDate
    }

    /// Returns the Risshun instant for a given year.
    ///
    /// - Parameter year: The calendar year
    /// - Returns: The Risshun date/time, or nil if not available
    func risshunDate(for year: Int) -> Date? {
        return sekkiProvider.risshunDate(for: year)
    }
}

/// Service for determining astrological month boundaries based on Sekki.
///
/// In Kyusei Kigaku, astrological months begin at each of the 12 principal Sekki,
/// not at calendar month boundaries. This service determines which astrological
/// month a given date belongs to.
class MonthBoundaryService {

    // MARK: - Properties

    private let sekkiProvider: SekkiProvider

    // MARK: - Initialization

    init(sekkiProvider: SekkiProvider) {
        self.sekkiProvider = sekkiProvider
    }

    // MARK: - Public Interface

    /// Determines the astrological month number (1-12) for a given date.
    ///
    /// **Astrological Month Mapping:**
    /// 1. Risshun (立春) - Feb ~4
    /// 2. Keichitsu (啓蟄) - Mar ~6
    /// 3. Seimei (清明) - Apr ~5
    /// 4. Rikka (立夏) - May ~5
    /// 5. Boushu (芒種) - Jun ~6
    /// 6. Shousho (小暑) - Jul ~7
    /// 7. Risshuu (立秋) - Aug ~7
    /// 8. Hakuro (白露) - Sep ~8
    /// 9. Kanro (寒露) - Oct ~8
    /// 10. Rittou (立冬) - Nov ~7
    /// 11. Taisetsu (大雪) - Dec ~7
    /// 12. Shoukan (小寒) - Jan ~6
    ///
    /// **Important:** Months 11 and 12 span across calendar years.
    ///
    /// - Parameter date: The date to evaluate
    /// - Returns: The astrological month number (1-12), or nil if cannot be determined
    func astrologicalMonth(for date: Date) -> Int? {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return nil
        }
        calendar.timeZone = jst

        let calendarYear = calendar.component(.year, from: date)

        // Get all Sekki for this year
        let currentYearSekkiList = sekkiProvider.allSekkiDates(for: calendarYear)

        // Also get Sekki for previous year (needed for dates in early January)
        let previousYearSekkiList = sekkiProvider.allSekkiDates(for: calendarYear - 1)

        // Combine and sort all relevant Sekki
        var allSekki = currentYearSekkiList + previousYearSekkiList
        allSekki.sort { $0.date < $1.date }

        // Find the latest Sekki that is at or before the given date
        var currentMonth: Int?

        for sekki in allSekki {
            if date >= sekki.date {
                // This Sekki has started
                if let sekkiType = SekkiType(rawValue: sekki.name) {
                    currentMonth = sekkiType.monthNumber
                }
            } else {
                // Haven't reached this Sekki yet, stop searching
                break
            }
        }

        // If no Sekki found before the date, use fallback
        if currentMonth == nil {
            // Fallback to calendar month approximation
            currentMonth = fallbackAstrologicalMonth(for: date, calendar: calendar)
        }

        return currentMonth
    }

    /// Returns the Sekki instant that starts a given astrological month in a year.
    ///
    /// - Parameters:
    ///   - month: The astrological month number (1-12)
    ///   - year: The Kigaku year
    /// - Returns: The Sekki instant, or nil if not available
    func sekkiDate(forMonth month: Int, kigakuYear year: Int) -> SekkiInstant? {
        // Note: For months 11 and 12, the Sekki may be in the next calendar year
        // But we use the kigaku year for lookups
        return sekkiProvider.sekkiDate(forMonth: month, year: year)
    }

    // MARK: - Fallback

    /// Fallback method to approximate astrological month from calendar month.
    ///
    /// This is used when Sekki data is unavailable. It provides a reasonable
    /// approximation but may be off by a few days from the true Sekki boundaries.
    ///
    /// - Parameters:
    ///   - date: The date to evaluate
    ///   - calendar: Calendar configured with JST timezone
    /// - Returns: Approximated astrological month number (1-12)
    private func fallbackAstrologicalMonth(for date: Date, calendar: Calendar) -> Int {
        let calendarMonth = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Approximate mapping based on typical Sekki dates
        // This is a rough approximation and should not be relied upon for precision
        switch calendarMonth {
        case 1:
            return day < 6 ? 12 : 1  // Before Jan 6 → Month 12 (Shoukan)
        case 2:
            return day < 4 ? 12 : 1  // Before Feb 4 → Month 12, after → Month 1 (Risshun)
        case 3:
            return day < 6 ? 1 : 2   // Before Mar 6 → Month 1, after → Month 2 (Keichitsu)
        case 4:
            return day < 5 ? 2 : 3   // Before Apr 5 → Month 2, after → Month 3 (Seimei)
        case 5:
            return day < 5 ? 3 : 4   // Before May 5 → Month 3, after → Month 4 (Rikka)
        case 6:
            return day < 6 ? 4 : 5   // Before Jun 6 → Month 4, after → Month 5 (Boushu)
        case 7:
            return day < 7 ? 5 : 6   // Before Jul 7 → Month 5, after → Month 6 (Shousho)
        case 8:
            return day < 7 ? 6 : 7   // Before Aug 7 → Month 6, after → Month 7 (Risshuu)
        case 9:
            return day < 8 ? 7 : 8   // Before Sep 8 → Month 7, after → Month 8 (Hakuro)
        case 10:
            return day < 8 ? 8 : 9   // Before Oct 8 → Month 8, after → Month 9 (Kanro)
        case 11:
            return day < 7 ? 9 : 10  // Before Nov 7 → Month 9, after → Month 10 (Rittou)
        case 12:
            return day < 7 ? 10 : 11 // Before Dec 7 → Month 10, after → Month 11 (Taisetsu)
        default:
            return 1
        }
    }
}
