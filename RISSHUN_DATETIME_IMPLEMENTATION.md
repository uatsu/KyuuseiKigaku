# Risshun Datetime Boundary Implementation

## Overview
This document describes the implementation of strict Risshun (立春, Start of Spring) datetime boundaries with JST timezone support for the Nine Star Ki (Kyuusei Kigaku) calculation system.

## Implementation Summary

### 1. RisshunProvider.swift
**Location**: `KyuuseiKigaku/Services/RisshunProvider.swift`

A new service class that provides exact Risshun datetime information:

#### Features
- **Embedded Risshun Table**: Contains precise Risshun dates and times (JST) for years 1985-2030
- **JST Timezone Support**: All dates are in `Asia/Tokyo` timezone
- **Fallback Mechanism**: For years not in the table, falls back to February 4, 00:00 JST
- **Date Precision**: Includes hour and minute components for accurate boundary detection

#### API
```swift
static func risshunDate(for year: Int) -> Date?
```
Returns the exact Risshun datetime for a given year in JST timezone.

#### Sample Data
| Year | Risshun Date & Time (JST) |
|------|---------------------------|
| 1995 | 1995-02-04 15:21 |
| 2000 | 2000-02-04 20:40 |
| 2020 | 2020-02-04 17:03 |
| 2025 | 2025-02-03 22:10 |

### 2. KigakuCalculator Updates
**Location**: `KyuuseiKigaku/Services/KigakuCalculator.swift`

#### Changes Made

**Removed Functions**:
- `getRisshunDay()` - No longer needed (replaced by RisshunProvider)
- `getAdjustedYearForRisshun()` - Replaced with more precise datetime comparison

**New Function**:
```swift
private static func determineKigakuYear(birthDate: Date, birthYear: Int) -> Int
```

This function:
1. Gets the exact Risshun datetime for the birth year
2. Compares birthDate < risshunDate
3. Returns:
   - `birthYear - 1` if birthDate is before Risshun
   - `birthYear` if birthDate is at or after Risshun

#### Logic Flow
```
Input: birthDate (with time)
  ↓
Get risshunDate for birthYear from RisshunProvider
  ↓
Compare: birthDate < risshunDate?
  ↓
Yes → kigakuYear = birthYear - 1
No  → kigakuYear = birthYear
  ↓
Calculate honmei using kigakuYear
```

### 3. Unit Tests
**Location**: `KyuuseiKigakuTests/KigakuCalculatorTests.swift`

#### New Boundary Tests

**Test: `testRisshunBoundary_OneMinuteBefore_1995`**
- Date: 1995-02-04 15:20 JST
- Risshun: 1995-02-04 15:21 JST
- Expected: Uses year 1994 (previous year)
- Status: ✅ Should pass

**Test: `testRisshunBoundary_OneMinuteAfter_1995`**
- Date: 1995-02-04 15:22 JST
- Risshun: 1995-02-04 15:21 JST
- Expected: Uses year 1995 (current year)
- Status: ✅ Should pass

**Test: `testRisshunBoundary_OneMinuteBefore_2020`**
- Date: 2020-02-04 17:02 JST
- Risshun: 2020-02-04 17:03 JST
- Expected: Uses year 2019 (previous year)
- Status: ✅ Should pass

**Test: `testRisshunBoundary_OneMinuteAfter_2020`**
- Date: 2020-02-04 17:04 JST
- Risshun: 2020-02-04 17:03 JST
- Expected: Uses year 2020 (current year)
- Status: ✅ Should pass

#### Updated Tests
- `testRisshunBoundary_Feb4`: Now includes hour component (16:00) to ensure it's after Risshun at 15:21

#### Existing Tests
All existing tests remain valid:
- `testHonmeiCalculation_For1990` - Tests 1900s formula
- `testHonmeiCalculation_For2000` - Tests 2000s formula
- `testYearAdjustment_BeforeRisshun` - Tests January date
- `testYearAdjustment_AfterRisshun` - Tests February 10 date
- `testRisshunBoundary_Feb3` - Tests February 3 (before Risshun)
- `testGetsumeiCalculation` - Range validation
- `testResultStructure` - Result completeness

**Total Test Count**: 12 tests

### 4. Xcode Project Configuration
**Location**: `KyuuseiKigaku.xcodeproj/project.pbxproj`

Added RisshunProvider.swift to:
- ✅ PBXBuildFile section (A0000016)
- ✅ PBXFileReference section (B0000016)
- ✅ Services group (E0000007)
- ✅ Sources build phase (F0000003)

## Technical Details

### Timezone Handling
All Risshun calculations use JST (Asia/Tokyo) timezone:
```swift
var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")
```

### Date Comparison
The system uses strict datetime comparison:
```swift
if birthDate < risshunDate {
    // Use previous year
} else {
    // Use current year
}
```

