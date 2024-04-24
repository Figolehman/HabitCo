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
    @Published private(set) var errorMessage: String? = nil
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension HabitViewModel {
   
    // Done
    public func createUserHabit(habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: Date?) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard !habitName.isEmpty,
                  !description.isEmpty,
                  !label.isEmpty,
                  frequency != 0,
                  !repeatHabit.isEmpty,
                  reminderHabit != nil
            else {
                self.errorMessage = "Please fill all fields"
                return
            }
            let timeString = DateFormatUtil.shared.dateToString(date: reminderHabit ?? Date(), to: "HH:mm")
            try await userManager.createNewHabit(userId: userId, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: timeString)
        }
    }
    
    public func getHabitDetail(habitId: String){
        Task{
            guard let userId = UserDefaultManager.userID,
                 let habits = self.habits
            else { return }
            for habit in habits {
                if habit.id == habitId {
                    if let habit = try? await userManager.getHabitDetail(userId: userId, habitId: habit.id ?? "") {
                        self.habit = habit
                    }
                }
            }
        }
    }
    
    public func editHabit(habitId: String, habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Int]?, reminderHabit: String?) {
        Task{
            guard let userId = UserDefaultManager.userID else { return }
            try await userManager.editHabit(userId: userId, habitId: habitId, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: reminderHabit)
        }
    }
    
    public func deleteHabit(habitId: String){
        Task{
            guard let userId = UserDefaultManager.userID else { return }
            try? await userManager.deleteHabit(userId: userId, habitId: habitId)
        }
    }
}
