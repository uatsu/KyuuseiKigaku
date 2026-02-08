import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @StateObject private var locationService = LocationService()

    @State private var name: String = ""
    @State private var gender: String = "male"
    @State private var birthDate: Date = Date()
    @State private var prefecture: String = ""
    @State private var municipality: String = ""
    @State private var useLocation: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(I18n.t("settings_profile_section"))) {
                    TextField(I18n.t("settings_name_label"), text: $name)

                    Picker(I18n.t("settings_gender_label"), selection: $gender) {
                        Text(I18n.t("settings_gender_male")).tag("male")
                        Text(I18n.t("settings_gender_female")).tag("female")
                        Text(I18n.t("settings_gender_other")).tag("other")
                    }

                    DatePicker(
                        I18n.t("settings_birthdate_label"),
                        selection: $birthDate,
                        displayedComponents: .date
                    )
                }

                Section(header: Text(I18n.t("settings_location_section"))) {
                    Toggle(I18n.t("settings_use_location"), isOn: $useLocation)
                        .onChange(of: useLocation) { oldValue, newValue in
                            if newValue {
                                locationService.requestPermission()
                                locationService.getCurrentLocation()
                            }
                        }

                    if useLocation {
                        Button(I18n.t("settings_get_location")) {
                            locationService.getCurrentLocation()
                        }

                        if !locationService.prefecture.isEmpty {
                            Text("\(I18n.t("settings_current_location")): \(locationService.prefecture) \(locationService.municipality)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    TextField(I18n.t("settings_prefecture_label"), text: $prefecture)
                    TextField(I18n.t("settings_municipality_label"), text: $municipality)
                }

                Section(header: Text(I18n.t("settings_language_section"))) {
                    Picker(I18n.t("settings_language_label"), selection: .constant(I18n.getCurrentLocale())) {
                        Text("日本語").tag("ja")
                        Text("English").tag("en")
                        Text("Bahasa Indonesia").tag("id")
                        Text("ภาษาไทย").tag("th")
                    }
                    .onChange(of: I18n.getCurrentLocale()) { oldValue, newValue in
                        I18n.setLocale(newValue)
                    }
                }
            }
            .navigationTitle(I18n.t("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(I18n.t("button_cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(I18n.t("button_save")) {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
            .onChange(of: locationService.prefecture) { oldValue, newValue in
                if useLocation {
                    prefecture = newValue
                }
            }
            .onChange(of: locationService.municipality) { oldValue, newValue in
                if useLocation {
                    municipality = newValue
                }
            }
        }
    }

    private func loadProfile() {
        guard let profile = profiles.first else { return }
        name = profile.name
        gender = profile.gender
        birthDate = profile.birthDate
        prefecture = profile.prefecture
        municipality = profile.municipality
        useLocation = profile.locationPermission
    }

    private func saveProfile() {
        guard let profile = profiles.first else { return }
        profile.name = name
        profile.gender = gender
        profile.birthDate = birthDate
        profile.prefecture = prefecture
        profile.municipality = municipality
        profile.locationPermission = useLocation
        try? modelContext.save()
    }
}
