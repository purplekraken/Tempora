import SwiftUI
import SwiftData

@main
struct TemporaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [HabitModel.self, PomodoroSessionModel.self])
    }
}
