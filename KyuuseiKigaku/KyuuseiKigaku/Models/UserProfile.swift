import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var gender: String
    var birthDate: Date
    var prefecture: String
    var municipality: String
    var locationPermission: Bool

    init(name: String, gender: String, birthDate: Date, prefecture: String, municipality: String, locationPermission: Bool) {
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.prefecture = prefecture
        self.municipality = municipality
        self.locationPermission = locationPermission
    }
}
