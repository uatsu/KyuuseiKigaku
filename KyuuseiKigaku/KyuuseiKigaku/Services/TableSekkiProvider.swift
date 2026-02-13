import Foundation

/// Implementation of SekkiProvider that reads from a bundled JSON data file.
///
/// This provider loads Sekki (solar term) data from a JSON file included in the app bundle.
/// The data contains precise date/time instants for all 12 principal Sekki for multiple years.
///
/// **Data Format:**
/// The JSON file contains a dictionary of years, where each year has an array of 12 Sekki entries.
/// Each entry includes the Sekki name (kanji), month, day, hour, and minute in JST.
///
/// **Caching:**
/// Data is loaded lazily on first use and cached in memory for performance.
///
/// **Thread Safety:**
/// Access to the cache is synchronized to prevent race conditions.
class TableSekkiProvider: SekkiProvider {

    // MARK: - Properties

    /// Cached Sekki data by year
    private var cache: [Int: [SekkiInstant]] = [:]

    /// Serial queue for thread-safe cache access
    private let cacheQueue = DispatchQueue(label: "com.kyuseikigaku.sekkiprovider.cache")

    /// Fallback year range when data file is unavailable
    private let fallbackRange = 1900...2100

    // MARK: - Initialization

    init() {
        loadDataIfNeeded()
    }

    // MARK: - SekkiProvider Protocol

    func risshunDate(for year: Int) -> Date? {
        return cacheQueue.sync {
            guard let sekkiList = cache[year], !sekkiList.isEmpty else {
                return fallbackRisshunDate(for: year)
            }

            // Risshun is always the first entry
            return sekkiList.first?.date
        }
    }

    func allSekkiDates(for year: Int) -> [SekkiInstant] {
        return cacheQueue.sync {
            if let cached = cache[year] {
                return cached
            }

            // Try to load for this specific year
            loadDataForYear(year)

            return cache[year] ?? []
        }
    }

    func sekkiDate(forMonth month: Int, year: Int) -> SekkiInstant? {
        guard month >= 1 && month <= 12 else { return nil }

        return cacheQueue.sync {
            let sekkiList = allSekkiDates(for: year)

            // Find the Sekki matching the requested month number
            return sekkiList.first { instant in
                guard let sekkiType = SekkiType(rawValue: instant.name) else { return false }
                return sekkiType.monthNumber == month
            }
        }
    }

    func supportedYearRange() -> ClosedRange<Int> {
        return cacheQueue.sync {
            if cache.isEmpty {
                return fallbackRange
            }

            let years = cache.keys.sorted()
            guard let minYear = years.first, let maxYear = years.last else {
                return fallbackRange
            }

            return minYear...maxYear
        }
    }

    // MARK: - Data Loading

    /// Loads the Sekki data from the bundled JSON file.
    private func loadDataIfNeeded() {
        cacheQueue.sync {
            guard cache.isEmpty else { return }

            guard let url = Bundle.main.url(forResource: "sekki_data", withExtension: "json") else {
                print("Warning: sekki_data.json not found in bundle. Using fallback data.")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let sekkiData = try decoder.decode(SekkiDataFile.self, from: data)

                // Parse all years
                for (yearString, entries) in sekkiData.years {
                    guard let year = Int(yearString) else { continue }
                    loadYear(year, from: entries)
                }

                print("Loaded Sekki data for \(cache.count) years")
            } catch {
                print("Error loading sekki_data.json: \(error). Using fallback data.")
            }
        }
    }

    /// Loads data for a specific year from the raw entries.
    private func loadYear(_ year: Int, from entries: [SekkiDataEntry]) {
        var sekkiInstants: [SekkiInstant] = []

        var calendar = Calendar(identifier: .gregorian)
        guard let jst = TimeZone(identifier: "Asia/Tokyo") else {
            print("Error: Could not create JST timezone")
            return
        }
        calendar.timeZone = jst

        for entry in entries {
            // Determine the correct year for this Sekki
            // Shoukan (January) belongs to the next calendar year
            let sekkiYear: Int
            if entry.month == 1 {
                // Shoukan of year N is actually in January of year N+1
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

        // Sort by date to ensure chronological order
        sekkiInstants.sort { $0.date < $1.date }

        cache[year] = sekkiInstants
    }

    /// Loads data for a specific year on demand.
    private func loadDataForYear(_ year: Int) {
        // In this implementation, all data is loaded upfront
        // This method is a placeholder for potential lazy loading
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

/// Root structure of the Sekki data JSON file.
private struct SekkiDataFile: Codable {
    let version: String
    let timezone: String
    let description: String
    let data_source: String
    let years: [String: [SekkiDataEntry]]
}

/// Single Sekki entry from the JSON file.
private struct SekkiDataEntry: Codable {
    let name: String
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
}
