import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🎯",
            title: "Строй привычки\nкоторые остаются",
            description: "Отслеживай привычки каждый день, следи за streak и видь свой прогресс на тепловой карте",
            color: "4A90D9"
        ),
        OnboardingPage(
            emoji: "🍅",
            title: "Работай в потоке\nс помодоро",
            description: "Фокусируйся на 25 минут, отдыхай 5 минут. Простая техника которая реально работает",
            color: "FF6B6B"
        ),
        OnboardingPage(
            emoji: "💰",
            title: "Узнай цену\nсвоего времени",
            description: "Введи свой доход и узнай сколько часов работы стоит любая покупка",
            color: "34C759"
        )
    ]

    var body: some View {
        ZStack {
            // Фон меняется по странице
            Color(hex: pages[currentPage].color)?.opacity(0.08)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentPage)

            VStack(spacing: 0) {
                // Страницы
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Нижняя часть
                VStack(spacing: 24) {
                    // Точки прогресса
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index
                                      ? (Color(hex: pages[currentPage].color) ?? .accentColor)
                                      : Color(.systemGray4))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Кнопка
                    Button {
                        withAnimation(.spring()) {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Далее" : "Начать")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: pages[currentPage].color) ?? .accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }

                    // Пропустить
                    if currentPage < pages.count - 1 {
                        Button("Пропустить") {
                            hasSeenOnboarding = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Страница онбординга

struct OnboardingPageView: View {
    let page: OnboardingPage

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Большой эмодзи с анимацией
            Text(page.emoji)
                .font(.system(size: 100))
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1.0 : 0)
                    .animation(.spring(response: 0.6).delay(0.1), value: appeared)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1.0 : 0)
                    .animation(.spring(response: 0.6).delay(0.2), value: appeared)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

// MARK: - Модель страницы

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let color: String
}

#Preview {
    OnboardingView()
}
