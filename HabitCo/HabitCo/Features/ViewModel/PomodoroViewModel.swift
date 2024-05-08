//
//  PomodoroViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation

@MainActor
final class PomodoroViewModel: ObservableObject {
    
    @Published private(set) var pomodoros: [PomodoroDB]? = []
    @Published private(set) var pomodoro: PomodoroDB? = nil
    @Published private(set) var progress: [CGFloat]? = nil
    @Published private(set) var errorMessage: String? = nil
    
    private var user: UserDB? = nil
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension PomodoroViewModel {
   
    // Create pomodoro
    public func createUserPomodoro(pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, longBreakTime: Int, repeatPomodoro: [Int], reminderPomodoro: Date?){
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let timeString = reminderPomodoro?.dateToString(to: .hourAndMinute)
            try await userManager.createNewPomodoro(userId: userId, pomodoroName: pomodoroName, description: description, label: label, session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderPomodoro: timeString ?? "")
        }
    }
    
    // Get progress for one month
    func getProgressPomodoro(pomodoroId: String, date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            self.progress = try await userManager.getProgressPomodoro(userId: userId, pomodoroId: pomodoroId, month: date.formattedDate(to: .fullMonthName))
        }
    }
    
    // Get pomodoro detail
    public func getPomodoroDetail(pomodoroId: String){
        Task {
            guard let user = self.user else { return }
            guard let pomodoros = self.pomodoros else { return }
            for pomodoro in pomodoros {
                if pomodoro.id == pomodoroId {
                    if let pomodoro = try await userManager.getPomodoroDetail(userId: user.id, pomodoroId: pomodoroId) {
                        self.pomodoro = pomodoro
                    }
                }
            }
        }
    }
    
    public func editPomodoro(pomodoroId: String, pomodoroName: String?, description: String?, label: String?, session: Int?, focusTime: Int?, breakTime: Int?, longBreakTime: Int?, repeatPomodoro: [Int]?, reminderHabit: Date?) {
        Task{
            guard let userId = UserDefaultManager.userID else { return }
            let reminder = reminderHabit?.dateToString(to: .hourAndMinute)
            self.pomodoro = try await userManager.editPomodoro(userId: userId, pomodoroId: pomodoroId, pomodoroName: pomodoroName, description: description, label: label, session: session, focusTime: focusTime, breakTime: breakTime, repeatPomodoro: repeatPomodoro, longBreakTime: longBreakTime, reminderPomodoro: reminder)
        }
    }
    
    // Delete pomodoro
    public func deletePomodoro(pomodoroId: String) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            try await userManager.deletePomodoro(userId: userId, pomodoroId: pomodoroId)
            let currentDate = Date().formattedDate(to: .fullMonthName)
            let hasSubJournalCompleteToday = try await userManager.checkPomodoroSubJournalIsCompleteByDate(userId: userId, pomodoroId: pomodoroId, date: currentDate)
            let isFirstStreak = try await userManager.checkIsFirstStreak(userId: userId)
            if try await !userManager.checkCompletedSubJournal(userId: userId, from: currentDate),
               try await !userManager.checkHasUndoStreak(userId: userId, from: currentDate) {
                if hasSubJournalCompleteToday,
                   isFirstStreak {
                    try await userManager.deleteStreak(userId: userId)
                } else {
                    try await userManager.updateCountStreak(userId: userId, undo: true)
                }
                try await userManager.updateTodayStreak(userId: userId, from: currentDate, isTodayStreak: false)
            }
        }
    }
}
