import SwiftUI
import SwiftData

struct ResultView: View {
    let category: String
    let message: String

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var isLoading = true
    @State private var kigakuResult: KigakuResult?
    @State private var fortuneText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                    Text(I18n.t("result_loading"))
                        .foregroundColor(.secondary)
                        .padding()
                } else if let result = kigakuResult {
                    VStack(spacing: 16) {
                        Text(I18n.t("result_title"))
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        HStack(spacing: 40) {
                            VStack {
                                Text(I18n.t("result_honmei"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(result.honmeiNum)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.blue)
                                Text(result.honmeiName)
                                    .font(.headline)
                            }

                            VStack {
                                Text(I18n.t("result_getsumei"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(result.getsumeiNum)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.purple)
                                Text(result.getsumeiName)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Text(I18n.t("result_reading"))
                                .font(.headline)

                            Text(fortuneText)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HomeView()) {
                    Text(I18n.t("button_back_home"))
                }
            }
        }
        .task {
            await loadReading()
        }
    }

    private func loadReading() async {
        guard let profile = profiles.first else {
            isLoading = false
            return
        }

        let result = KigakuCalculator.calculate(birthDate: profile.birthDate)
        kigakuResult = result

        let region = "\(profile.prefecture) \(profile.municipality)".trimmingCharacters(in: .whitespaces)
        let regionText = region.isEmpty ? "Unknown" : region

        fortuneText = await OpenAIService.shared.generateReading(
            category: I18n.t("category_\(category)"),
            message: message,
            honmei: result.honmeiName,
            getsumei: result.getsumeiName,
            region: regionText
        )

        let reading = Reading(
            createdAt: Date(),
            category: category,
            message: message,
            responseText: fortuneText,
            honmeiNum: result.honmeiNum,
            honmeiName: result.honmeiName,
            getsumeiNum: result.getsumeiNum,
            getsumeiName: result.getsumeiName,
            regionSnapshot: regionText
        )

        modelContext.insert(reading)
        try? modelContext.save()

        isLoading = false
    }
}
