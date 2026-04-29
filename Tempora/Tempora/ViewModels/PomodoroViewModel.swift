import Foundation
import Combine
import SwiftData

@Observable
class PomodoroViewModel {

    // Настройки длительности (в секундах)
    var focusDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60

    // Состояние таймера
    var currentSession: SessionType = .focus
    var timeRemaining: Int = 25 * 60
    var isRunning: Bool = false
    var isPaused: Bool = false
    var completedPomodoros: Int = 0

    // Текущая задача
    var currentTaskName: String = ""

    // Приватные
    private var timer: Timer?
    private var modelContext: ModelContext?

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // Текущая длительность сессии
    var currentDuration: Int {
        switch currentSession {
        case .focus: return focusDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    // Прогресс от 0 до 1
    var progress: Double {
        guard currentDuration > 0 else { return 0 }
        return 1.0 - Double(timeRemaining) / Double(currentDuration)
    }

    // Форматированное время — 25:00
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Цвет зависит от режима
    var sessionColor: String {
        switch currentSession {
        case .focus: return "FF6B6B"
        case .shortBreak: return "34C759"
        case .longBreak: return "4A90D9"
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        timeRemaining = currentDuration
    }

    func skip() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        moveToNextSession()
    }

    private func tick() {
        guard timeRemaining > 0 else {
            sessionCompleted()
            return
        }
        timeRemaining -= 1
    }

    private func sessionCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false

        // Сохраняем сессию в базу
        if let context = modelContext {
            let session = PomodoroSessionModel(
                type: currentSession,
                duration: currentDuration,
                taskName: currentTaskName.isEmpty ? nil : currentTaskName
            )
            session.wasCompleted = true
            context.insert(session)
        }

        // Считаем помодоро
        if currentSession == .focus {
            completedPomodoros += 1
        }

        // Haptic
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        moveToNextSession()
    }

    private func moveToNextSession() {
        switch currentSession {
        case .focus:
            // После каждых 4 помодоро — длинный перерыв
            if completedPomodoros % 4 == 0 && completedPomodoros > 0 {
                currentSession = .longBreak
                timeRemaining = longBreakDuration
            } else {
                currentSession = .shortBreak
                timeRemaining = shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentSession = .focus
            timeRemaining = focusDuration
        }
    }

    func reset() {
        stop()
        completedPomodoros = 0
        currentSession = .focus
        timeRemaining = focusDuration
    }
}
