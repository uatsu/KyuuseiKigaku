import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey: String?

    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }

    func generateReading(category: String, message: String, honmei: String, getsumei: String, region: String) async -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            return generateDummyReading(category: category, honmei: honmei, getsumei: getsumei)
        }

        let prompt = I18n.t("openai_prompt")
            .replacingOccurrences(of: "{category}", with: category)
            .replacingOccurrences(of: "{message}", with: message)
            .replacingOccurrences(of: "{honmei}", with: honmei)
            .replacingOccurrences(of: "{getsumei}", with: getsumei)
            .replacingOccurrences(of: "{region}", with: region)

        do {
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                return generateDummyReading(category: category, honmei: honmei, getsumei: getsumei)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 500,
                "temperature": 0.8
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return generateDummyReading(category: category, honmei: honmei, getsumei: getsumei)
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("OpenAI API error: \(error)")
        }

        return generateDummyReading(category: category, honmei: honmei, getsumei: getsumei)
    }

    private func generateDummyReading(category: String, honmei: String, getsumei: String) -> String {
        let template = I18n.t("dummy_reading_template")
        return template
            .replacingOccurrences(of: "{category}", with: category)
            .replacingOccurrences(of: "{honmei}", with: honmei)
            .replacingOccurrences(of: "{getsumei}", with: getsumei)
    }
}
