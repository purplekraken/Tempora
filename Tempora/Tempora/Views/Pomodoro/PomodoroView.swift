import SwiftUI
import SwiftData

struct PomodoroView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = PomodoroViewModel()
    @Query private var allSessions: [PomodoroSessionModel]

    var todaySessions: [PomodoroSessionModel] {
        let today = Calendar.current.startOfDay(for: Date())
        return allSessions.filter {
            Calendar.current.startOfDay(for: $0.startedAt) == today && $0.wasCompleted
        }
    }

    var focusToday: Int { todaySessions.filter { $0.type == .focus }.count }

    var sessionColor: Color {
        switch vm.currentSession {
        case .focus: return Color(hex: "E8453C") ?? .red
        case .shortBreak: return Color(hex: "34C759") ?? .green
        case .longBreak: return Color(hex: "6C63FF") ?? .purple
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Хедер
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Помодоро")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    if focusToday > 0 {
                        HStack(spacing: 4) {
                            Text("🍅")
                            Text("\(focusToday)")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 24)

                // Режим чипы
                HStack(spacing: 10) {
                    ForEach([SessionType.focus, .shortBreak, .longBreak], id: \.self) { type in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                vm.stop()
                                vm.currentSession = type
                                vm.timeRemaining = vm.currentDuration
                            }
                        } label: {
                            Text(type.title)
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(vm.currentSession == type ? Color(.label) : Color(.secondarySystemBackground))
                                .foregroundStyle(vm.currentSession == type ? Color(.systemBackground) : .secondary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Таймер кольцо
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 14)
                        .frame(width: 240, height: 240)

                    Circle()
                        .trim(from: 0, to: vm.progress)
                        .stroke(sessionColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: vm.progress)

                    VStack(spacing: 6) {
                        Text(vm.timeString)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .monospacedDigit()

                        Text(vm.currentSession.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 28)

                // Помидорки прогресс
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { i in
                        Text(i < (vm.completedPomodoros % 4) ? "🍅" : "⬜️")
                            .font(.system(size: 20))
                    }
                }
                .padding(.bottom, 24)

                // Поле задачи
                TextField("Над чем работаешь?", text: $vm.currentTaskName)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                // Кнопки
                HStack(spacing: 20) {
                    Button {
                        withAnimation(.spring()) { vm.stop() }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 54, height: 54)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation(.spring()) {
                            vm.isRunning ? vm.pause() : vm.start()
                        }
                    } label: {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 76)
                            .background(sessionColor)
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation(.spring()) { vm.skip() }
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 54, height: 54)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }

                Spacer()
            }
        }
        .onAppear { vm.setContext(modelContext) }
    }
}

#Preview {
    PomodoroView()
        .modelContainer(for: PomodoroSessionModel.self, inMemory: true)
}
