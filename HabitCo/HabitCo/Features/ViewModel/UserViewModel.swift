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
    @Published private(set) var streakCount: Int = 0
    @Published var selectedLabels: [String]?
    @Published var hasHabit: [Date]?
    @Published var isAscending: Bool?
         
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension UserViewModel{
    
    // DONE
    func getCurrentUserData(completion: @escaping () -> ()) throws {
        Task {
            guard let userAuthInfo = firebaseProvider.getAuthenticatedUser() else { return }
            do {
                self.user = try await userManager.getUserDB(userId: userAuthInfo.uid)
                completion()
            } catch {
                debugPrint("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }
    
    // DONE
    func generateInitial() -> String {
        guard let user else { return Prompt.id }
        var initial = ""
        let splitName = user.fullName?.split(separator: " ")
        if splitName?.count == 1 {
            guard let firstLetter = user.fullName?.first else { return Prompt.id }
            initial = String(firstLetter)
        } else {
            guard let lastName = splitName?.last,
                  let firstLastName = lastName.first
            else { return Prompt.id }
            initial = String(user.fullName?.prefix(1) ?? "") + String(firstLastName)
        }
        return initial.uppercased()
    }
    
    // DONE
    func generateJournalEntries() {
        let lastEntryDate = UserDefaultManager.lastEntryDate
        let calendar = Calendar.current
        let currentDate = Date().formattedDate(to: .fullMonthName)
        let missedDay = calendar.dateComponents([.day], from: lastEntryDate, to: currentDate).day ?? 0
        Task {
            if missedDay > 0 {
                for i in 0...missedDay {
                    if let missedDate = calendar.date(byAdding: .day, value: -i, to: currentDate)
                    {
                        try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: missedDate)
                        checkIsStreak()
                        getSubJournals(from: currentDate)
                    }
                }
                UserDefaultManager.lastEntryDate = Date().formattedDate(to: .fullMonthName)
            } else {
                try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: currentDate)
                checkIsStreak()
                getSubJournals(from: currentDate)
                UserDefaultManager.lastEntryDate = Date().formattedDate(to: .fullMonthName)
            }
        }
    }
    
    // DONE
    func filterSubJournalsByLabels(date: Date, labels: [String]?) {
        Task {
            self.selectedLabels = labels
            getSubJournals(from: date)
        }
    }
    
    // DONE
    func filterSubJournalsByProgress(from date: Date, isAscending: Bool?) {
        Task {
            self.isAscending = isAscending
            getSubJournals(from: date)
        }
    }
    
    // DONE
    func getStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            self.streakCount = try await userManager.getStreak(userId: userId)?.streaksCount ?? 0
        }
    }

    // DONE
    func getSubJournals(from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard let subJournals = try await userManager.getSubJournals(userId: userId, from: date.formattedDate(to: .fullMonthName), label: selectedLabels, isAscending: isAscending),
                  !subJournals.isEmpty
            else {
                self.subJournals = nil
                getStreak()
                return
            }
            self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
            getStreak()
        }
    }
    
    // DONE
    func undoCountSubJournal(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getJournal(userId: userId, from: date)
            let isFirstStreak = try await userManager.checkIsFirstStreak(userId: userId)
            let isStartFrequencyIsZero = try await userManager.checkStartFrequencyIsZero(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            
            try await userManager.undoCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            if try await !userManager.checkCompletedSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName)),
                try await !userManager.checkHasUndo(userId: userId, from: date)
            {
                if !isFirstStreak,
                   !isStartFrequencyIsZero
                {
                    try await userManager.updateCountStreak(userId: userId, undo: true)
                    try await userManager.updateHasUndo(userId: userId, from: date, isUndo: true)
                } else {
                    try await userManager.deleteStreak(userId: userId)
                }
                try await userManager.updateTodayStreak(userId: userId, from: date, isTodayStreak: false)
            }
            getStreak()
            getSubJournals(from: date)
        }
    }

    func updateCountSubJournal(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getJournal(userId: userId, from: date)
            let complete = try await userManager.isSubJournalComplete(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            try await userManager.updateCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            if complete,
               date.isSameDay(UserDefaultManager.lastEntryDate.formattedDate(to: .fullMonthName))
            {
                if (try await userManager.getStreak(userId: userId) != nil) {
                    updateCountStreak(date: date)
                    try await userManager.updateHasUndo(userId: userId, from: date)
                } else {
                    try await userManager.createStreak(userId: userId, description: "")
                    try await userManager.updateTodayStreak(userId: userId, from: date, isTodayStreak: true)
                    try await userManager.updateHasUndo(userId: userId, from: date)
                }
                try await userManager.updateSubJournalCompleted(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
                getStreak()
            }
            getSubJournals(from: date)
        }
    }
    
    func printDay(date: Date) {
        print("Day: \(date)")
    }
    
    func checkHasSubJournal() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.checkHasSubJournals(userId: userId)
            print("Journal: \(journal))\n", "Count: \(journal?.count)")
            self.hasHabit = journal
        }
    }
    
    // DONE
    func checkIsStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let calendar = Calendar.current
            let formattedDate = Date().formattedDate(to: .fullMonthName)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: formattedDate)
            let startDate = calendar.date(byAdding: .day, value: 0, to: UserDefaultManager.lastEntryDate)
            
            let countHasSubJournalAndCompleted = try await userManager.checkHasSubJournalAndIsComepleted(userId: userId, startDate: startDate ?? formattedDate, endDate: yesterday ?? formattedDate)
            let hasStreak = (try await userManager.getStreak(userId: userId) != nil)
            
            if  hasStreak,
                !countHasSubJournalAndCompleted,
                !formattedDate.isSameDay(startDate ?? formattedDate)
            {
                try await userManager.deleteStreak(userId: userId)
                getStreak()
            }
        }
    }
}


private extension UserViewModel {
    
    // DONE
    func fetchSubJournal(userId: String, subJournals: [SubJournalDB]) async throws -> [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] {
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
        getStreak()
        return localArray
    }
    
    // DONE
    func updateCountStreak(date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if try await !userManager.checkTodayStreak(userId: userId, from: date)
            {
                try await userManager.updateCountStreak(userId: userId)
                try await userManager.updateTodayStreak(userId: userId, from: date, isTodayStreak: true)
            }
        }
    }
}
