import SwiftUI

struct SettingsView: View {
    @AppStorage("workHoursPerDay") private var workHoursPerDay: Double = 8
    @AppStorage("dailyIncome") private var dailyIncome: Double = 100
    @AppStorage("focusDuration") private var focusDuration: Int = 25
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 15
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("appTheme") private var appTheme: String = "system"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Хедер
                    Text("Настройки")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 64)

                    // Тема
                    SettingsSection(title: "Внешний вид") {
                        VStack(spacing: 0) {
                            HStack {
                                Label("Тема", systemImage: "circle.lefthalf.filled")
                                    .font(.system(size: 15))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 10)

                            HStack(spacing: 8) {
                                ForEach([("light","Светлая","sun.max.fill"),
                                         ("dark","Тёмная","moon.fill"),
                                         ("system","Авто","iphone")], id: \.0) { val, label, icon in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            appTheme = val
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: icon)
                                                .font(.system(size: 18))
                                            Text(label)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(appTheme == val ? Color(.label) : Color(.systemGray6))
                                        .foregroundStyle(appTheme == val ? Color(.systemBackground) : .secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 14)
                        }

                        Divider().padding(.horizontal, 16)

                        SettingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            iconColor: .blue,
                            title: "Вибрация",
                            isOn: $hapticsEnabled
                        )
                    }

                    // Профиль
                    SettingsSection(title: "Профиль") {
                        SettingsNumberRow(
                            icon: "clock.fill", iconColor: .purple,
                            title: "Часов в день",
                            value: $workHoursPerDay,
                            format: "%.0f ч"
                        )
                        Divider().padding(.horizontal, 16)
                        SettingsNumberRow(
                            icon: "dollarsign.circle.fill", iconColor: .green,
                            title: "Доход в день ($)",
                            value: $dailyIncome,
                            format: "%.0f $"
                        )
                    }

                    // Помодоро
                    SettingsSection(title: "Помодоро") {
                        SettingsStepperRow(
                            icon: "brain.head.profile", iconColor: .red,
                            title: "Фокус",
                            value: $focusDuration,
                            range: 5...90, step: 5, unit: "мин"
                        )
                        Divider().padding(.horizontal, 16)
                        SettingsStepperRow(
                            icon: "cup.and.saucer.fill", iconColor: .orange,
                            title: "Короткий перерыв",
                            value: $shortBreakDuration,
                            range: 1...30, step: 1, unit: "мин"
                        )
                        Divider().padding(.horizontal, 16)
                        SettingsStepperRow(
                            icon: "bed.double.fill", iconColor: Color(hex: "6C63FF") ?? .purple,
                            title: "Длинный перерыв",
                            value: $longBreakDuration,
                            range: 5...60, step: 5, unit: "мин"
                        )
                    }

                    // О приложении
                    SettingsSection(title: "О приложении") {
                        HStack {
                            Label("Версия", systemImage: "info.circle.fill")
                                .font(.system(size: 15))
                            Spacer()
                            Text("x")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 15))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        HStack {
                            Label("Разработчик", systemImage: "person.fill")
                                .font(.system(size: 15))
                            Spacer()
                            Text("sigidin")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 15))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider().padding(.horizontal, 16)

                        Link(destination: URL(string: "https://t.me/yourname")!) {
                            HStack {
                                Label("Написать разработчику", systemImage: "paperplane.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }

                    Spacer(minLength: 80)
                }
            }
        }
    }
}

// MARK: - Компоненты

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(size: 15))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsStepperRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(size: 15))
            Spacer()
            Stepper("\(value) \(unit)", value: $value, in: range, step: step)
                .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsNumberRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var value: Double
    let format: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(size: 15))
            Spacer()
            TextField("", value: $value, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .frame(width: 70)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
}
