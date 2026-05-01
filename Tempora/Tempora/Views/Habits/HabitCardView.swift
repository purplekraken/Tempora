import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: HabitModel
    @State private var checkScale: CGFloat = 1.0
    @State private var showGlow = false

    var habitColor: Color { Color(hex: habit.colorHex) ?? Color(.label) }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return habit.completions.contains { Calendar.current.startOfDay(for: $0) == today }
    }

    var streak: Int {
        let calendar = Calendar.current
        var count = 0
        var date = calendar.startOfDay(for: Date())
        while true {
            if habit.completions.contains(where: { calendar.startOfDay(for: $0) == date }) {
                count += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else { break }
        }
        return count
    }

    var last7Days: [Bool] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { days in
            let date = calendar.date(byAdding: .day, value: -days, to: Date())!
            let day = calendar.startOfDay(for: date)
            return habit.completions.contains { calendar.startOfDay(for: $0) == day }
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Иконка
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(habitColor.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: habit.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(habitColor)
            }

            // Инфо
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isCompletedToday ? .secondary : .primary)
                    .strikethrough(isCompletedToday)

                HStack(spacing: 10) {
                    if streak > 0 {
                        HStack(spacing: 3) {
                            Text("🔥")
                                .font(.system(size: 11))
                            Text("\(streak)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                    HStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(last7Days[i] ? habitColor : Color(.systemGray5))
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
                        .fill(isCompletedToday ? habitColor : Color(.systemGray6))
                        .frame(width: 34, height: 34)
                    Circle()
                        .stroke(isCompletedToday ? habitColor : Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                    if isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(checkScale)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    func toggleCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        if isCompletedToday {
            habit.completions.removeAll { Calendar.current.startOfDay(for: $0) == today }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                habit.completions.append(Date())
                checkScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring()) { checkScale = 1.0 }
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
