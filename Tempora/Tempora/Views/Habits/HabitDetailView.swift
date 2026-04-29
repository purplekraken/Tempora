import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let habit: HabitModel

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var habitColor: Color {
        Color(hex: habit.colorHex) ?? .accentColor
    }

    var streak: Int {
        let calendar = Calendar.current
        var count = 0
        var checkDate = calendar.startOfDay(for: Date())
        while true {
            let found = habit.completions.contains {
                calendar.startOfDay(for: $0) == checkDate
            }
            if found {
                count += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else { break }
        }
        return count
    }

    var bestStreak: Int {
        guard !habit.completions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedDates = habit.completions
            .map { calendar.startOfDay(for: $0) }
            .sorted()
        var best = 1
        var current = 1
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            if diff == 1 {
                current += 1
                best = max(best, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return best
    }

    // Статистика за период
    func completionRate(days: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var completed = 0
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            if habit.completions.contains(where: { calendar.startOfDay(for: $0) == date }) {
                completed += 1
            }
        }
        return Double(completed) / Double(days) * 100
    }

    // Данные для тепловой карты — последние 15 недель (105 дней)
    var heatmapData: [[Bool?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weeks: [[Bool?]] = []

        for week in (0..<15).reversed() {
            var weekData: [Bool?] = []
            for day in (0..<7).reversed() {
                let totalDays = week * 7 + day
                guard let date = calendar.date(byAdding: .day, value: -totalDays, to: today) else {
                    weekData.append(nil)
                    continue
                }
                if date > today {
                    weekData.append(nil)
                } else if date < habit.createdAt {
                    weekData.append(nil)
                } else {
                    let completed = habit.completions.contains {
                        calendar.startOfDay(for: $0) == date
                    }
                    weekData.append(completed)
                }
            }
            weeks.append(weekData.reversed())
        }
        return weeks
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Заголовок
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(habitColor.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: habit.icon)
                            .font(.system(size: 36))
                            .foregroundStyle(habitColor)
                    }

                    Text(habit.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Streak карточки
                HStack(spacing: 12) {
                    StatCard(
                        title: "Текущий стрик",
                        value: "\(streak)",
                        unit: "дней",
                        icon: "flame.fill",
                        color: .orange
                    )
                    StatCard(
                        title: "Лучший стрик",
                        value: "\(bestStreak)",
                        unit: "дней",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                }
                .padding(.horizontal)

                // Процент выполнения
                VStack(alignment: .leading, spacing: 12) {
                    Text("Статистика выполнения")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        CompletionRateCard(label: "7 дней", rate: completionRate(days: 7), color: habitColor)
                        CompletionRateCard(label: "30 дней", rate: completionRate(days: 30), color: habitColor)
                        CompletionRateCard(label: "90 дней", rate: completionRate(days: 90), color: habitColor)
                    }
                    .padding(.horizontal)
                }

                // Тепловая карта
                VStack(alignment: .leading, spacing: 12) {
                    Text("История")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(0..<heatmapData.count, id: \.self) { weekIndex in
                                VStack(spacing: 4) {
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        let value = heatmapData[weekIndex][dayIndex]
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(
                                                value == nil ? Color.clear :
                                                value == true ? habitColor :
                                                Color(.systemGray5)
                                            )
                                            .frame(width: 16, height: 16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Кнопки действий
                VStack(spacing: 12) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(habitColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Label("Удалить привычку", systemImage: "trash")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        
        
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit)
        }
        .alert("Удалить привычку?", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Все данные о выполнении будут потеряны")
        }
    }
}

// MARK: - Вспомогательные компоненты

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CompletionRateCard: View {
    let label: String
    let rate: Double
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(rate))%")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habit: HabitModel(name: "Читать", icon: "book.fill", colorHex: "34C759"))
    }
    .modelContainer(for: HabitModel.self, inMemory: true)
}
