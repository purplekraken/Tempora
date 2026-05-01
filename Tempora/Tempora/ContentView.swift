import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            MainPageView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
