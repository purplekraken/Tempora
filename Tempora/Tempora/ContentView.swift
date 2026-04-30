import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HabitsView()
                .tabItem {
                    Label("Привычки", systemImage: "checkmark.circle.fill")
                }
                .tag(0)

            PomodoroView()
                .tabItem {
                    Label("Помодоро", systemImage: "timer")
                }
                .tag(1)

            PriceCalculatorView()
                .tabItem {
                    Label("Цена времени", systemImage: "dollarsign.circle.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HabitModel.self, PomodoroSessionModel.self], inMemory: true)
}
