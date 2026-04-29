import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: HabitModel

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String
    @State private var selectedDays: [Int]

    let colors: [(String, String)] = [
        ("4A90D9", "Синий"), ("7B68EE", "Фиолетовый"), ("FF6B9D", "Розовый"),
        ("FF9500", "Оранжевый"), ("34C759", "Зелёный"), ("00C7BE", "Бирюзовый"),
        ("FF3B30", "Красный"), ("5856D6", "Индиго"), ("FF2D55", "Малиновый"),
        ("AF52DE", "Пурпурный"), ("FFD60A", "Жёлтый"), ("8E8E93", "Серый")
    ]

    let icons = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "pencil", "dumbbell.fill", "figure.run",
        "drop.fill", "leaf.fill", "moon.fill", "sun.max.fill",
        "music.note", "paintbrush.fill", "fork.knife", "bed.double.fill",
        "brain.head.profile", "pills.fill", "bicycle", "figure.yoga"
    ]

    let weekDays = [
        (1, "Пн"), (2, "Вт"), (3, "Ср"),
        (4, "Чт"), (5, "Пт"), (6, "Сб"), (7, "Вс")
    ]

    // Инициализатор заполняет поля из существующей привычки
    init(habit: HabitModel) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedIcon = State(initialValue: habit.icon)
        _selectedColorHex = State(initialValue: habit.colorHex)
        _selectedDays = State(initialValue: habit.frequency)
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedDays.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Превью
                    previewCard

                    // Название
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название")
                            .font(.headline)
                            .padding(.horizontal)

                        TextField("Название привычки", text: $name)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }

                    // Иконка
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Иконка")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedIcon = icon
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedIcon == icon
                                                  ? (Color(hex: selectedColorHex) ?? .accentColor).opacity(0.2)
                                                  : Color(.secondarySystemBackground))
                                            .frame(height: 52)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedIcon == icon
                                                            ? (Color(hex: selectedColorHex) ?? .accentColor)
                                                            : .clear, lineWidth: 2)
                                            )
                                        Image(systemName: icon)
                                            .font(.system(size: 22))
                                            .foregroundStyle(selectedIcon == icon
                                                             ? (Color(hex: selectedColorHex) ?? .accentColor)
                                                             : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Цвет
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Цвет")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(colors, id: \.0) { hex, _ in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedColorHex = hex
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: hex) ?? .blue)
                                            .frame(width: 40, height: 40)
                                        if selectedColorHex == hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Дни недели
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Дни недели")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 8) {
                            ForEach(weekDays, id: \.0) { day, label in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if selectedDays.contains(day) {
                                            selectedDays.removeAll { $0 == day }
                                        } else {
                                            selectedDays.append(day)
                                        }
                                    }
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedDays.contains(day)
                                            ? (Color(hex: selectedColorHex) ?? .accentColor)
                                            : Color(.secondarySystemBackground)
                                        )
                                        .foregroundStyle(selectedDays.contains(day) ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Сохранить
                    Button {
                        saveChanges()
                    } label: {
                        Text("Сохранить изменения")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isFormValid
                                ? (Color(hex: selectedColorHex) ?? .accentColor)
                                : Color(.systemGray4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    .disabled(!isFormValid)
                    .padding(.bottom, 32)
                }
                .padding(.top)
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    var previewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill((Color(hex: selectedColorHex) ?? .accentColor).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: selectedIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(Color(hex: selectedColorHex) ?? .accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Название привычки" : name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(name.isEmpty ? .tertiary : .primary)
                Text("🔥 \(habit.completions.count) выполнений")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    func saveChanges() {
        habit.name = name.trimmingCharacters(in: .whitespaces)
        habit.icon = selectedIcon
        habit.colorHex = selectedColorHex
        habit.frequency = selectedDays
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    EditHabitView(habit: HabitModel(name: "Читать", icon: "book.fill", colorHex: "34C759"))
        .modelContainer(for: HabitModel.self, inMemory: true)
}
