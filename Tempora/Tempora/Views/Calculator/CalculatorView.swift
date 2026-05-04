import SwiftUI

struct CalculatorView: View {
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 100
    @State private var inputAmount = ""
    @State private var showingProfile = false

    var hourlyRate: Double { guard workHoursPerDay > 0 else { return 0 }; return dailyIncome / workHoursPerDay }
    var amount: Double { Double(inputAmount) ?? 0 }
    var hoursOfWork: Double { guard hourlyRate > 0 else { return 0 }; return amount / hourlyRate }
    var daysOfWork: Double { guard workHoursPerDay > 0 else { return 0 }; return hoursOfWork / workHoursPerDay }
    var monthlyIncome: Double { dailyIncome * 22 }
    var percentOfMonth: Double { guard monthlyIncome > 0 else { return 0 }; return amount / monthlyIncome * 100 }

    var motivation: (String, Color) {
        switch amount {
        case 0: return ("Введи сумму", .secondary)
        case ..<10: return ("Стоит потраченного ✅", .green)
        case ..<50: return ("Подумай дважды 🤔", .orange)
        case ..<200: return ("Несколько дней работы 😬", .orange)
        default: return ("Серьёзная трата 💸", .red)
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Хедер
                    HStack {
                        Text("Цена времени")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Spacer()
                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.system(size: 26))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 64)

                    // Профиль карточка
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1 час")
                                .font(.system(size: 13)).foregroundStyle(.secondary)
                            Text("$\(String(format: "%.2f", hourlyRate))")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("в день")
                                .font(.system(size: 13)).foregroundStyle(.secondary)
                            Text("$\(String(format: "%.0f", dailyIncome))")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                    }
                    .padding(18)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)

                    // Ввод суммы
                    VStack(spacing: 8) {
                        Text("Сколько стоит?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        HStack(alignment: .center, spacing: 4) {
                            Text("$")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            TextField("0", text: $inputAmount)
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 16)
                    }

                    // Быстрые суммы
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([5, 10, 25, 50, 100, 200, 500, 1000], id: \.self) { val in
                                Button {
                                    withAnimation(.spring()) { inputAmount = "\(val)" }
                                } label: {
                                    Text("$\(val)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(inputAmount == "\(val)" ? Color(.label) : Color(.secondarySystemBackground))
                                        .foregroundStyle(inputAmount == "\(val)" ? Color(.systemBackground) : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Результаты
                    if amount > 0 {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                CalcResultCard(icon: "clock.fill", color: .blue,
                                    value: String(format: "%.1f ч", hoursOfWork), label: "Часов работы")
                                CalcResultCard(icon: "calendar", color: Color(hex: "6C63FF") ?? .purple,
                                    value: String(format: "%.1f дн", daysOfWork), label: "Рабочих дней")
                            }
                            HStack(spacing: 10) {
                                CalcResultCard(icon: "chart.pie.fill", color: .orange,
                                    value: String(format: "%.1f%%", percentOfMonth), label: "От месяца")
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(motivation.0)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(motivation.1)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 80)
                }
                .animation(.spring(response: 0.4), value: amount)
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSettingsView()
        }
    }
}

struct CalcResultCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 100

    var body: some View {
        NavigationStack {
            Form {
                Section("Рабочий профиль") {
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
                        TextField("100", value: $dailyIncome, format: .number)
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
    CalculatorView()
}
