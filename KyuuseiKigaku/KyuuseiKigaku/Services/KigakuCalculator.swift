import Foundation

struct KigakuResult {
    let honmeiNum: Int
    let honmeiName: String
    let getsumeiNum: Int
    let getsumeiName: String
}

class KigakuCalculator {
    static func calculate(birthDate: Date) -> KigakuResult {
        var calendar = Calendar(identifier: .gregorian)
        if let jst = TimeZone(identifier: "Asia/Tokyo") {
            calendar.timeZone = jst
        }
        let components = calendar.dateComponents([.year, .month], from: birthDate)

        guard let year = components.year,
              let month = components.month else {
            return KigakuResult(honmeiNum: 1, honmeiName: getKigakuName(1), getsumeiNum: 1, getsumeiName: getKigakuName(1))
        }

        let kigakuYear = determineKigakuYear(birthDate: birthDate, birthYear: year)
        let honmei = calculateHonmei(year: kigakuYear)
        let getsumei = calculateSimplifiedGetsumei(honmei: honmei, month: month)

        return KigakuResult(
            honmeiNum: honmei,
            honmeiName: getKigakuName(honmei),
            getsumeiNum: getsumei,
            getsumeiName: getKigakuName(getsumei)
        )
    }

    private static func determineKigakuYear(birthDate: Date, birthYear: Int) -> Int {
        guard let risshunDate = RisshunProvider.risshunDate(for: birthYear) else {
            return birthYear
        }

        if birthDate < risshunDate {
            return birthYear - 1
        } else {
            return birthYear
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
