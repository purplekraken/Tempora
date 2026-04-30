import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HabitModel> { !$0.isArchived })
    private var habits: [HabitModel]

    @State private var showingAddHabit = false

    // Считаем сколько привычек выполнено сегодня
    var completedToday: Int {
        habits.filter { habit in
            let today = Calendar.current.startOfDay(for: Date())
            return habit.completions.contains {
                Calendar.current.startOfDay(for: $0) == today
            }
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Прогресс кольцо вверху
                    ProgressRingView(
                        completed: completedToday,
                        total: habits.count
                    )
                    .padding(.top, 8)

                    // Список привычек
                    if habits.isEmpty {
                        EmptyHabitsView()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                modelContext.delete(habit)
                                            }
                                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        NavigationLink(destination: HabitDetailView(habit: habit)) {
                                            Label("Детали", systemImage: "chart.bar.fill")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationTitle(greetingWithDate())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }

    // Приветствие зависит от времени суток
    func greetingWithDate() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        if hour < 12 {
            greeting = "Доброе утро"
        } else if hour < 18 {
            greeting = "Добрый день"
        } else {
            greeting = "Добрый вечер"
        }
        return greeting
    }
}

// MARK: - Прогресс кольцо

struct ProgressRingView: View {
    let completed: Int
    let total: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Фоновый круг
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 14)
                    .frame(width: 120, height: 120)

                // Прогресс круг
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

                // Текст внутри кольца
                VStack(spacing: 2) {
                    Text("\(completed)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("из \(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(completed == total && total > 0 ? "Все привычки выполнены! 🎉" : "привычек сегодня")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Пустой экран

struct EmptyHabitsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
                .padding(.top, 40)

            Text("Нет привычек")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Нажми + чтобы добавить\nсвою первую привычку")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    HabitsView()
        .modelContainer(for: HabitModel.self, inMemory: true)
}
