import SwiftUI

struct SettingsView: View {
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 80
    @AppStorage("focusDuration") private var focusDuration: Int = 25
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 15
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("selectedAccentColor") private var selectedAccentColor: String = "4A90D9"

    let accentColors: [(String, String)] = [
        ("4A90D9", "Синий"),
        ("7B68EE", "Фиолетовый"),
        ("FF6B9D", "Розовый"),
        ("FF9500", "Оранжевый"),
        ("34C759", "Зелёный"),
        ("FF3B30", "Красный")
    ]

    var body: some View {
        NavigationStack {
            Form {

                // Профиль для калькулятора
                Section {
                    HStack {
                        Label("Часов в день", systemImage: "clock.fill")
                        Spacer()
                        TextField("8", value: $workHoursPerDay, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }
                    HStack {
                        Label("Доход в день ($)", systemImage: "dollarsign.circle.fill")
                        Spacer()
                        TextField("80", value: $dailyIncome, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                } header: {
                    Text("💰 Профиль")
                } footer: {
                    Text("Используется в калькуляторе цены времени")
                }

                // Настройки помодоро
                Section {
                    HStack {
                        Label("Фокус", systemImage: "brain.head.profile")
                        Spacer()
                        Stepper("\(focusDuration) мин", value: $focusDuration, in: 5...90, step: 5)
                            .fixedSize()
                    }
                    HStack {
                        Label("Короткий перерыв", systemImage: "cup.and.saucer.fill")
                        Spacer()
                        Stepper("\(shortBreakDuration) мин", value: $shortBreakDuration, in: 1...30, step: 1)
                            .fixedSize()
                    }
                    HStack {
                        Label("Длинный перерыв", systemImage: "bed.double.fill")
                        Spacer()
                        Stepper("\(longBreakDuration) мин", value: $longBreakDuration, in: 5...60, step: 5)
                            .fixedSize()
                    }
                } header: {
                    Text("🍅 Помодоро")
                }

                // Внешний вид
                Section {
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Вибрация", systemImage: "iphone.radiowaves.left.and.right")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Акцентный цвет", systemImage: "paintpalette.fill")
                            .padding(.top, 4)

                        HStack(spacing: 12) {
                            ForEach(accentColors, id: \.0) { hex, name in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedAccentColor = hex
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: hex) ?? .blue)
                                            .frame(width: 36, height: 36)
                                        if selectedAccentColor == hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                } header: {
                    Text("🎨 Внешний вид")
                }

                // О приложении
                Section {
                    HStack {
                        Label("Версия", systemImage: "info.circle.fill")
                        Spacer()
                        Text("Version 0.5.1")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Разработчик", systemImage: "person.fill")
                        Spacer()
                        Text("sigidin")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://apple.com")!) {
                        Label("Написать отзыв", systemImage: "star.fill")
                    }
                } header: {
                    Text("ℹ️ О приложении")
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
