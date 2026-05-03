import Foundation
import UIKit
import SwiftData

@Observable
class PomodoroViewModel {

    var currentSession: SessionType = .focus
    var timeRemaining: Int
    var isRunning = false
    var isPaused = false
    var completedPomodoros = 0
    var currentTaskName = ""
    private var timer: Timer?
    private var modelContext: ModelContext?

    init() {
        timeRemaining = (UserDefaults.standard.integer(forKey: "focusDuration").nonZero ?? 25) * 60
    }

    var focusDuration: Int { (UserDefaults.standard.integer(forKey: "focusDuration").nonZero ?? 25) * 60 }
    var shortBreakDuration: Int { (UserDefaults.standard.integer(forKey: "shortBreakDuration").nonZero ?? 5) * 60 }
    var longBreakDuration: Int { (UserDefaults.standard.integer(forKey: "longBreakDuration").nonZero ?? 15) * 60 }

    var currentDuration: Int {
        switch currentSession {
        case .focus: return focusDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    var progress: Double {
        guard currentDuration > 0 else { return 0 }
        return 1.0 - Double(timeRemaining) / Double(currentDuration)
    }

    var timeString: String {
        String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    func setContext(_ context: ModelContext) { modelContext = context }

    func start() {
        guard !isRunning else { return }
        isRunning = true; isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() { isRunning = false; isPaused = true; timer?.invalidate(); timer = nil }

    func stop() {
        isRunning = false; isPaused = false
        timer?.invalidate(); timer = nil
        timeRemaining = currentDuration
    }

    func skip() {
        timer?.invalidate(); timer = nil
        isRunning = false; isPaused = false
        moveToNext()
    }

    private func tick() {
        guard timeRemaining > 0 else { sessionCompleted(); return }
        timeRemaining -= 1
    }

    private func sessionCompleted() {
        timer?.invalidate(); timer = nil; isRunning = false
        if let context = modelContext {
            let session = PomodoroSessionModel(type: currentSession, duration: currentDuration,
                taskName: currentTaskName.isEmpty ? nil : currentTaskName)
            session.wasCompleted = true
            context.insert(session)
        }
        if currentSession == .focus { completedPomodoros += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        NotificationManager.shared.sendPomodoroComplete(type: currentSession)
        moveToNext()
    }

    private func moveToNext() {
        switch currentSession {
        case .focus:
            if completedPomodoros % 4 == 0 && completedPomodoros > 0 {
                currentSession = .longBreak; timeRemaining = longBreakDuration
            } else {
                currentSession = .shortBreak; timeRemaining = shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentSession = .focus; timeRemaining = focusDuration
        }
    }

    func reset() {
        stop(); completedPomodoros = 0
        currentSession = .focus; timeRemaining = focusDuration
    }
}

extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
