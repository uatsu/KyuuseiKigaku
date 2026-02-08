import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reading.createdAt, order: .reverse) private var readings: [Reading]

    var body: some View {
        Group {
            if readings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text(I18n.t("history_empty"))
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(readings) { reading in
                        NavigationLink(destination: HistoryDetailView(reading: reading)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(I18n.t("category_\(reading.category)"))
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(4)

                                    Spacer()

                                    Text(reading.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text(reading.message)
                                    .font(.body)
                                    .lineLimit(2)

                                HStack {
                                    Text("\(reading.honmeiName) / \(reading.getsumeiName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteReadings)
                }
            }
        }
        .navigationTitle(I18n.t("history_title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteReadings(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(readings[index])
        }
        try? modelContext.save()
    }
}
