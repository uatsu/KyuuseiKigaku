# Kyusei Kigaku Calculation Specification (C Logic)

**Version:** 1.0
**Date:** 2026-02-13
**Status:** Production

## Overview

This document defines the production-grade calculation logic for Kyusei Kigaku (Nine Star Ki) astrology system. The logic is based on the traditional Japanese astronomical calendar using the 24 solar terms (二十四節気 / Nijūshi Sekki) for precise boundary determination.

## Core Principles

### 1. Timezone Standard

**All calculations use Asia/Tokyo timezone (JST / UTC+9)** exclusively, regardless of:
- User's device timezone
- User's geographic location
- Birth location

**Rationale:** Kyusei Kigaku originated in Japan and uses Japanese astronomical calculations published in JST.

### 2. Gregorian Calendar

All dates are expressed in the Gregorian calendar, even for historical dates.

### 3. Precision

Time boundaries are precise to the **minute** level in JST.

---

## Year Boundary: Risshun (立春)

### Definition

The **astrological year** in Kyusei Kigaku begins at **Risshun (立春)**, the "Start of Spring" and the first of the 24 solar terms.

### Boundary Rules

- **Before Risshun:** Belongs to the **previous** calendar year for Honmei calculation
- **At or After Risshun:** Belongs to the **current** calendar year for Honmei calculation

### Example

For **1995-02-04 15:21 JST** (Risshun 1995):

| Birth DateTime (JST)      | Calendar Year | Kigaku Year | Reason                    |
|---------------------------|---------------|-------------|---------------------------|
| 1995-02-04 15:20:00 JST   | 1995          | 1994        | Before Risshun            |
| 1995-02-04 15:21:00 JST   | 1995          | 1995        | At Risshun (exact minute) |
| 1995-02-04 15:22:00 JST   | 1995          | 1995        | After Risshun             |
| 1995-02-03 23:59:59 JST   | 1995          | 1994        | Before Risshun            |
| 1995-02-05 00:00:00 JST   | 1995          | 1995        | After Risshun             |

### Data Requirements

Risshun instants must be provided for each year in the supported range, specified as:
- Year
- Month
- Day
- Hour
- Minute
- Timezone: JST

---

## Month Boundary: Sekki (節気)

### Definition

The **astrological month** in Kyusei Kigaku begins at each **Sekki (節気)**, the principal solar terms (the odd-numbered terms of the 24 solar terms).

### The 12 Sekki (Principal Solar Terms)

| Sekki No. | Name (Kanji) | Name (Romaji) | Approximate Date |
|-----------|--------------|---------------|------------------|
| 1         | 立春          | Risshun       | Feb 4            |
| 2         | 啓蟄          | Keichitsu     | Mar 6            |
| 3         | 清明          | Seimei        | Apr 5            |
| 4         | 立夏          | Rikka         | May 5            |
| 5         | 芒種          | Boushu        | Jun 6            |
| 6         | 小暑          | Shousho       | Jul 7            |
| 7         | 立秋          | Risshuu       | Aug 7            |
| 8         | 白露          | Hakuro        | Sep 8            |
| 9         | 寒露          | Kanro         | Oct 8            |
| 10        | 立冬          | Rittou        | Nov 7            |
| 11        | 大雪          | Taisetsu      | Dec 7            |
| 12        | 小寒          | Shoukan       | Jan 6            |

### Boundary Rules

- **Before Sekki:** Belongs to the **previous** astrological month
- **At or After Sekki:** Belongs to the **current** astrological month

### Month Mapping

The astrological months do NOT align with calendar months:

| Astrological Month | Sekki Start    | Approximate Period      |
|--------------------|----------------|-------------------------|
| 1                  | Risshun (立春)  | Feb 4 - Mar 5          |
| 2                  | Keichitsu (啓蟄) | Mar 6 - Apr 4         |
| 3                  | Seimei (清明)   | Apr 5 - May 4          |
| 4                  | Rikka (立夏)    | May 5 - Jun 5          |
| 5                  | Boushu (芒種)   | Jun 6 - Jul 6          |
| 6                  | Shousho (小暑)  | Jul 7 - Aug 6          |
| 7                  | Risshuu (立秋)  | Aug 7 - Sep 7          |
| 8                  | Hakuro (白露)   | Sep 8 - Oct 7          |
| 9                  | Kanro (寒露)    | Oct 8 - Nov 6          |
| 10                 | Rittou (立冬)   | Nov 7 - Dec 6          |
| 11                 | Taisetsu (大雪) | Dec 7 - Jan 5          |
| 12                 | Shoukan (小寒)  | Jan 6 - Feb 3          |

