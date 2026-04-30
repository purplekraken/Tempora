import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    // Запрашиваем разрешение на уведомления
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("✅ Уведомления разрешены")
            } else {
                print("❌ Уведомления запрещены")
            }
        }
    }

    // Планируем уведомление для привычки
    func scheduleHabitReminder(habit: HabitModel) {
        guard let reminderTime = habit.reminderTime else { return }

        // Удаляем старое уведомление для этой привычки
        cancelHabitReminder(habitId: habit.id)

        let content = UNMutableNotificationContent()
        content.title = "Время для привычки 🎯"
        content.body = "Не забудь: \(habit.name)"
        content.sound = .default
        content.badge = 1

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        // Повторяем каждый день в указанное время
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка уведомления: \(error)")
            }
        }
    }

    // Отменяем уведомление привычки
    func cancelHabitReminder(habitId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habitId.uuidString)"]
        )
    }

    // Уведомление о том что streak под угрозой
    func scheduleStreakWarning(habit: HabitModel) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak под угрозой!"
        content.body = "\(habit.name) — осталось мало времени"
        content.sound = .default

        // Срабатывает в 20:00
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "streak-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // Уведомление что помодоро завершён
    func sendPomodoroComplete(type: SessionType) {
        let content = UNMutableNotificationContent()

        switch type {
        case .focus:
            content.title = "Фокус завершён! 🍅"
            content.body = "Отличная работа! Заслужил перерыв"
        case .shortBreak:
            content.title = "Перерыв окончен ☕️"
            content.body = "Готов к следующей сессии? Погнали!"
        case .longBreak:
            content.title = "Длинный перерыв окончен 💪"
            content.body = "Ты отдохнул — время фокусироваться"
        }

        content.sound = .default

        // Отправляем немедленно
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "pomodoro-complete-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
