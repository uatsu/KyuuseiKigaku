# Kigaku Calculation Implementation Notes

## Honmei (本命星) Calculation

### Formula (Deterministic)

```
1. Adjust year for Risshun boundary:
   if month < 2 OR (month == 2 AND day < 4):
       adjustedYear = year - 1
   else:
       adjustedYear = year

2. Calculate Honmei:
   honmei = 11 - (adjustedYear % 9)
   if honmei > 9:
       honmei -= 9
   if honmei == 0:
       honmei = 9
```

### Examples

| Birth Date | Adjusted Year | Calculation | Honmei | Star Name |
|------------|---------------|-------------|--------|-----------|
| Jan 15, 1990 | 1989 | 11 - (1989 % 9) = 11 - 0 = 11 → 11 - 9 = 2 | 2 | 二黒土星 |
| Feb 3, 1990 | 1989 | 11 - (1989 % 9) = 2 | 2 | 二黒土星 |
| Feb 4, 1990 | 1990 | 11 - (1990 % 9) = 11 - 1 = 10 → 10 - 9 = 1 | 1 | 一白水星 |
| Feb 5, 1990 | 1990 | 11 - (1990 % 9) = 1 | 1 | 一白水星 |
| Dec 25, 1990 | 1990 | 11 - (1990 % 9) = 1 | 1 | 一白水星 |

### Risshun Boundary

**Fixed at February 4th** - This is a simplified MVP approach.

- **Before Feb 4 (Jan 1 - Feb 3)**: Use previous year
- **On/After Feb 4 (Feb 4 - Dec 31)**: Use current year

**Note:** Traditional Kigaku uses the exact Risshun moment (around 11:00-12:00 on Feb 4), which varies by year. This MVP uses a fixed date boundary for simplicity.

---

## Getsumei (月命星) Calculation

### Implementation: Simplified Algorithm

**IMPORTANT:** This is a **simplified monthly star calculation** for MVP purposes. It is **NOT** the traditional solar term-based method.

### Formula

```
monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
offset = monthOffset[month - 1]
getsumei = honmei + offset
while getsumei > 9:
    getsumei -= 9
```

### Pattern

The offset pattern follows a 3-month cycle (2, 5, 8) repeated for all 12 months:
- Jan, Apr, Jul, Oct: offset = 2
- Feb, May, Aug, Nov: offset = 5
- Mar, Jun, Sep, Dec: offset = 8

### Examples

| Honmei | Month | Offset | Calculation | Getsumei | Star Name |
|--------|-------|--------|-------------|----------|-----------|
| 1 | January | 2 | 1 + 2 = 3 | 3 | 三碧木星 |
| 1 | February | 5 | 1 + 5 = 6 | 6 | 六白金星 |
| 1 | March | 8 | 1 + 8 = 9 | 9 | 九紫火星 |
| 9 | January | 2 | 9 + 2 = 11 → 11 - 9 = 2 | 2 | 二黒土星 |
| 5 | June | 8 | 5 + 8 = 13 → 13 - 9 = 4 | 4 | 四緑木星 |

### Limitations & Disclaimer

**This is NOT traditional Kigaku Getsumei calculation.**

Traditional Getsumei requires:
1. Determining the exact solar term (節入り) for each month
2. Using the traditional calendar conversion
3. Complex date-time calculations based on the lunar-solar calendar

**What this MVP provides:**
- A deterministic, simplified monthly star
- Consistent results for the same month
- No dependency on solar terms or complex calendars

**For users:**
- Results are consistent and reproducible
- Suitable for fortune reading entertainment
- Should NOT be used for professional Kigaku consultation
- Clearly labeled as "月命星" (monthly star) in UI

**For future versions:**
- Implement proper solar term calculations
- Use authenticated calendar conversion tables
- Provide traditional Kigaku accuracy

---

## Nine Stars Mapping

| Number | Japanese | Romanization | Element |
|--------|----------|--------------|---------|
| 1 | 一白水星 | Ippaku Suisei | Water |
| 2 | 二黒土星 | Jikoku Dosei | Earth |
| 3 | 三碧木星 | Sanpeki Mokusei | Wood |
| 4 | 四緑木星 | Shiroku Mokusei | Wood |
| 5 | 五黄土星 | Goo Dosei | Earth |
| 6 | 六白金星 | Roppaku Kinsei | Metal |
| 7 | 七赤金星 | Shichiseki Kinsei | Metal |
| 8 | 八白土星 | Happaku Dosei | Earth |
| 9 | 九紫火星 | Kyushi Kasei | Fire |

---

## Implementation in Code

See `Services/KigakuCalculator.swift` for the actual implementation.

### Key Functions

```swift
static func calculate(birthDate: Date) -> KigakuResult
private static func calculateSimplifiedGetsumei(honmei: Int, month: Int) -> Int
private static func getKigakuName(_ number: Int) -> String
```

### Testing

To verify the calculation:
1. Test Risshun boundary (Jan 15, Feb 3, Feb 4, Feb 5)
2. Test honmei formula with known birth dates
3. Test getsumei consistency across months
4. Verify star name mapping (1-9 to Japanese names)

---

## References

### Honmei Formula Source
Standard Kyusei Kigaku formula:
- 11 - (year % 9) with adjustments for values > 9 or == 0

### Risshun Boundary
- Fixed at February 4 (simplified)
- Traditional: Exact moment varies by year (around Feb 3-5)

### Getsumei Note
- This implementation is simplified for MVP
- Traditional calculation requires solar term tables
- Future enhancement should use proper calendar conversion

---

**Last Updated:** 2024-02-08
**Version:** MVP 1.0
**Status:** Deterministic formulas implemented
