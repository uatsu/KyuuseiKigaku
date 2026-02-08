import SwiftUI

struct HistoryDetailView: View {
    let reading: Reading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(I18n.t("category_\(reading.category)"))
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)

                    Spacer()

                    Text(reading.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(I18n.t("detail_message"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(reading.message)
                        .font(.body)
                }

                Divider()

                HStack(spacing: 40) {
                    VStack {
                        Text(I18n.t("result_honmei"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(reading.honmeiNum)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                        Text(reading.honmeiName)
                            .font(.subheadline)
                    }

                    VStack {
                        Text(I18n.t("result_getsumei"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(reading.getsumeiNum)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.purple)
                        Text(reading.getsumeiName)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(I18n.t("result_reading"))
                        .font(.headline)
                    Text(reading.responseText)
                        .font(.body)
                        .lineSpacing(6)
                }

                if !reading.regionSnapshot.isEmpty && reading.regionSnapshot != "Unknown" {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(I18n.t("detail_region"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(reading.regionSnapshot)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(I18n.t("detail_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
