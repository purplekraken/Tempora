import Foundation
import SwiftData

enum SessionType: String, Codable {
    case focus = "focus"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"

    var title: String {
        switch self {
        case .focus: return "Фокус"
        case .shortBreak: return "Короткий перерыв"
        case .longBreak: return "Длинный перерыв"
        }
    }

    var emoji: String {
        switch self {
        case .focus: return "🍅"
        case .shortBreak: return "☕️"
        case .longBreak: return "🛋️"
        }
    }
}

@Model
class PomodoroSessionModel {
    var id: UUID
    var startedAt: Date
    var duration: Int        // в секундах
    var type: SessionType
    var taskName: String?
    var wasCompleted: Bool

    init(type: SessionType, duration: Int, taskName: String? = nil) {
        self.id = UUID()
        self.startedAt = Date()
        self.duration = duration
        self.type = type
        self.taskName = taskName
        self.wasCompleted = false
    }
}