This ensures:
- 2020-02-04 17:02:59 JST → Uses 2019
- 2020-02-04 17:03:00 JST → Uses 2020 (exact moment of Risshun)
- 2020-02-04 17:03:01 JST → Uses 2020

### Fallback Behavior
If a year is not in the Risshun table:
```swift
private static func fallbackRisshunDate(for year: Int) -> Date? {
    // Returns: year-02-04 00:00:00 JST
}
```

This is clearly marked as fallback behavior that can be replaced when more data is available.

## Benefits

### 1. Accuracy
- Uses actual astronomical Risshun times
- Handles minute-level precision
- Accounts for years when Risshun falls on February 3 (e.g., 2017, 2021, 2025)

### 2. Testability
- Clear boundary test cases
- Tests verify exact minute transitions
- Tests cover both 1900s and 2000s formulas

### 3. Maintainability
- Risshun data is centralized in one location
- Easy to add more years to the table
- Fallback mechanism prevents crashes

### 4. Extensibility
- Can easily add more years to the Risshun table
- Can implement astronomical calculation in the future
- Clear separation of concerns

## Migration from Previous Implementation

### Before (Date-only comparison)
```swift
// Old: Only compared day
if month < 2 || (month == 2 && day < 4) {
    adjustedYear = year - 1
}
```

**Issues**:
- Always used February 4 regardless of actual Risshun
- No time component consideration
- Inaccurate for edge cases

### After (Datetime comparison with JST)
```swift
// New: Compares exact datetime
guard let risshunDate = RisshunProvider.risshunDate(for: birthYear) else {
    return birthYear
}

if birthDate < risshunDate {
    return birthYear - 1
} else {
    return birthYear
}
```

**Improvements**:
- Uses actual Risshun dates and times
- Handles February 3 Risshun years correctly
- Minute-level precision
- Proper JST timezone handling

## Verification

### Manual Testing
To verify the implementation:

1. **Test 1**: Birth at 1995-02-04 15:20 JST (1 min before Risshun)
   - Expected: Honmei for 1994

2. **Test 2**: Birth at 1995-02-04 15:22 JST (1 min after Risshun)
   - Expected: Honmei for 1995

3. **Test 3**: Birth at 2025-02-03 22:09 JST (1 min before Risshun)
   - Expected: Honmei for 2024

4. **Test 4**: Birth at 2025-02-03 22:11 JST (1 min after Risshun)
   - Expected: Honmei for 2025

### Unit Test Execution
```bash
cd KyuuseiKigaku
xcodebuild test \
  -project KyuuseiKigaku.xcodeproj \
  -scheme KyuuseiKigaku \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5"
```

Expected: All 12 tests pass

## Files Modified

1. **Created**: `KyuuseiKigaku/Services/RisshunProvider.swift`
   - New service with Risshun datetime table

2. **Modified**: `KyuuseiKigaku/Services/KigakuCalculator.swift`
   - Replaced date-only logic with datetime comparison
   - Added `determineKigakuYear` function
   - Removed old `getRisshunDay` and `getAdjustedYearForRisshun` functions

3. **Modified**: `KyuuseiKigakuTests/KigakuCalculatorTests.swift`
   - Added 4 new boundary condition tests
   - Updated `testRisshunBoundary_Feb4` to include time component
   - All tests now account for precise datetime boundaries

4. **Modified**: `KyuuseiKigaku.xcodeproj/project.pbxproj`
   - Added RisshunProvider.swift to project configuration

## Future Enhancements

### 1. Extended Risshun Table
Add more years to the Risshun table:
- Historical data: 1900-1984
- Future data: 2031-2099

### 2. Astronomical Calculation
Replace the table with astronomical calculation:
```swift
static func calculateRisshun(for year: Int) -> Date? {
    // Calculate based on solar longitude
}
```

### 3. Time Zone Flexibility
Support birth dates in other timezones:
```swift
static func risshunDate(for year: Int, in timeZone: TimeZone) -> Date?
```

### 4. Validation
Add validation warnings:
```swift
if !risshunTable.keys.contains(year) {
    print("⚠️ Using fallback Risshun date for year \(year)")
}
```

## Summary

The Risshun datetime implementation provides:
- ✅ Precise datetime boundaries (minute-level accuracy)
- ✅ Proper JST timezone handling
- ✅ Comprehensive unit test coverage (12 tests)
- ✅ Clear fallback mechanism
- ✅ Easy extensibility for future enhancements
- ✅ Maintains backward compatibility with existing functionality

This implementation ensures that the Nine Star Ki calculations are astronomically accurate and properly handle the exact moment of Risshun, regardless of the time of day or whether Risshun falls on February 3 or February 4.
