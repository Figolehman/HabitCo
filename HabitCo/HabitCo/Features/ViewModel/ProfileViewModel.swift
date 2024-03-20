//
//  ProfileViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published private(set) var user: UserDB? = nil
    @Published private(set) var journals: [Journal]? = nil
    @Published private(set) var journal: Journal? = nil
    //@Published private(set) var habit: Habit? = nil
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension ProfileViewModel{
    func getCurrentUserData() {
        Task{
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            self.user = try await userManager.getUserDB(userId: userAuthInfo.uid )
        }
    }
    
    func updateName() {
        Task{
            guard let user = self.user else { return }
            self.user = try await userManager.updateUserProfile(userId: user.id)
        }
    }
    
    func createJournal() {
        Task {
            guard let user = self.user else { return }
            try await userManager.createJournal(userId: user.id)
        }
    }
    
    func getAllJournal() {
        Task{
            guard let user = self.user else { return }
            if let userJournals = try? await userManager.getAllJournal(userId: user.id) {
                self.journals = userJournals
            }
        }
    }
    
    func getDetailJournal(from date: Date){
        Task {
            guard let user = self.user else { return }
            if let journal = try await userManager.getDetailJournal(userId: user.id, from: date) {
                self.journal = journal
                print(journal.id ?? "NO ID" as String , journal.date ?? Date() as Date)
            } else {
                print("ELSE")
            }
        }
    }
    
    func generateInitial() -> String{
        guard let user = self.user else { return "NO DATA"}
        let splitName = user.fullName?.split(separator: " ")
        guard let lastName = splitName?.last, let firstLastName = lastName.first else { return "" }
        let initial = String(user.fullName?.prefix(1) ?? "") + String(firstLastName)
        return initial.uppercased()
    }
    
    func createStreak(){
        Task {
            guard let user = self.user else { return }
            try await userManager.createStreak(userId: user.id, description: "")
            print("trigger streak")
        }
    }
    
//    func createHabit(){
//        Task {
//            guard let user = self.user else { return }
//            try await userManager.createNewHabit(userId: user.id, journalId: "")
//        }
//    }
    
//    func getHabitDetail(){
//        Task{
//            guard let user = self.user else { return }
//            if let habit = try? await userManager.getHabitDetail(userId: user.id, date: Date()) {
//                self.habit = habit
//            }
//        }
//    }
//    
//    func deleteHabit(){
//        Task{
//            // Still dummy
//            guard let user = self.user else { return }
//            try? await userManager.deleteHabit(userId: user.id, journalId: "", habitId: "")
//        }
//    }
}
