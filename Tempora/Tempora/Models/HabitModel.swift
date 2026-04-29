import Foundation
import SwiftData

@Model
class HabitModel {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var frequency: [Int]
    var reminderTime: Date?
    var targetCount: Int
    var completions: [Date]
    var createdAt: Date
    var isArchived: Bool

    init(name: String, icon: String = "star.fill", colorHex: String = "4A90D9") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = [1, 2, 3, 4, 5, 6, 7]
        self.reminderTime = nil
        self.targetCount = 1
        self.completions = []
        self.createdAt = Date()
        self.isArchived = false
    }
}
