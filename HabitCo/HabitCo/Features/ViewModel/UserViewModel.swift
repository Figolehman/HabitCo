//
//  ProfileViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

@MainActor
final class UserViewModel: ObservableObject{
    
    @Published private(set) var user: UserDB? = nil
    @Published private(set) var journals: [Journal]? = nil
    @Published private(set) var journal: Journal? = nil
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension UserViewModel{
    func getCurrentUserData(completion: @escaping () -> ()) throws {
        Task {
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            do {
                self.user = try await userManager.getUserDB(userId: userAuthInfo.uid)
                completion()
            } catch {
                print("Error fetching user data: \(error)")
            }
        }
    }
    
    func updateName() {
        Task{
            guard let user = self.user else { return }
            self.user = try await userManager.updateUserProfile(userId: user.id)
        }
    }
    
    func createJournal(habitId: String?, pomodoroId: String?) {
        Task {
            guard let user = self.user else { return }
            try await userManager.createJournal(userId: user.id, habitId: habitId, pomodoroId: pomodoroId)
        }
    }
    
    func getAllJournal() throws {
        Task {
            guard let user = self.user else { return }
            do {
                if let userJournals = try await userManager.getAllJournal(userId: user.id) {
                    self.journals = userJournals
                }
            } catch {
                print("Error fetching journals: \(error)")
            }
        }
    }
    
    func getDetailJournal(from date: Date){
        Task {
            guard let user = self.user else { return }
            if let journal = try await userManager.getDetailJournal(userId: user.id, from: date) {
                self.journal = journal
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
    
    func deleteStreak(){
        Task{
            guard let user = self.user else { return }
            guard let isStreak = user.streak?.isStreak else { return }
            if !isStreak{
                try await userManager.deleteStreak(userId: user.id)
            }
        }
    }
    
}
