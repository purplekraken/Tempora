import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColorHex = "6C63FF"
    @State private var selectedDays = [1,2,3,4,5,6,7]
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    let colors = ["6C63FF","E8453C","34C759","FF9500","FF2D55","00C7BE","AF52DE","FF8C42"]
    let icons = ["star.fill","heart.fill","bolt.fill","flame.fill","book.fill","pencil",
                 "dumbbell.fill","figure.run","drop.fill","leaf.fill","moon.fill","sun.max.fill",
                 "music.note","fork.knife","bed.double.fill","brain.head.profile"]
    let weekDays = [(1,"Пн"),(2,"Вт"),(3,"Ср"),(4,"Чт"),(5,"Пт"),(6,"Сб"),(7,"Вс")]

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedDays.isEmpty }
    var habitColor: Color { Color(hex: selectedColorHex) ?? .accentColor }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Превью
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(habitColor.opacity(0.12))
                                .frame(width: 50, height: 50)
                            Image(systemName: selectedIcon)
                                .font(.system(size: 22))
                                .foregroundStyle(habitColor)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(name.isEmpty ? "Название привычки" : name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(name.isEmpty ? .tertiary : .primary)
                            Text("🔥 0 дней подряд")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // Название
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название").font(.headline).padding(.horizontal)
                        TextField("Например: Читать 20 минут", text: $name)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                    }

                    // Иконки
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Иконка").font(.headline).padding(.horizontal)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    withAnimation(.spring(response: 0.2)) { selectedIcon = icon }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon ? habitColor.opacity(0.15) : Color(.secondarySystemBackground))
                                            .frame(height: 44)
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedIcon == icon ? habitColor : .clear, lineWidth: 1.5))
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedIcon == icon ? habitColor : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Цвета
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Цвет").font(.headline).padding(.horizontal)
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { hex in
                                Button {
                                    withAnimation(.spring(response: 0.2)) { selectedColorHex = hex }
                                } label: {
                                    ZStack {
                                        Circle().fill(Color(hex: hex) ?? .blue).frame(width: 36, height: 36)
                                        if selectedColorHex == hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Дни
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Дни недели").font(.headline).padding(.horizontal)
                        HStack(spacing: 6) {
                            ForEach(weekDays, id: \.0) { day, label in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        if selectedDays.contains(day) { selectedDays.removeAll { $0 == day } }
                                        else { selectedDays.append(day) }
                                    }
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(selectedDays.contains(day) ? habitColor : Color(.secondarySystemBackground))
                                        .foregroundStyle(selectedDays.contains(day) ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Напоминание
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Напоминание").font(.headline).padding(.horizontal)
                        VStack(spacing: 0) {
                            Toggle(isOn: $reminderEnabled.animation()) {
                                Label("Включить", systemImage: "bell.fill")
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: reminderEnabled ? 0 : 14))

                            if reminderEnabled {
                                Divider().padding(.horizontal)
                                DatePicker("Время", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 14, bottomTrailingRadius: 14))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Кнопка
                    Button {
                        save()
                    } label: {
                        Text("Создать привычку")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(isValid ? habitColor : Color(.systemGray4))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    .disabled(!isValid)
                    .padding(.bottom, 32)
                }
                .padding(.top)
            }
            .navigationTitle("Новая привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    func save() {
        let habit = HabitModel(name: name.trimmingCharacters(in: .whitespaces), icon: selectedIcon, colorHex: selectedColorHex)
        habit.frequency = selectedDays
        habit.reminderTime = reminderEnabled ? reminderTime : nil
        modelContext.insert(habit)
        if reminderEnabled { NotificationManager.shared.scheduleHabitReminder(habit: habit) }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    AddHabitView().modelContainer(for: HabitModel.self, inMemory: true)
}
