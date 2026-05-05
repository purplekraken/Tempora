import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") private var appTheme: String = "system"

    var colorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainPageView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
}
