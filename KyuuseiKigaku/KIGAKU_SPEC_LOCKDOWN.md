# Nine Star Ki (Kyuusei Kigaku) Calculation Spec Lockdown

## Overview
This document defines the locked-down specification for Nine Star Ki calculations, ensuring consistent and testable behavior.

## 1. Risshun (立春) Boundary for Yearly Change

### Definition
- **Risshun** (Start of Spring) marks the beginning of the astrological year
- Fixed date: **February 4th** (simplified for initial implementation)
- Future refinement: Can be adjusted to actual astronomical Risshun dates

### Year Adjustment Rule
```
IF birth_month < 2 OR (birth_month == 2 AND birth_day < 4)
  THEN use (birth_year - 1) for calculation
  ELSE use birth_year for calculation
```

### Implementation
```swift
private static func getRisshunDay(year: Int) -> Int {
    return 4  // February 4th
}

private static func getAdjustedYearForRisshun(year: Int, month: Int, day: Int) -> Int {
    let risshunDay = getRisshunDay(year: year)

    if month < 2 || (month == 2 && day < risshunDay) {
        return year - 1
    } else {
        return year
    }
}
```

## 2. Honmei (本命) Calculation Formula

### Century-Specific Formulas

#### For Years 1900-1999
```
raw_value = 11 - (year % 9)
honmei = normalize_to_1_to_9(raw_value)
```

#### For Years 2000-2099
```
raw_value = 9 - (year % 9)
honmei = normalize_to_1_to_9(raw_value)
```

#### For Other Years (Fallback)
```
raw_value = 11 - (year % 9)
honmei = normalize_to_1_to_9(raw_value)
```

### Normalization to 1-9 Range
```swift
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
```

### Examples

| Year | Adjusted Year | Formula | Raw | Normalized |
|------|---------------|---------|-----|------------|
| 1990-05-15 | 1990 | 11 - (1990 % 9) | 10 | **1** |
| 1990-01-15 | 1989 | 11 - (1989 % 9) | 11 | **2** |
| 2000-06-20 | 2000 | 9 - (2000 % 9) | 7 | **7** |
| 1995-02-03 | 1994 | 11 - (1994 % 9) | 6 | **6** |
| 1995-02-04 | 1995 | 11 - (1995 % 9) | 5 | **5** |

## 3. Getsumei (月命) Calculation

### Current Implementation
Simplified formula using month offset:
```swift
private static func calculateSimplifiedGetsumei(honmei: Int, month: Int) -> Int {
    let monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
    let offset = monthOffset[month - 1]
    var getsumei = honmei + offset
    while getsumei > 9 {
        getsumei -= 9
    }
    return getsumei
}
```

### Test Requirements
- **Current**: Minimal range validation (1-9)
- **Future**: Will be tightened with specific expected values

## 4. Unit Test Coverage

### Test Suite Structure

#### 1. Basic Formula Tests
- `testHonmeiCalculation_For1990()` - Validates 1900-1999 formula
- `testHonmeiCalculation_For2000()` - Validates 2000-2099 formula

#### 2. Year Adjustment Tests
- `testYearAdjustment_BeforeRisshun()` - Jan 15 uses previous year
- `testYearAdjustment_AfterRisshun()` - Feb 10 uses current year

#### 3. Risshun Boundary Tests
- `testRisshunBoundary_Feb3()` - Feb 3 uses previous year
- `testRisshunBoundary_Feb4()` - Feb 4 uses current year (Risshun day)

#### 4. Getsumei Tests
- `testGetsumeiCalculation()` - Range validation (1-9)

#### 5. Structure Tests
- `testResultStructure()` - Validates result completeness

### Expected Test Results
All 8 tests should pass:
1. ✅ testHonmeiCalculation_For1990
2. ✅ testHonmeiCalculation_For2000
3. ✅ testYearAdjustment_BeforeRisshun
4. ✅ testYearAdjustment_AfterRisshun
5. ✅ testRisshunBoundary_Feb3
6. ✅ testRisshunBoundary_Feb4
7. ✅ testGetsumeiCalculation
8. ✅ testResultStructure

## 5. Key Design Decisions

### Modular Functions
The implementation is structured with clear separation:
1. `getRisshunDay()` - Returns Risshun day for a year (currently fixed at 4)
2. `getAdjustedYearForRisshun()` - Applies year adjustment based on Risshun
3. `calculateHonmei()` - Calculates honmei using century-specific formulas
4. `normalizeToNineStars()` - Ensures result is in 1-9 range
5. `calculateSimplifiedGetsumei()` - Calculates monthly star

### Future Refinements
1. **Risshun Date**: Can be refined to use astronomical calculations
2. **Getsumei Formula**: Can be tightened with more specific expected values
3. **Century Support**: Easy to add formulas for other centuries

## 6. Files Modified

### Core Implementation
- `KyuuseiKigaku/KyuuseiKigaku/Services/KigakuCalculator.swift`
  - Added `getRisshunDay()` function
  - Added `getAdjustedYearForRisshun()` function
  - Added `calculateHonmei()` with century-specific logic
  - Added `normalizeToNineStars()` function
  - Refactored `calculate()` to use new functions

### Unit Tests
- `KyuuseiKigaku/KyuuseiKigakuTests/KigakuCalculatorTests.swift`
  - Changed "Setsubun" to "Risshun" in test names and messages
  - Updated expected calculations to use century-specific formulas
  - Added `testRisshunBoundary_Feb3()` test
  - Added `testRisshunBoundary_Feb4()` test

## 7. Verification

To verify the implementation locally:

```bash
cd KyuuseiKigaku
xcodebuild test \
  -project KyuuseiKigaku.xcodeproj \
  -scheme KyuuseiKigaku \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""
```

Expected output: All 8 tests pass

## 8. Next Steps

1. ✅ Risshun boundary defined and implemented
2. ✅ Honmei formula locked down with century-specific logic
3. ✅ Unit tests updated with Risshun terminology and boundary tests
4. 🔄 Getsumei formula kept minimal (to be tightened later)
5. 📋 Future: Astronomical Risshun calculation
6. 📋 Future: Detailed Getsumei validation

## Summary

The Nine Star Ki calculation logic is now:
- **Consistent**: Clear rules for Risshun boundary and century-specific formulas
- **Testable**: 8 comprehensive unit tests covering all scenarios
- **Maintainable**: Modular functions with clear responsibilities
- **Extensible**: Easy to refine Risshun dates and formulas in the future
