import SwiftUI

struct MainPageView: View {
    @State private var currentPage = 1

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                JournalView()
                    .tag(0)
                NavigationStack {
                    HabitsView()
                }
                .tag(1)
                PomodoroView()
                    .tag(2)
                Text("Калькулятор 💰")
                    .tag(3)
                Text("Настройки ⚙️")
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            HStack(spacing: 6) {
                ForEach(0..<5) { i in
                    Capsule()
                        .fill(currentPage == i ? Color(.label) : Color(.systemGray4))
                        .frame(width: currentPage == i ? 20 : 6, height: 6)
                        .animation(.spring(response: 0.3), value: currentPage)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4)) { currentPage = i }
                        }
                }
            }
            .padding(.bottom, 48)
        }
        .onChange(of: currentPage) { _, _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

#Preview {
    MainPageView()
}
