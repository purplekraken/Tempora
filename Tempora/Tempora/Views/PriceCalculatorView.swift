import SwiftUI

struct PriceCalculatorView: View {
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 80

    @State private var inputAmount: String = ""
    @State private var showingSettings = false

    var hourlyRate: Double {
        guard workHoursPerDay > 0 else { return 0 }
        return dailyIncome / workHoursPerDay
    }

    var minuteRate: Double {
        hourlyRate / 60
    }

    var monthlyIncome: Double {
        dailyIncome * 22 // рабочих дней в месяце
    }

    var amount: Double {
        Double(inputAmount) ?? 0
    }

    var hoursOfWork: Double {
        guard hourlyRate > 0 else { return 0 }
        return amount / hourlyRate
    }

    var daysOfWork: Double {
        guard workHoursPerDay > 0 else { return 0 }
        return hoursOfWork / workHoursPerDay
    }

    var percentOfMonth: Double {
        guard monthlyIncome > 0 else { return 0 }
        return amount / monthlyIncome * 100
    }

    var motivationalMessage: (String, Color) {
        switch amount {
        case 0: return ("Введи сумму для расчёта", .secondary)
        case ..<10: return ("Стоит потраченного ✅", .green)
        case ..<50: return ("Полдня работы — подумай дважды 🤔", .orange)
        case ..<200: return ("Несколько дней твоей жизни 😬", .orange)
        default: return ("Это серьёзная инвестиция 💸", .red)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Твой профиль
                    profileCard

                    // Большое поле ввода
                    VStack(spacing: 8) {
                        Text("Сколько стоит?")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text("$")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)

                            TextField("0", text: $inputAmount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)

                    // Результаты
                    if amount > 0 {
                        VStack(spacing: 12) {
                            ResultCard(
                                icon: "clock.fill",
                                color: .blue,
                                label: "Часов работы",
                                value: String(format: "%.1f ч", hoursOfWork)
                            )
                            ResultCard(
                                icon: "calendar",
                                color: .purple,
                                label: "Рабочих дней",
                                value: String(format: "%.1f дн", daysOfWork)
                            )
                            ResultCard(
                                icon: "chart.pie.fill",
                                color: .orange,
                                label: "От месячного дохода",
                                value: String(format: "%.1f%%", percentOfMonth)
                            )
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                        // Мотивационная фраза
                        Text(motivationalMessage.0)
                            .font(.headline)
                            .foregroundStyle(motivationalMessage.1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity)
                    }

                    // Быстрые суммы
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Быстрый ввод")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach([10, 25, 50, 100, 200, 500, 1000], id: \.self) { value in
                                    Button {
                                        withAnimation(.spring()) {
                                            inputAmount = "\(value)"
                                        }
                                    } label: {
                                        Text("$\(value)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                inputAmount == "\(value)"
                                                ? Color.accentColor
                                                : Color(.secondarySystemBackground)
                                            )
                                            .foregroundStyle(
                                                inputAmount == "\(value)" ? .white : .primary
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
                .animation(.spring(response: 0.4), value: amount)
            }
            .navigationTitle("Цена времени")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                PriceSettingsView()
            }
        }
    }

    // Карточка профиля вверху
    var profileCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("1 час = $\(String(format: "%.2f", hourlyRate))")
                    .font(.headline)
                Text("1 мин = $\(String(format: "%.2f", minuteRate))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.0f", dailyIncome))/день")
                    .font(.headline)
                Text("\(String(format: "%.0f", workHoursPerDay)) часов работы")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Карточка результата

struct ResultCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Настройки профиля

struct PriceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 80

    var body: some View {
        NavigationStack {
            Form {
                Section("Твой рабочий профиль") {
                    HStack {
                        Label("Часов в день", systemImage: "clock")
                        Spacer()
                        TextField("8", value: $workHoursPerDay, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }

                    HStack {
                        Label("Доход в день ($)", systemImage: "dollarsign.circle")
                        Spacer()
                        TextField("80", value: $dailyIncome, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }
                }

                Section("Итого") {
                    HStack {
                        Text("Стоимость часа")
                        Spacer()
                        Text("$\(String(format: "%.2f", dailyIncome / max(workHoursPerDay, 1)))")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Доход в месяц")
                        Spacer()
                        Text("$\(String(format: "%.0f", dailyIncome * 22))")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PriceCalculatorView()
}
