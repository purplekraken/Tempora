import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allDays: [JournalDayModel]
    let date: Date
    @State private var showingAddEvent = false
    @State private var noteText = ""

    let calendar = Calendar.current

    var journalDay: JournalDayModel? {
        allDays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var events: [JournalEventModel] {
        (journalDay?.events ?? []).sorted { a, b in
            a.startHour == b.startHour ? a.startMinute < b.startMinute : a.startHour < b.startHour
        }
    }

    var dayTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM, EEEE"
        return f.string(from: date).capitalized
    }

    var isToday: Bool { calendar.isDateInToday(date) }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Заметка дня
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Заметка")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)

                        TextEditor(text: $noteText)
                            .font(.system(size: 15))
                            .frame(minHeight: 80)
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 16)
                            .onChange(of: noteText) { _, new in
                                saveNote(new)
                            }
                    }

                    // Расписание по часам
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Расписание")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                showingAddEvent = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, 20)

                        if events.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.secondary)
                                Text("Нет событий")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Нажми + чтобы добавить")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(events) { event in
                                    EventRow(event: event, onDelete: {
                                        withAnimation { modelContext.delete(event) }
                                    })
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 16)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .navigationTitle(dayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .onAppear {
            noteText = journalDay?.note ?? ""
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(date: date)
        }
    }

    func saveNote(_ text: String) {
        if let day = journalDay {
            day.note = text
        } else {
            let newDay = JournalDayModel(date: date)
            newDay.note = text
            modelContext.insert(newDay)
        }
    }
}

// MARK: - Строка события

struct EventRow: View {
    let event: JournalEventModel
    let onDelete: () -> Void

    var timeString: String {
        String(format: "%02d:%02d", event.startHour, event.startMinute)
    }

    var endTimeString: String {
        let totalMinutes = event.startHour * 60 + event.startMinute + event.durationMinutes
        return String(format: "%02d:%02d", totalMinutes / 60, totalMinutes % 60)
    }

    var eventColor: Color { Color(hex: event.colorHex) ?? .accentColor }

    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(eventColor)
                .frame(width: 3)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(event.isCompleted)
                    .foregroundStyle(event.isCompleted ? .secondary : .primary)
                Text("\(timeString) – \(endTimeString)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.spring()) {
                    event.isCompleted.toggle()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                ZStack {
                    Circle()
                        .fill(event.isCompleted ? eventColor : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                    if event.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { onDelete() } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

#Preview {
    DayDetailView(date: Date())
        .modelContainer(for: [JournalDayModel.self, JournalEventModel.self], inMemory: true)
}
