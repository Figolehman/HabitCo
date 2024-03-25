//
//  PomodoroViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation

@MainActor
final class PomodoroViewModel: ObservableObject {
    
    @Published private(set) var pomodoros: [Pomodoro]? = []
    @Published private(set) var pomodoro: Pomodoro? = nil
    
    private var user: UserDB? = nil
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
        initUser()
    }
    
}

extension PomodoroViewModel {
    private func initUser(){
        Task{
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            self.user = try await userManager.getUserDB(userId: userAuthInfo.uid)
        }
    }
   
    public func createUserPomodoro(){
        Task {
            guard let user = self.user else { return }
            try await userManager.createNewPomodoro(userId: user.id)
        }
    }
    
    public func getAllPomodoro(date: Date){
        Task{
            guard let user = self.user else { return }
            self.pomodoros = try await userManager.getAllPomodoroByDate(userId: user.id, date: date)
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
