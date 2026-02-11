import Foundation

struct KigakuResult {
    let honmeiNum: Int
    let honmeiName: String
    let getsumeiNum: Int
    let getsumeiName: String
}

class KigakuCalculator {
    static func calculate(birthDate: Date) -> KigakuResult {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return KigakuResult(honmeiNum: 1, honmeiName: getKigakuName(1), getsumeiNum: 1, getsumeiName: getKigakuName(1))
        }

        let adjustedYear = getAdjustedYearForRisshun(year: year, month: month, day: day)
        let honmei = calculateHonmei(year: adjustedYear)
        let getsumei = calculateSimplifiedGetsumei(honmei: honmei, month: month)

        return KigakuResult(
            honmeiNum: honmei,
            honmeiName: getKigakuName(honmei),
            getsumeiNum: getsumei,
            getsumeiName: getKigakuName(getsumei)
        )
    }

    private static func getRisshunDay(year: Int) -> Int {
        return 4
    }

    private static func getAdjustedYearForRisshun(year: Int, month: Int, day: Int) -> Int {
        let risshunDay = getRisshunDay(year: year)

        if month < 2 || (month == 2 && day < risshunDay) {
            return year - 1
        } else {
            return year
        }
    }

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

    private static func calculateSimplifiedGetsumei(honmei: Int, month: Int) -> Int {
        let monthOffset = [2, 5, 8, 2, 5, 8, 2, 5, 8, 2, 5, 8]
        let offset = monthOffset[month - 1]
        var getsumei = honmei + offset
        while getsumei > 9 {
            getsumei -= 9
        }
        return getsumei
    }

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
