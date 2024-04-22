//
//  ProfileViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    
    @Published private(set) var user: UserDB? = nil
    @Published private(set) var journals: [JournalDB]? = nil
    @Published private(set) var subJournals: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)]? = nil
    
    private var isJournalCreated = false
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension UserViewModel{
    
    //Done
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
    
    func generateJournalEntries()  {
        let lastEntryDate = UserDefaultManager.lastEntryDate
        let calendar = Calendar.current
        let currentDate = Date()
        let formattedCurrentDate = DateFormatUtil.shared.formattedDate(date: currentDate, to: .fullMonthName)
        let missedDay = calendar.dateComponents([.day], from: lastEntryDate, to: formattedCurrentDate).day ?? 0
        Task {
            if missedDay > 0 {
                for i in 1...missedDay {
                    if let missedDate = calendar.date(byAdding: .day, value: -i, to: formattedCurrentDate)
                    {
                        try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: missedDate)
                        getDetailJournal(from: currentDate)
                    }
                }
            } else {
                try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: formattedCurrentDate)
                getDetailJournal(from: currentDate)
            }
        }
    }
        
    // Done
    func getAllJournal() throws {
        Task {
            do {
                guard let userId = UserDefaultManager.userID else { return }
                if let userJournals = try await userManager.getAllJournal(userId: userId) {
                    self.journals = userJournals
                }
            } catch {
                print("Error fetching journals: \(error)")
            }
        }
    }
    
//    func addListenerForSubJournals(from date: Date) {
//        print("Trigger")
//        Task {
//            guard let userId = UserDefaultManager.userID else { return }
//            try await userManager.addListenerForSubJournals(userId: userId, from: date) { [weak self] subJournals in
//                guard let subJournals else { return }
//                var localArray: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] = []
//                for subJournal in subJournals {
//                    print(subJournal.id ?? "")
//                    if subJournal.subJournalType == .habit {
//                        if let habitPomodoroId = try await self?.userManager.getHabitDetail(userId: userId, habitId: subJournal.habitPomodoroId ?? "") {
//                            print(habitPomodoroId.habitName)
//                            localArray.append((subJournal, habitPomodoroId, nil))
//                        }
//                    } else {
//                        let habitPomodoroId = try await self?.userManager.getPomodoroDetail(userId: userId, pomodoroId: subJournal.habitPomodoroId ?? "")
//                        print(habitPomodoroId?.pomodoroName)
//                        localArray.append((subJournal, nil, habitPomodoroId))
//                    }
//                }
//                self?.subJournals = localArray
//            }
//        }
//    }
    
    // Done
    func getDetailJournal(from date: Date){
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if let subJournals = try await userManager.getSubJournal(userId: userId, from: date) {
                var localArray: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] = []
                for subJournal in subJournals {
                    if subJournal.subJournalType == .habit {
                        if let habitPomodoroId = try await userManager.getHabitDetail(userId: userId, habitId: subJournal.habitPomodoroId ?? "") {
                            localArray.append((subJournal, habitPomodoroId, nil))
                        }
                    } else {
                        let habitPomodoroId = try await userManager.getPomodoroDetail(userId: userId, pomodoroId: subJournal.habitPomodoroId ?? "")
                        localArray.append((subJournal, nil, habitPomodoroId))
                    }
                }
                self.subJournals = localArray
            }
        }
    }
    
    func updateFreqeunceSubJournal(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getDetailJournal(userId: userId, from: date)
                print(subJournalId)
                try await userManager.updateCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
        }
    }
    
    func updateCountStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            try await userManager.updateCountStreak(userId: userId)
        }
    }
    
    func createStreak(){
        Task {
            guard let user else { return }
            try await userManager.createStreak(userId: user.id, description: "")
        }
    }
    
    func deleteStreak(){
        Task{
            guard let user else { return }
            guard let isStreak = user.streak?.isStreak else { return }
            if isStreak {
                print("trigger")
                try await userManager.deleteStreak(userId: user.id)
            }
        }
    }
    
    func getMonthAndYear(date: Date) -> String {
        var dateString = ""
        let calendar = Calendar.current
        if let todayMonthYear = calendar.date(byAdding: .month, value: 0, to: date) {
            dateString = DateFormatUtil().dateToString(date: todayMonthYear, to: "MMMM, yyyy")
        }
        return dateString
    }
}
