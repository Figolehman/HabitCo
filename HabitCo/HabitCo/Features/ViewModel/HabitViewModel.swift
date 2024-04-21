//
//  HabitViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    
    @Published private(set) var habits: [HabitDB]? = []
    @Published private(set) var habit: HabitDB? = nil
    
    private var user: UserDB? = nil
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
        initUser()
    }
    
}

private extension HabitViewModel {
    func initUser(){
        Task{
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            self.user = try await userManager.getUserDB(userId: userAuthInfo.uid)
        }
    }
}

extension HabitViewModel {
   
    public func createUserHabit(habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: Date){
        Task {
            guard let user = self.user else { return }
            let timeString = DateFormatUtil.shared.dateToString(date: reminderHabit, to: "HH:mm")
            try await userManager.createNewHabit(userId: user.id, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: timeString, dateCreated: Date())
        }
    }
    
    public func getHabitDetail(habitId: String){
        Task{
            guard let user = self.user else { return }
            guard let habits = self.habits else { return }
            for habit in habits {
                if habit.id == habitId {
                    if let habit = try? await userManager.getHabitDetail(userId: user.id, habitId: habit.id ?? "") {
                        self.habit = habit
                    }
                }
            }
        }
    }
    
    public func editHabit(habitId: String) {
        Task{
            guard let habits else { return }
            try await userManager.editHabit(userId: UserDefaultManager.userID ?? "", habitId: "ChnrWkKEVGZqrLiEmliw", repeatHabit: [])
        }
    }
    
    public func deleteHabit(habitId: String){
        Task{
            guard let user = self.user else { return }
            try? await userManager.deleteHabit(userId: user.id, habitId: habitId)
        }
    }
}
