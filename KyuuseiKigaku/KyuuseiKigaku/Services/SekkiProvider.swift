import Foundation

/// Represents a single Sekki (solar term) instant with precise date and time.
struct SekkiInstant {
    let name: String
    let date: Date

    init(name: String, date: Date) {
        self.name = name
        self.date = date
    }
}

/// Represents the type of Sekki (solar term).
enum SekkiType: String, CaseIterable {
    case risshun = "立春"       // 1. Start of Spring (Feb ~4)
    case keichitsu = "啓蟄"     // 2. Awakening of Insects (Mar ~6)
    case seimei = "清明"        // 3. Pure Brightness (Apr ~5)
    case rikka = "立夏"         // 4. Start of Summer (May ~5)
    case boushu = "芒種"        // 5. Grain in Ear (Jun ~6)
    case shousho = "小暑"       // 6. Lesser Heat (Jul ~7)
    case risshuu = "立秋"       // 7. Start of Autumn (Aug ~7)
    case hakuro = "白露"        // 8. White Dew (Sep ~8)
    case kanro = "寒露"         // 9. Cold Dew (Oct ~8)
    case rittou = "立冬"        // 10. Start of Winter (Nov ~7)
    case taisetsu = "大雪"      // 11. Heavy Snow (Dec ~7)
    case shoukan = "小寒"       // 12. Lesser Cold (Jan ~6)

    /// Returns the astrological month number (1-12) for this Sekki.
    var monthNumber: Int {
        switch self {
        case .risshun: return 1
        case .keichitsu: return 2
        case .seimei: return 3
        case .rikka: return 4
        case .boushu: return 5
        case .shousho: return 6
        case .risshuu: return 7
        case .hakuro: return 8
        case .kanro: return 9
        case .rittou: return 10
        case .taisetsu: return 11
        case .shoukan: return 12
        }
    }

    /// Returns the Sekki type for a given astrological month number (1-12).
    static func fromMonthNumber(_ month: Int) -> SekkiType? {
        return SekkiType.allCases.first { $0.monthNumber == month }
    }
}

/// Protocol for providing Sekki (solar term) data.
///
/// Implementations must provide precise date/time instants for the 24 solar terms,
/// particularly the 12 principal terms (Sekki) used in Kyusei Kigaku calculations.
///
/// All dates and times must be in Asia/Tokyo timezone (JST).
protocol SekkiProvider {

    /// Returns the Risshun (立春) instant for the given year.
    ///
    /// Risshun marks the beginning of the astrological year in Kyusei Kigaku.
    ///
    /// - Parameter year: The calendar year
    /// - Returns: The date and time of Risshun in JST, or nil if not available
    func risshunDate(for year: Int) -> Date?

    /// Returns all 12 Sekki instants for the given year.
    ///
    /// The array should contain entries in chronological order, starting with
    /// Risshun and including all 12 principal solar terms.
    ///
    /// - Parameter year: The calendar year
    /// - Returns: Array of Sekki instants, or empty array if not available
    func allSekkiDates(for year: Int) -> [SekkiInstant]

    /// Returns the Sekki instant for a specific astrological month in the given year.
    ///
    /// - Parameters:
    ///   - month: The astrological month number (1-12)
    ///   - year: The calendar year
    /// - Returns: The Sekki instant, or nil if not available
    func sekkiDate(forMonth month: Int, year: Int) -> SekkiInstant?

    /// Returns the supported year range for this provider.
    ///
    /// - Returns: A closed range of years for which data is available
    func supportedYearRange() -> ClosedRange<Int>
}

/// Default implementation providing common functionality.
extension SekkiProvider {

    /// Helper to determine which astrological month a date belongs to.
    ///
    /// - Parameters:
    ///   - date: The date to check
    ///   - year: The calendar year (needed to fetch Sekki data)
    /// - Returns: The astrological month number (1-12), or nil if cannot be determined
    func astrological Month(for date: Date, inYear year: Int) -> Int? {
        let sekkiDates = allSekkiDates(for: year)
        guard !sekkiDates.isEmpty else { return nil }

        // Find the latest Sekki that is before or at the given date
        var currentMonth = 12  // Start with last month of previous year

        for sekki in sekkiDates {
            if date >= sekki.date {
                // This Sekki has started
                if let sekkiType = SekkiType(rawValue: sekki.name) {
                    currentMonth = sekkiType.monthNumber
                }
            } else {
                // Haven't reached this Sekki yet
                break
            }
        }

        // Handle case where date is before first Sekki of the year
        if date < sekkiDates[0].date {
            // Need to check last Sekki of previous year
            let previousYearSekkiDates = allSekkiDates(for: year - 1)
            if !previousYearSekkiDates.isEmpty {
                if let lastSekki = previousYearSekkiDates.last,
                   let sekkiType = SekkiType(rawValue: lastSekki.name) {
                    currentMonth = sekkiType.monthNumber
                }
            }
        }

        return currentMonth
    }
}
