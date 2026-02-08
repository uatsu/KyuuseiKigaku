import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            HomeView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
        }
        .onAppear {
            if profiles.isEmpty {
                let newProfile = UserProfile(
                    name: "",
                    gender: "male",
                    birthDate: Date(),
                    prefecture: "",
                    municipality: "",
                    locationPermission: false
                )
                modelContext.insert(newProfile)
            }
        }
    }
}
