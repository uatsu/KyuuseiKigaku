import Foundation

/// Implementation of SekkiProvider that reads from a bundled JSON data file.
///
/// This provider loads Sekki (solar term) data from a JSON file included in the app bundle.
/// The data contains precise date/time instants for all 12 principal Sekki for multiple years.
///
/// **Data Format:**
/// Supports two JSON formats:
/// 1. ISO8601 format (preferred): Sekki names mapped to ISO8601 datetime strings
/// 2. Component format: Sekki entries with separate month/day/hour/minute fields
///
/// **Performance:**
/// - Data is loaded lazily on first use and cached in memory
/// - Binary search used for efficient year lookups
/// - Thread-safe cache access
///
/// **Resource Files:**
/// - `sekki_jst_1900_2100.json`: Comprehensive ISO8601 format (preferred)
/// - `sekki_data.json`: Component format (fallback)
class TableSekkiProvider: SekkiProvider {

    // MARK: - Properties

    /// Cached Sekki data by year (sorted by year for binary search)
    private var cache: [Int: [SekkiInstant]] = [:]

    /// Sorted array of years for binary search
    private var sortedYears: [Int] = []

    /// All Sekki sorted chronologically for latestSekkiBefore queries
    private var allSekkiSorted: [SekkiInstant] = []

    /// Serial queue for thread-safe cache access
    private let cacheQueue = DispatchQueue(label: "com.kyuseikigaku.sekkiprovider.cache")

    /// Fallback year range when data file is unavailable
    private let fallbackRange = 1900...2100

    /// Flag indicating if data has been loaded
    private var isLoaded = false

    // MARK: - Initialization

    init() {
        loadDataIfNeeded()
    }

    // MARK: - SekkiProvider Protocol

    func risshunDate(for year: Int) -> Date? {
        return cacheQueue.sync {
            ensureDataLoaded()

            guard let sekkiList = cache[year], !sekkiList.isEmpty else {
                return fallbackRisshunDate(for: year)
            }

            return sekkiList.first?.date
        }
    }

    func allSekkiDates(for year: Int) -> [SekkiInstant] {
        return cacheQueue.sync {
            ensureDataLoaded()

            if let cached = cache[year] {
                return cached
            }

            return []
        }
    }

    func sekkiDate(forMonth month: Int, year: Int) -> SekkiInstant? {
        guard month >= 1 && month <= 12 else { return nil }

        return cacheQueue.sync {
            ensureDataLoaded()

            let sekkiList = allSekkiDates(for: year)

            return sekkiList.first { instant in
                guard let sekkiType = SekkiType(rawValue: instant.name) else { return false }
                return sekkiType.monthNumber == month
            }
        }
    }

    func supportedYearRange() -> ClosedRange<Int> {
        return cacheQueue.sync {
            ensureDataLoaded()

            if sortedYears.isEmpty {
                return fallbackRange
            }

            return sortedYears.first!...sortedYears.last!
        }
    }

    // MARK: - Enhanced Functions

    /// Returns the Risshun instant for a given year.
    ///
    /// This is a convenience method that returns a SekkiInstant instead of just a Date.
    ///
    /// - Parameter year: The calendar year
    /// - Returns: SekkiInstant for Risshun, or nil if not available
    func risshunInstant(forYear year: Int) -> SekkiInstant? {
        return cacheQueue.sync {
            ensureDataLoaded()

            guard let sekkiList = cache[year], !sekkiList.isEmpty else {
                return nil
            }

            return sekkiList.first(where: { $0.name == "立春" })
        }
    }

    /// Returns the Sekki instant for a specific Sekki type and year.
    ///
    /// - Parameters:
    ///   - sekki: The Sekki type
    ///   - year: The calendar year
    /// - Returns: SekkiInstant for the requested Sekki, or nil if not available
    func sekkiInstant(for sekki: SekkiType, year: Int) -> SekkiInstant? {
        return cacheQueue.sync {
            ensureDataLoaded()

            guard let sekkiList = cache[year] else {
                return nil
            }

            return sekkiList.first { $0.name == sekki.rawValue }
        }
    }

    /// Finds the latest Sekki instant that occurs before or at the given date.
    ///
    /// Uses binary search for efficient lookup across all years.
    ///
    /// - Parameter date: The date to search from
    /// - Returns: The latest SekkiInstant before or at the date, or nil if none found
    func latestSekkiBefore(date: Date) -> SekkiInstant? {
        return cacheQueue.sync {
            ensureDataLoaded()

            guard !allSekkiSorted.isEmpty else {
                return nil
            }

            // Binary search for the latest Sekki before or at the date
            var left = 0
            var right = allSekkiSorted.count - 1
            var result: SekkiInstant?

            while left <= right {
                let mid = (left + right) / 2
                let sekki = allSekkiSorted[mid]

                if sekki.date <= date {
                    result = sekki
                    left = mid + 1
                } else {
                    right = mid - 1
                }
            }

            return result
        }
    }

