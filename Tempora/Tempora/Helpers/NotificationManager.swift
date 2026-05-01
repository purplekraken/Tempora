import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            print(granted ? "✅ Уведомления разрешены" : "❌ Запрещены")
        }
    }

    func scheduleHabitReminder(habit: HabitModel) {
        guard let reminderTime = habit.reminderTime else { return }
        cancelHabitReminder(habitId: habit.id)
        let content = UNMutableNotificationContent()
        content.title = "Время для привычки 🎯"
        content.body = habit.name
        content.sound = .default
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelHabitReminder(habitId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habitId.uuidString)"])
    }

    func sendPomodoroComplete(type: SessionType) {
        let content = UNMutableNotificationContent()
        content.title = type == .focus ? "Фокус завершён 🍅" : "Перерыв окончен 💪"
        content.body = type == .focus ? "Заслужил перерыв!" : "Готов к следующей сессии?"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "pomodoro-\(UUID().uuidString)",
            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
