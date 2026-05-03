import SwiftUI
import SwiftData

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allDays: [JournalDayModel]
    let date: Date

    @State private var title = ""
    @State private var startHour = 9
    @State private var startMinute = 0
    @State private var duration = 60
    @State private var selectedColor = "6C63FF"

    let colors = ["6C63FF","E8453C","34C759","FF9500","FF2D55","00C7BE","AF52DE","FF8C42"]
    let durations = [(15,"15 мин"),(30,"30 мин"),(60,"1 час"),(90,"1.5 ч"),(120,"2 часа")]
    let calendar = Calendar.current

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var journalDay: JournalDayModel? {
        allDays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Например: Встреча с командой", text: $title)
                }

                Section("Время начала") {
                    HStack {
                        Picker("Час", selection: $startHour) {
                            ForEach(0..<24) { Text(String(format: "%02d", $0)).tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Text(":")
                            .font(.title2).fontWeight(.semibold)

                        Picker("Минуты", selection: $startMinute) {
                            ForEach([0,15,30,45], id: \.self) {
                                Text(String(format: "%02d", $0)).tag($0)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 120)
                }

                Section("Длительность") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(durations, id: \.0) { mins, label in
                                Button {
                                    duration = mins
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(duration == mins ? Color(.label) : Color(.secondarySystemBackground))
                                        .foregroundStyle(duration == mins ? Color(.systemBackground) : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Цвет") {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            Button {
                                selectedColor = hex
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: hex) ?? .blue)
                                        .frame(width: 32, height: 32)
                                    if selectedColor == hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Новое событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        save()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    func save() {
        let event = JournalEventModel(
            title: title.trimmingCharacters(in: .whitespaces),
            startHour: startHour,
            startMinute: startMinute,
            durationMinutes: duration,
            colorHex: selectedColor,
            date: date
        )

        if let day = journalDay {
            day.events.append(event)
        } else {
            let newDay = JournalDayModel(date: date)
            newDay.events.append(event)
            modelContext.insert(newDay)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    AddEventView(date: Date())
        .modelContainer(for: [JournalDayModel.self, JournalEventModel.self], inMemory: true)
}