    // MARK: - Data Loading

    /// Ensures data is loaded (called within cacheQueue)
    private func ensureDataLoaded() {
        guard !isLoaded else { return }
        loadData()
        isLoaded = true
    }

    /// Loads the Sekki data from the bundled JSON file.
    private func loadDataIfNeeded() {
        cacheQueue.sync {
            ensureDataLoaded()
        }
    }

    /// Main data loading method
    private func loadData() {
        // Try ISO8601 format first (preferred)
        if loadISO8601Format() {
            print("Loaded Sekki data (ISO8601 format) for \(cache.count) years")
            buildSortedStructures()
            return
        }

        // Fall back to component format
        if loadComponentFormat() {
            print("Loaded Sekki data (component format) for \(cache.count) years")
            buildSortedStructures()
            return
        }

        print("Warning: No sekki data files found. Using fallback data.")
    }

    /// Loads data from ISO8601 format JSON
    private func loadISO8601Format() -> Bool {
        guard let url = Bundle.main.url(forResource: "sekki_jst_1900_2100", withExtension: "json") else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let sekkiData = try decoder.decode(SekkiDataFileISO8601.self, from: data)

            for (yearString, sekkiDict) in sekkiData.years {
                guard let year = Int(yearString) else { continue }

                var sekkiInstants: [SekkiInstant] = []

                // Parse ISO8601 datetime strings
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withTimeZone]

                for (sekkiName, dateTimeString) in sekkiDict {
                    guard let date = iso8601Formatter.date(from: dateTimeString) else {
                        print("Warning: Could not parse date '\(dateTimeString)' for \(sekkiName) in year \(year)")
                        continue
                    }

                    let instant = SekkiInstant(name: sekkiName, date: date)
                    sekkiInstants.append(instant)
                }

                sekkiInstants.sort { $0.date < $1.date }
                cache[year] = sekkiInstants
            }

            return true
        } catch {
            print("Error loading sekki_jst_1900_2100.json: \(error)")
            return false
        }
    }

    /// Loads data from component format JSON (fallback)
    private func loadComponentFormat() -> Bool {
        guard let url = Bundle.main.url(forResource: "sekki_data", withExtension: "json") else {
            return false
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let sekkiData = try decoder.decode(SekkiDataFile.self, from: data)

            for (yearString, entries) in sekkiData.years {
                guard let year = Int(yearString) else { continue }
                loadYear(year, from: entries)
            }

            return true
        } catch {
            print("Error loading sekki_data.json: \(error)")
            return false
        }
    }

    /// Loads data for a specific year from component entries.
    private func loadYear(_ year: Int, from entries: [SekkiDataEntry]) {
        var sekkiInstants: [SekkiInstant] = []

        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            print("Error: Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        for entry in entries {
            let sekkiYear: Int
            if entry.month == 1 {
                sekkiYear = year + 1
            } else {
                sekkiYear = year
            }

            let components = DateComponents(
                year: sekkiYear,
                month: entry.month,
                day: entry.day,
                hour: entry.hour,
                minute: entry.minute,
                second: 0
            )

            guard let date = calendar.date(from: components) else {
                print("Warning: Could not create date for \(entry.name) in year \(year)")
                continue
            }

            let instant = SekkiInstant(name: entry.name, date: date)
            sekkiInstants.append(instant)
        }

        sekkiInstants.sort { $0.date < $1.date }
        cache[year] = sekkiInstants
    }

    /// Builds sorted data structures for efficient lookups
    private func buildSortedStructures() {
        sortedYears = cache.keys.sorted()

        allSekkiSorted = cache.values
            .flatMap { $0 }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Fallback

    /// Provides a fallback Risshun date for years without data.
    private func fallbackRisshunDate(for year: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            return nil
        }
        calendar.timeZone = jst

        let components = DateComponents(year: year, month: 2, day: 4, hour: 0, minute: 0)
        return calendar.date(from: components)
    }
}

// MARK: - Data Structures for JSON Decoding

/// Root structure of the ISO8601 format Sekki data JSON file.
private struct SekkiDataFileISO8601: Codable {
    let version: String
    let timezone: String
    let description: String
    let data_source: String
    let format: String
    let years: [String: [String: String]]
}

/// Root structure of the component format Sekki data JSON file.
private struct SekkiDataFile: Codable {
    let version: String
    let timezone: String
    let description: String
    let data_source: String
    let years: [String: [SekkiDataEntry]]
}

/// Single Sekki entry from the component format JSON file.
private struct SekkiDataEntry: Codable {
    let name: String
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
}
