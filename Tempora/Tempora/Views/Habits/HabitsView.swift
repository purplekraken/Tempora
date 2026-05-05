import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HabitModel> { !$0.isArchived })
    private var habits: [HabitModel]
    @State private var showingAdd = false

    var completedToday: Int {
        habits.filter { habit in
            let today = Calendar.current.startOfDay(for: Date())
            return habit.completions.contains {
                Calendar.current.startOfDay(for: $0) == today
            }
        }.count
    }

    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Доброе утро" }
        else if h < 18 { return "Добрый день" }
        else { return "Добрый вечер" }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Хедер
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("Привычки")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 64)
                    .padding(.bottom, 24)

                    // Прогресс кольцо
                    HStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 10)
                                .frame(width: 90, height: 90)
                            Circle()
                                .trim(from: 0, to: habits.isEmpty ? 0 : Double(completedToday) / Double(habits.count))
                                .stroke(Color(.label), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 90, height: 90)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6), value: completedToday)
                            VStack(spacing: 0) {
                                Text("\(completedToday)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                Text("из \(habits.count)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            if completedToday == habits.count && habits.count > 0 {
                                Text("Все выполнены! 🎉")
                                    .font(.system(size: 17, weight: .semibold))
                            } else {
                                Text("Осталось \(habits.count - completedToday)")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            Text("привычек на сегодня")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    // Список
                    if habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                                .padding(.top, 48)
                            Text("Нет привычек")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Нажми + чтобы добавить первую")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(habits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitCardView(habit: habit)
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation { modelContext.delete(habit) }
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 80)
                }
            }

            // FAB кнопка
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                            .frame(width: 56, height: 56)
                            .background(Color(.label))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 72)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAdd) {
            AddHabitView()
        }
    }
}

#Preview {
    NavigationStack {
        HabitsView()
    }
    .modelContainer(for: HabitModel.self, inMemory: true)
}
