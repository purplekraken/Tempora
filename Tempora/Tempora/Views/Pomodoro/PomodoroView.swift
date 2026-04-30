import SwiftUI
import SwiftData

struct PomodoroView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PomodoroViewModel()

    var sessionColor: Color {
        Color(hex: viewModel.sessionColor) ?? .red
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {

                Spacer()

                // Режим сессии
                VStack(spacing: 8) {
                    Text(viewModel.currentSession.emoji)
                        .font(.system(size: 40))
                    Text(viewModel.currentSession.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                // Круговой таймер
                ZStack {
                    // Фоновый круг
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 16)
                        .frame(width: 260, height: 260)

                    // Прогресс
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            sessionColor,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.progress)

                    // Время внутри
                    VStack(spacing: 4) {
                        Text(viewModel.timeString)
                            .font(.system(size: 58, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        if !viewModel.currentTaskName.isEmpty {
                            Text(viewModel.currentTaskName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                // Счётчик помодоро 🍅
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Text(index < (viewModel.completedPomodoros % 4) ? "🍅" : "⬜️")
                            .font(.title3)
                    }
                }

                // Поле задачи
                TextField("Над чем работаешь?", text: $viewModel.currentTaskName)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 32)

                // Кнопки управления
                HStack(spacing: 20) {

                    // Стоп
                    Button {
                        withAnimation(.spring()) {
                            viewModel.stop()
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 56, height: 56)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }

                    // Старт / Пауза — большая кнопка
                    Button {
                        withAnimation(.spring()) {
                            if viewModel.isRunning {
                                viewModel.pause()
                            } else {
                                viewModel.start()
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 80, height: 80)
                            .background(sessionColor)
                            .clipShape(Circle())
                            .shadow(color: sessionColor.opacity(0.4), radius: 12, x: 0, y: 4)
                    }

                    // Пропустить
                    Button {
                        withAnimation(.spring()) {
                            viewModel.skip()
                        }
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 56, height: 56)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }

                Spacer()

                // История сессий сегодня
                TodaySessionsView()
            }
            .navigationTitle("Помодоро")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.setContext(modelContext)
            }
        }
    }
}

// MARK: - История сессий сегодня

struct TodaySessionsView: View {
    @Query private var allSessions: [PomodoroSessionModel]

    var todaySessions: [PomodoroSessionModel] {
        let today = Calendar.current.startOfDay(for: Date())
        return allSessions.filter {
            Calendar.current.startOfDay(for: $0.startedAt) == today
        }.reversed()
    }

    var focusCount: Int {
        todaySessions.filter { $0.type == .focus && $0.wasCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !todaySessions.isEmpty {
                HStack {
                    Text("Сегодня")
                        .font(.headline)
                    Spacer()
                    Text("🍅 \(focusCount) помодоро")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(todaySessions) { session in
                            SessionChip(session: session)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 16)
    }
}

struct SessionChip: View {
    let session: PomodoroSessionModel

    var body: some View {
        HStack(spacing: 6) {
            Text(session.type.emoji)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text(session.type.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("\(session.duration / 60) мин")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    PomodoroView()
        .modelContainer(for: PomodoroSessionModel.self, inMemory: true)
}
