import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: HabitModel

    @State private var checkmarkScale: CGFloat = 1.0
    @State private var cardOffset: CGFloat = 0
    @State private var showGlow = false

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return habit.completions.contains {
            Calendar.current.startOfDay(for: $0) == today
        }
    }

    // Streak — количество дней подряд
    var streak: Int {
        guard !habit.completions.isEmpty else { return 0 }
        let calendar = Calendar.current
        var count = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let completedOnDay = habit.completions.contains {
                calendar.startOfDay(for: $0) == checkDate
            }
            if completedOnDay {
                count += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return count
    }

    // Последние 7 дней для прогресс баров
    var last7Days: [Bool] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let day = calendar.startOfDay(for: date)
            return habit.completions.contains {
                calendar.startOfDay(for: $0) == day
            }
        }
    }

    var habitColor: Color {
        Color(hex: habit.colorHex) ?? .accentColor
    }

    var body: some View {
        HStack(spacing: 14) {

            // Иконка привычки
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(habitColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: habit.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(habitColor)
            }

            // Название + streak + 7 дней
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isCompletedToday ? .secondary : .primary)
                    .strikethrough(isCompletedToday, color: .secondary)

                HStack(spacing: 8) {
                    // Streak
                    if streak > 0 {
                        HStack(spacing: 3) {
                            Text("🔥")
                                .font(.caption)
                            Text("\(streak)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        }
                    }

                    // 7 кружочков
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            Circle()
                                .fill(last7Days[index] ? habitColor : Color(.systemGray5))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }

            Spacer()

            // Чекбокс
            Button {
                toggleCompletion()
            } label: {
                ZStack {
                    Circle()
                        .fill(isCompletedToday ? habitColor : Color(.systemGray5))
                        .frame(width: 32, height: 32)

                    if isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(checkmarkScale)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: showGlow ? habitColor.opacity(0.3) : .black.opacity(0.06),
                    radius: showGlow ? 12 : 8,
                    x: 0, y: 2
                )
        )
        .offset(x: cardOffset)
    }

    func toggleCompletion() {
        let today = Calendar.current.startOfDay(for: Date())

        if isCompletedToday {
            // Убираем выполнение
            habit.completions.removeAll {
                Calendar.current.startOfDay(for: $0) == today
            }
        } else {
            // Отмечаем выполненным с анимацией
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                habit.completions.append(Date())
                checkmarkScale = 1.3
                showGlow = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring()) {
                    checkmarkScale = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showGlow = false
                }
            }
            // Haptic
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
