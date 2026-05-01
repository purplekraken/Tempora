import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    let pages: [OBPage] = [
        OBPage(emoji: "🎯", title: "Строй привычки\nкоторые остаются",
               description: "Отслеживай каждый день, следи за streak и видь прогресс на тепловой карте",
               color: "6C63FF"),
        OBPage(emoji: "📅", title: "Планируй день\nпо часам",
               description: "Ежедневник с расписанием помогает видеть весь день сразу и ничего не забыть",
               color: "34C759"),
        OBPage(emoji: "🍅", title: "Работай в потоке\nс помодоро",
               description: "Фокусируйся на 25 минут, отдыхай 5 минут. Простая техника которая работает",
               color: "E8453C")
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        OBPageView(page: pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(currentPage == i
                                      ? (Color(hex: pages[currentPage].color) ?? .accentColor)
                                      : Color(.systemGray4))
                                .frame(width: currentPage == i ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

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
                    .padding(.horizontal, 24)

                    if currentPage < pages.count - 1 {
                        Button("Пропустить") { hasSeenOnboarding = true }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

struct OBPage {
    let emoji: String
    let title: String
    let description: String
    let color: String
}

struct OBPageView: View {
    let page: OBPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text(page.emoji)
                .font(.system(size: 90))
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.1), value: appeared)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.2), value: appeared)
            }
            Spacer()
            Spacer()
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}

#Preview {
    OnboardingView()
}