**Important:** Months 11 and 12 span across calendar year boundaries. For example, if born on Jan 5, the astrological month is still 11 (Taisetsu), not 12.

### Data Requirements

All 12 Sekki instants must be provided for each year, with minute precision in JST.

---

## Daily Star (Nichimei / 日命)

### Definition

The **Daily Star** represents the star that governs a specific day in the Kyusei Kigaku system. It follows a simple 9-day cyclic rotation.

### Calculation Method (C Spec)

The daily star cycles through the nine stars in **decreasing order**:

```
9 → 8 → 7 → 6 → 5 → 4 → 3 → 2 → 1 → 9 (repeat)
```

### Reference Point

- **Reference Date:** 1995-02-04 (Risshun 1995)
- **Reference Star:** 9 (Kyuushi / Nine Purple Fire Star)
- **Timezone:** JST (Asia/Tokyo)

### Formula

```
offset = floorMod(daysDiff, 9)  // 0...8
star = 9 - offset               // Returns 9,8,7,6,5,4,3,2,1 for offset 0-8
```

Where:
- `daysDiff` = Number of calendar days from reference date to target date (can be negative)
- `floorMod(a, n)` = Mathematical floor modulo (always returns 0 to n-1, even for negative a)

### Day Boundary

The Daily Star uses **start of day (00:00:00)** in JST for day boundaries.

**Time of day does NOT affect the result** - only the calendar date matters.

### Examples

| Date           | Days from Ref | Offset | Daily Star |
|----------------|---------------|--------|------------|
| 1995-02-04     | 0             | 0      | 9          |
| 1995-02-05     | 1             | 1      | 8          |
| 1995-02-06     | 2             | 2      | 7          |
| 1995-02-12     | 8             | 8      | 1          |
| 1995-02-13     | 9             | 0      | 9          |
| 1995-02-03     | -1            | 8      | 1          |
| 1995-02-02     | -2            | 7      | 2          |
| 2000-01-01     | 1792          | 1      | 8          |
| 2020-02-04     | 9131          | 5      | 4          |

### Data Requirements

Only the single reference point is needed:
- Reference date: 1995-02-04
- Reference star: 9

All other dates are computed mathematically.

---

## Honmei (本命 / Life Star)

### Definition

Honmei represents the primary star that governs a person's life path and character. It is determined by the **Kigaku year** (adjusted for Risshun boundary).

### Calculation Formula

The formula varies by century:

#### For years 1900-1999:
```
rawValue = 11 - (year % 9)
honmei = normalizeToNineStars(rawValue)
```

#### For years 2000-2099:
```
rawValue = 9 - (year % 9)
honmei = normalizeToNineStars(rawValue)
```

#### For other centuries (default):
```
rawValue = 11 - (year % 9)
honmei = normalizeToNineStars(rawValue)
```

Where `normalizeToNineStars(value)` ensures the result is in the range 1-9.

### Examples

| Calendar Year | Birth Date         | Before Risshun? | Kigaku Year | Honmei |
|---------------|-------------------|-----------------|-------------|--------|
| 1995          | 1995-02-03 23:59  | Yes             | 1994        | 3      |
| 1995          | 1995-02-04 15:21  | No              | 1995        | 2      |
| 2000          | 2000-01-15        | Yes             | 1999        | 2      |
| 2000          | 2000-02-05        | No              | 2000        | 9      |

---

## Getsumei (月命 / Month Star)

### Definition

Getsumei represents the secondary star that influences a person's personality and interpersonal relationships. It is derived from the Honmei star plus a month-based offset.

### Calculation Formula

```
monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8][astrological_month - 1]
getsumei = normalizeToNineStars(honmei + monthOffset)
```

### Monthly Offset Pattern

The offset follows a repeating 3-month cycle:

| Astrological Month | Offset | Notes                    |
|--------------------|--------|--------------------------|
| 1, 4, 7, 10        | +2     | Months starting with 立  |
| 2, 5, 8, 11        | +5     |                          |
| 3, 6, 9, 12        | +8     |                          |

### Important Note

**Getsumei uses the astrological month**, not the calendar month. The astrological month is determined by Sekki boundaries, not calendar month boundaries.

### Example

For birth date: **2020-03-05 12:00 JST**

1. Determine Kigaku year:
   - Risshun 2020: 2020-02-04 17:03 JST
   - Birth is after Risshun → Kigaku year = 2020

