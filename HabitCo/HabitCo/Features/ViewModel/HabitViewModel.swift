//
//  HabitViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    
    @Published private(set) var habits: [Habit]? = []
    @Published private(set) var habit: Habit? = nil
    
    private var journal: Journal? = nil
    private var user: UserDB? = nil
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
        initUser()
    }
    
}

extension HabitViewModel {
    private func initUser(){
        Task{
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            self.user = try await userManager.getUserDB(userId: userAuthInfo.uid)
        }
        initJournal()
    }
    
    private func initJournal(){
        Task{
            guard let user = self.user else { return }
            self.journal = try await userManager.getDetailJournal(userId: user.id, from: Date())
        }
    }
   
    public func createnewHabit(){
        Task {
            guard let user = self.user else { return }
            try await userManager.createNewHabit(userId: user.id)
        }
    }
    
    public func getAllHabit(){
        Task{
            guard let user = self.user else { return }
            self.habits = try await userManager.getAllHabit(userId: user.id)
        }
    }
    
    public func getHabitDetail(habitId: String){
        Task{
            guard let user = self.user else { return }
            guard let habits = self.habits else { return }
            for i in habits.indices {
                if habits[i].id == habitId {
                    if let habit = try? await userManager.getHabitDetail(userId: user.id, habitId: habits[i].id ?? "") {
                        self.habit = habit
                    }
                }
            }
        }
    }
    
    public func deleteHabit(habitId: String){
        Task{
            guard let user = self.user else { return }
            try? await userManager.deleteHabit(userId: user.id, habitId: habitId)
        }
    }
}
