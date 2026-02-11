# Risshun Table Generator

## Overview

This directory contains **generation utilities** for the Risshun datetime lookup table. These files are **NOT used at runtime** and are excluded from release builds.

## Files

### `RisshunTableGenerator.swift`
- **Purpose**: Generate Swift source code for RisshunProvider's dictionary
- **Status**: Phase 1 - Simplified interpolation algorithm
- **Exclusion**: Wrapped in `#if DEBUG` (not included in release builds)
- **Required**: No (generation utility only)

### `RunGenerator.swift`
- **Purpose**: Example script showing how to run the generator
- **Usage**: Demonstrates generator usage and preview output

## Usage Instructions

### Option 1: Xcode Playground (Recommended)

1. Create a new Xcode Playground
2. Copy the entire `RisshunTableGenerator.swift` contents into the playground
3. Add at the bottom:
   ```swift
   let output = RisshunTableGenerator.generateWithStats()
   print(output)
   ```
4. Run the playground
5. Copy the generated Swift code from the console output
6. Paste into `RisshunProvider.swift` to replace the placeholder table

### Option 2: Swift Command Line

```bash
cd KyuuseiKigaku/Scripts
swift RunGenerator.swift
```

### Option 3: Debug Build

1. Include the generator in a debug-only target
2. Call `RisshunTableGenerator.generateSwiftCode()` from debug code
3. Print or save the output

## Algorithm

### Current (Phase 1): Simplified Interpolation

- Uses linear interpolation between known reference points
- Reference points based on historical astronomical data:
  - 1990: 1990-02-04 10:14 JST
  - 2000: 2000-02-04 20:40 JST
  - 2010: 2010-02-04 06:47 JST
  - 2020: 2020-02-04 17:03 JST
  - 2026: 2026-02-04 03:56 JST

**Accuracy**: Estimated ±30-60 minutes of actual Risshun time

**Limitations**:
- Not true astronomical calculation
- Suitable for placeholder generation only
- Should not be used for professional Kigaku consultation

### Future (Phase 2): Solar Longitude Calculation

**Goal**: Implement astronomical precision using solar longitude 315°

**Requirements**:
- VSOP87 or JPL DE ephemeris for solar position
- Earth's orbital mechanics calculations
- Sub-minute precision
- Timezone conversion utilities

**Libraries** (potential):
- SwiftAA (Swift Astronomical Algorithms)
- Custom VSOP87 implementation
- NASA/JPL Horizons API integration

## Generated Output Format

The generator produces Swift code in this exact format:

```swift
private static let risshunTable: [Int: DateComponents] = [
    1900: DateComponents(year: 1900, month: 2, day: 4, hour: 10, minute: 30),
    1901: DateComponents(year: 1901, month: 2, day: 4, hour: 16, minute: 15),
    // ... entries for each year ...
    2100: DateComponents(year: 2100, month: 2, day: 3, hour: 23, minute: 45)
]
```

This format is directly compatible with `RisshunProvider.swift`.

## Workflow

### When to Regenerate the Table

1. **Initial Setup**: Generate full 1900-2100 table for production use
2. **Algorithm Improvement**: When Phase 2 (solar longitude) is implemented
3. **Extended Range**: If year range needs to expand beyond 1900-2100
4. **Validation**: After astronomical reference data updates

### Steps

1. Run the generator (see Usage Instructions above)
2. Copy the generated Swift code
3. Open `KyuuseiKigaku/Services/RisshunProvider.swift`
4. Replace the existing `risshunTable` dictionary
5. Build the project to verify syntax
6. Run `KigakuCalculatorTests` to verify calculations
7. Commit changes with clear message: "Update Risshun table: [reason]"

## Testing Generated Table

After updating `RisshunProvider.swift` with generated code:

```bash
# Run unit tests
xcodebuild test -scheme KyuuseiKigaku -destination 'platform=iOS Simulator,name=iPhone 15'
```

Key tests to verify:
- `testRisshunBoundary_OneMinuteBefore_1990`
- `testRisshunBoundary_OneMinuteAfter_1990`
- `testHonmeiCalculation_For1990`
- `testHonmeiCalculation_For2000`

## Not Included in Runtime

⚠️ **Important**: These generator files are **NOT**:
- Used by the app at runtime
- Required for unit tests to pass
- Included in release builds
- Part of the Xcode project targets (optional inclusion)

The generator is purely for **development and maintenance** of the Risshun table data.

## Future Enhancements

### Phase 2: Astronomical Precision

**Priority**: High
**Goal**: Replace simplified algorithm with true solar longitude calculation

**Implementation Steps**:
1. Research and select astronomical algorithm library
2. Implement solar longitude calculation (target: 315°)
3. Add timezone conversion (UTC → JST)
4. Achieve sub-minute precision
5. Validate against authoritative sources (e.g., Japanese Ephemeris)
6. Regenerate full table with new algorithm
7. Update documentation with new accuracy metrics

**Validation Sources**:
- 国立天文台 (National Astronomical Observatory of Japan)
- NASA JPL Horizons System
- USNO (US Naval Observatory) data

### Phase 3: Continuous Updates

**Priority**: Low
**Goal**: Annual regeneration for extended ranges

**Automation**:
- Script to run generator annually
- Compare with authoritative sources
- Automated validation checks
- Git commit with version tracking

## Questions or Issues

If you need to modify the generator or have questions about the algorithm:

1. Check the header comments in `RisshunTableGenerator.swift`
2. Review `RISSHUN_DATETIME_IMPLEMENTATION.md` in project root
3. See `Docs/plan-c-spec-table.md` for full specification
4. Consult astronomical references for solar longitude calculations

---

**Last Updated**: 2026-02-11
**Version**: Phase 1 (Simplified Interpolation)
**Status**: Ready for generation
