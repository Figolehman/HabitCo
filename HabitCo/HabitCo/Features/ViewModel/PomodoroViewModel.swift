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
   
    // Done
    public func createUserPomodoro(pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, longBreakTime: Int, repeatPomodoro: [Int], reminderPomodoro: Date?){
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard !pomodoroName.isEmpty,
                  !description.isEmpty,
                  !label.isEmpty,
                  session != 0,
                  focusTime != 0,
                  breakTime != 0,
                  !repeatPomodoro.isEmpty,
                  reminderPomodoro != nil
            else {
                self.errorMessage = "Please fill all fields"
                return
            }
            let timeString = DateFormatUtil.shared.dateToString(date: reminderPomodoro ?? Date(), to: "HH:mm")
            try await userManager.createNewPomodoro(userId: userId, pomodoroName: pomodoroName, description: description, label: label, session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderPomodoro: timeString)
        }
    }
    
    func getProgressPomodoro(pomodoroId: String) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            self.progress = try await userManager.getProgressPomodoro(userId: userId, pomodoroId: pomodoroId, month: Date().formattedDate(to: .fullMonthName))
        }
    }
    
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
    
    public func deletePomodoro(pomodoroId: String) {
        Task {
            guard let user = self.user else { return }
            try await userManager.deletePomodoro(userId: user.id, pomodoroId: pomodoroId)
        }
    }
}
