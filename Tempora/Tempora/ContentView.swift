import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HabitsView()
                .tabItem {
                    Label("Привычки", systemImage: "checkmark.circle.fill")
                }

            Text("Помодоро 🍅")
                .tabItem {
                    Label("Помодоро", systemImage: "timer")
                }

            Text("Цена времени 💰")
                .tabItem {
                    Label("Цена времени", systemImage: "dollarsign.circle.fill")
                }

            Text("Настройки ⚙️")
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
