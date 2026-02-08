import SwiftUI
import SwiftData

@main
struct KyuuseiKigakuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, Reading.self])
    }
}
