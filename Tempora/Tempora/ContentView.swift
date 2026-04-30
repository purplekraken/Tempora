import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HabitsView()
                .tabItem {
                    Label("Привычки", systemImage: "checkmark.circle.fill")
                }

            PomodoroView()
                .tabItem {
                    Label("Помодоро", systemImage: "timer")
                }

            PriceCalculatorView()
                .tabItem {
                    Label("Цена времени", systemImage: "dollarsign.circle.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HabitModel.self, inMemory: true)
}

