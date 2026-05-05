import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var days: [JournalDayModel]
    @State private var selectedDate = Date()
    @State private var showingDayDetail = false

    let calendar = Calendar.current

    var currentMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
    }

    var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }
        let firstWeekday = (calendar.component(.weekday, from: first) + 5) % 7
        var result: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            result.append(calendar.date(byAdding: .day, value: day - 1, to: first))
        }
        return result
    }

    func journalDay(for date: Date) -> JournalDayModel? {
        let d = calendar.startOfDay(for: date)
        return days.first { calendar.startOfDay(for: $0.date) == d }
    }

    func hasEvents(for date: Date) -> Bool { journalDay(for: date)?.events.isEmpty == false }
    func hasNote(for date: Date) -> Bool { !(journalDay(for: date)?.note.isEmpty ?? true) }

    var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: currentMonth).capitalized
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Хедер
                HStack {
                    Text("Ежедневник")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Spacer()
                    Button {
                        selectedDate = Date()
                    } label: {
                        Text("Сегодня")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 20)

                // Навигация месяца
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(monthTitle).font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Дни недели
                HStack {
                    ForEach(["Пн","Вт","Ср","Чт","Пт","Сб","Вс"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Сетка дней
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(0..<daysInMonth.count, id: \.self) { i in
                        if let date = daysInMonth[i] {
                            DayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                hasEvents: hasEvents(for: date),
                                hasNote: hasNote(for: date)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) { selectedDate = date }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showingDayDetail = true
                                }
                            }
                        } else {
                            Color.clear.frame(height: 44)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // Подсказка снизу
                VStack(spacing: 6) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)
                    Text("Нажми на день чтобы открыть расписание")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .sheet(isPresented: $showingDayDetail) {
            DayDetailView(date: selectedDate)
        }
    }
}

// MARK: - Ячейка дня

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let hasNote: Bool

    var day: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    Circle().fill(Color(.label)).frame(width: 36, height: 36)
                } else if isToday {
                    Circle().stroke(Color(.label), lineWidth: 1.5).frame(width: 36, height: 36)
                }
                Text(day)
                    .font(.system(size: 15, weight: isToday || isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
            }
            .frame(width: 36, height: 36)

            HStack(spacing: 3) {
                if hasEvents { Circle().fill(Color.accentColor).frame(width: 4, height: 4) }
                if hasNote { Circle().fill(Color.orange).frame(width: 4, height: 4) }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [JournalDayModel.self, JournalEventModel.self], inMemory: true)
}
