import SwiftUI
import SwiftData

@main
struct TemporaApp: App {
    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            HabitModel.self,
            JournalDayModel.self,
            JournalEventModel.self,
            PomodoroSessionModel.self
        ])
    }
}
