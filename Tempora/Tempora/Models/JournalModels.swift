import Foundation
import SwiftData

@Model
class JournalDayModel {
    var id: UUID
    var date: Date
    var note: String
    var mood: Int        // 1-5
    var events: [JournalEventModel]

    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.note = ""
        self.mood = 0
        self.events = []
    }
}

@Model
class JournalEventModel {
    var id: UUID
    var title: String
    var startHour: Int       // 0-23
    var startMinute: Int
    var durationMinutes: Int
    var colorHex: String
    var isCompleted: Bool
    var date: Date

    init(title: String, startHour: Int, startMinute: Int = 0, durationMinutes: Int = 60, colorHex: String = "6C63FF", date: Date) {
        self.id = UUID()
        self.title = title
        self.startHour = startHour
        self.startMinute = startMinute
        self.durationMinutes = durationMinutes
        self.colorHex = colorHex
        self.isCompleted = false
        self.date = Calendar.current.startOfDay(for: date)
    }
}
