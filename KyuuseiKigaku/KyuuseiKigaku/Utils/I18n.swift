import Foundation

class I18n {
    static let shared = I18n()

    private var translations: [String: [String: String]] = [:]
    private var currentLocale: String = "ja"

    private init() {
        loadTranslations()
        detectLocale()
    }

    private func detectLocale() {
        let preferredLanguage = Locale.preferredLanguages.first ?? "ja"
        if preferredLanguage.hasPrefix("en") {
            currentLocale = "en"
        } else if preferredLanguage.hasPrefix("id") {
            currentLocale = "id"
        } else if preferredLanguage.hasPrefix("th") {
            currentLocale = "th"
        } else {
            currentLocale = "ja"
        }
    }

    private func loadTranslations() {
        let locales = ["ja", "en", "id", "th"]

        for locale in locales {
            if let url = Bundle.main.url(forResource: locale, withExtension: "po", subdirectory: "Resources/i18n"),
               let content = try? String(contentsOf: url, encoding: .utf8) {
                translations[locale] = parsePO(content)
            }
        }
    }

    private func parsePO(_ content: String) -> [String: String] {
        var dict: [String: String] = [:]
        let lines = content.components(separatedBy: .newlines)

        var currentMsgid: String?
        var currentMsgstr: String?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("msgid \"") {
                if let msgid = currentMsgid, let msgstr = currentMsgstr, !msgid.isEmpty {
                    dict[msgid] = msgstr
                }
                currentMsgid = extractString(from: trimmed, prefix: "msgid")
                currentMsgstr = nil
            } else if trimmed.hasPrefix("msgstr \"") {
                currentMsgstr = extractString(from: trimmed, prefix: "msgstr")
            } else if trimmed.hasPrefix("\"") && currentMsgstr != nil {
                if let extracted = extractString(from: trimmed, prefix: "") {
                    currentMsgstr? += extracted
                }
            }
        }

        if let msgid = currentMsgid, let msgstr = currentMsgstr, !msgid.isEmpty {
            dict[msgid] = msgstr
        }

        return dict
    }

    private func extractString(from line: String, prefix: String) -> String? {
        var working = line
        if !prefix.isEmpty {
            working = working.replacingOccurrences(of: prefix, with: "")
        }
        working = working.trimmingCharacters(in: .whitespaces)

        if working.hasPrefix("\"") && working.hasSuffix("\"") {
            working = String(working.dropFirst().dropLast())
            return working.replacingOccurrences(of: "\\n", with: "\n")
                         .replacingOccurrences(of: "\\\"", with: "\"")
        }
        return nil
    }

    static func t(_ key: String) -> String {
        if let translation = shared.translations[shared.currentLocale]?[key], !translation.isEmpty {
            return translation
        }
        if let jaTranslation = shared.translations["ja"]?[key], !jaTranslation.isEmpty {
            return jaTranslation
        }
        return key
    }

    static func setLocale(_ locale: String) {
        shared.currentLocale = locale
    }

    static func getCurrentLocale() -> String {
        return shared.currentLocale
    }
}