2. Calculate Honmei:
   - rawValue = 9 - (2020 % 9) = 9 - 4 = 5
   - Honmei = 5

3. Determine astrological month:
   - Keichitsu 2020: 2020-03-05 10:57 JST
   - Birth (12:00) is after Keichitsu (10:57) → Month = 2

4. Calculate Getsumei:
   - monthOffset = [2, 5, 8, ...][2 - 1] = 5
   - getsumei = normalize(5 + 5) = normalize(10) = 1

Result: Honmei = 5, Getsumei = 1

---

## Data Source Requirements

### SekkiProvider Protocol

The implementation must provide a `SekkiProvider` protocol that can return:

1. **Risshun instant** for a given year
2. **All 12 Sekki instants** for a given year
3. **Specific Sekki instant** for a given year and month

### Data Format

Sekki data should be stored in a structured format (JSON/CSV) with:
- Year
- Sekki name
- Date and time in JST (to minute precision)

### Data Range

The bundled data should cover a practical range, such as:
- **Minimum:** 1900
- **Maximum:** 2100

For dates outside this range, the system should:
- Log a warning
- Fall back to February 4, 00:00 JST as Risshun
- Use calendar months for Getsumei calculation

---

## Testing Requirements

### Unit Tests Must Cover

1. **Year Boundary Tests:**
   - One minute before Risshun → uses previous year
   - At Risshun (exact minute) → uses current year
   - One minute after Risshun → uses current year
   - Test for multiple years (e.g., 1995, 2000, 2020)

2. **Month Boundary Tests:**
   - One minute before each Sekki → uses previous month
   - At Sekki (exact minute) → uses current month
   - One minute after Sekki → uses current month
   - Test for all 12 Sekki

3. **Daily Star Tests:**
   - Reference date returns correct star
   - Dates before reference return correct stars
   - Dates after reference return correct stars
   - Time of day does not affect result
   - Negative offsets handled correctly

4. **Integration Tests:**
   - Complete Honmei calculation with real birth dates
   - Complete Getsumei calculation with real birth dates
   - Edge cases (year boundaries, month boundaries)

### Test Data

Use known astronomical data from reliable sources such as:
- Japan Meteorological Agency
- National Astronomical Observatory of Japan
- Published Koyomi (暦 / Japanese almanac)

---

## Implementation Notes

### Architectural Principles

1. **Separation of Concerns:**
   - Data layer (SekkiProvider)
   - Boundary logic (YearBoundaryService, MonthBoundaryService)
   - Calculation logic (KigakuCalculator)

2. **Dependency Injection:**
   - Services should accept provider protocols
   - Enables testing with mock data
   - Allows future alternative data sources

3. **Immutability:**
   - All calculation methods are pure functions
   - No global mutable state
   - Thread-safe by design

4. **Error Handling:**
   - Graceful degradation for missing data
   - Clear logging of fallback behavior
   - Never crash - always return a valid result

### Performance Considerations

1. **Data Loading:**
   - Load Sekki data lazily on first use
   - Cache parsed data in memory
   - Consider pre-loading for critical paths

2. **Calculation Efficiency:**
   - Most calculations are O(1) after boundary determination
   - Boundary lookup should be O(log n) or better
   - Avoid repeated date parsing

---

## Future Enhancements

Potential future improvements (out of scope for this version):

1. **Hour Star (時命 / Jikimei):**
   - Requires hour-level Sekki boundaries
   - More complex calculation based on day and time

2. **Compatibility Analysis:**
   - Relationship compatibility between two people
   - Requires additional algorithm specifications

3. **Lucky/Unlucky Directions:**
   - Annual and monthly direction calculations
   - Based on Honmei and current year/month

4. **Multiple Calendar Systems:**
   - Support for Chinese lunar calendar
   - Support for other East Asian variations

---

## References

1. **Astronomical Data:**
   - 国立天文台 (National Astronomical Observatory of Japan)
   - 気象庁 (Japan Meteorological Agency)

2. **Traditional Sources:**
   - 九星気学 texts and practitioners
   - Historical Koyomi publications

3. **Implementation Standards:**
   - ISO 8601 for date/time representation
   - IANA timezone database for timezone handling

---

## Version History

- **1.0 (2026-02-13):** Initial specification for C logic implementation

---

## Approval

This specification defines the authoritative calculation logic for the Kyusei Kigaku application.

**Status:** ✅ APPROVED FOR IMPLEMENTATION
