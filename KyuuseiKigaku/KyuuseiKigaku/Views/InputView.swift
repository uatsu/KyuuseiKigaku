import SwiftUI

struct InputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: String = "general"
    @State private var message: String = ""
    @State private var showAd = false

    let categories = ["love", "work", "health", "money", "general"]

    var body: some View {
        Form {
            Section(header: Text(I18n.t("input_category_label"))) {
                Picker(I18n.t("input_category_label"), selection: $category) {
                    Text(I18n.t("category_love")).tag("love")
                    Text(I18n.t("category_work")).tag("work")
                    Text(I18n.t("category_health")).tag("health")
                    Text(I18n.t("category_money")).tag("money")
                    Text(I18n.t("category_general")).tag("general")
                }
                .pickerStyle(.menu)
            }

            Section(header: Text(I18n.t("input_message_label"))) {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
                    .onChange(of: message) { oldValue, newValue in
                        if newValue.count > 200 {
                            message = String(newValue.prefix(200))
                        }
                    }

                Text("\(message.count)/200")
                    .font(.caption)
                    .foregroundColor(message.count >= 200 ? .red : .secondary)
            }

            Section {
                Button(action: {
                    if !message.isEmpty {
                        showAd = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(I18n.t("button_submit"))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(message.isEmpty)
            }
        }
        .navigationTitle(I18n.t("input_nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showAd) {
            FakeAdView(category: category, message: message)
        }
    }
}
