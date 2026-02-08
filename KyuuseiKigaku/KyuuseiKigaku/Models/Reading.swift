import Foundation
import SwiftData

@Model
final class Reading {
    var createdAt: Date
    var category: String
    var message: String
    var responseText: String
    var honmeiNum: Int
    var honmeiName: String
    var getsumeiNum: Int
    var getsumeiName: String
    var regionSnapshot: String

    init(createdAt: Date, category: String, message: String, responseText: String, honmeiNum: Int, honmeiName: String, getsumeiNum: Int, getsumeiName: String, regionSnapshot: String) {
        self.createdAt = createdAt
        self.category = category
        self.message = message
        self.responseText = responseText
        self.honmeiNum = honmeiNum
        self.honmeiName = honmeiName
        self.getsumeiNum = getsumeiNum
        self.getsumeiName = getsumeiName
        self.regionSnapshot = regionSnapshot
    }
}
