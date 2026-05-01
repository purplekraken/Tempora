import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let habit: HabitModel
    @State private var showingEdit = false
    @State private var showingDelete = false

    var habitColor: Color { Color(hex: habit.colorHex) ?? Color(.label) }

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

    var bestStreak: Int {
        guard !habit.completions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = habit.completions.map { calendar.startOfDay(for: $0) }.sorted()
        var best = 1; var current = 1
        for i in 1..<sorted.count {
            let diff = calendar.dateComponents([.day], from: sorted[i-1], to: sorted[i]).day ?? 0
            if diff == 1 { current += 1; best = max(best, current) }
            else if diff > 1 { current = 1 }
        }
        return best
    }

    func rate(days: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var done = 0
        for i in 0..<days {
            let d = calendar.date(byAdding: .day, value: -i, to: today)!
            if habit.completions.contains(where: { calendar.startOfDay(for: $0) == d }) { done += 1 }
        }
        return Double(done) / Double(days) * 100
    }

    var heatmap: [[Bool?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weeks: [[Bool?]] = []
        for week in (0..<15).reversed() {
            var weekData: [Bool?] = []
            for day in (0..<7).reversed() {
                let total = week * 7 + day
                guard let date = calendar.date(byAdding: .day, value: -total, to: today) else {
                    weekData.append(nil); continue
                }
                if date > today || date < habit.createdAt {
                    weekData.append(nil)
                } else {
                    weekData.append(habit.completions.contains { calendar.startOfDay(for: $0) == date })
                }
            }
            weeks.append(weekData.reversed())
        }
        return weeks
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // Хедер
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(habitColor.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: habit.icon)
                            .font(.system(size: 34))
                            .foregroundStyle(habitColor)
                    }
                    Text(habit.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                }
                .padding(.top, 24)

                // Streak карточки
                HStack(spacing: 12) {
                    DetailStatCard(icon: "flame.fill", color: .orange, value: "\(streak)", label: "Текущий стрик")
                    DetailStatCard(icon: "trophy.fill", color: .yellow, value: "\(bestStreak)", label: "Лучший стрик")
                }
                .padding(.horizontal, 20)

                // Процент
                HStack(spacing: 12) {
                    DetailRateCard(label: "7 дней", rate: rate(days: 7), color: habitColor)
                    DetailRateCard(label: "30 дней", rate: rate(days: 30), color: habitColor)
                    DetailRateCard(label: "90 дней", rate: rate(days: 90), color: habitColor)
                }
                .padding(.horizontal, 20)

                // Тепловая карта
                VStack(alignment: .leading, spacing: 10) {
                    Text("История")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 3) {
                            ForEach(0..<heatmap.count, id: \.self) { w in
                                VStack(spacing: 3) {
                                    ForEach(0..<7, id: \.self) { d in
                                        let val = heatmap[w][d]
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(val == nil ? Color.clear :
                                                  val == true ? habitColor : Color(.systemGray5))
                                            .frame(width: 14, height: 14)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // Кнопки
                VStack(spacing: 10) {
                    Button {
                        showingEdit = true
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
                        showingDelete = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) { EditHabitView(habit: habit) }
        .alert("Удалить привычку?", isPresented: $showingDelete) {
            Button("Удалить", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Все данные будут потеряны")
        }
    }
}

struct DetailStatCard: View {
    let icon: String; let color: Color; let value: String; let label: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DetailRateCard: View {
    let label: String; let rate: Double; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(rate))%").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(color)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habit: HabitModel(name: "Читать", icon: "book.fill", colorHex: "6C63FF"))
    }
    .modelContainer(for: HabitModel.self, inMemory: true)
}
