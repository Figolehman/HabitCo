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
    @Published var fraction: Double = 0.0
     
    private var isJournalCreated = false
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
        checkIsToday()
        checkIsStreak()
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
                print("Error fetching user data: \(error)")
            }
        }
    }
    
    // DONE
    func generateInitial() -> String {
        guard let user else { return "ID" }
        var initial = ""
        let splitName = user.fullName?.split(separator: " ")
        if splitName?.count == 1 {
            guard let firstLetter = user.fullName?.first else { return "ID" }
            initial = String(firstLetter)
        } else {
            guard let lastName = splitName?.last,
                  let firstLastName = lastName.first
            else { return "ID" }
            initial = String(user.fullName?.prefix(1) ?? "") + String(firstLastName)
        }
        return initial.uppercased()
    }
    
    // BUG -> di Last Entry Date
    func generateJournalEntries()  {
        let lastEntryDate = UserDefaultManager.lastEntryDate
        let calendar = Calendar.current
        let currentDate = Date().formattedDate(to: .fullMonthName)
        let missedDay = calendar.dateComponents([.day], from: lastEntryDate, to: currentDate).day ?? 0
        print(lastEntryDate)
        print(missedDay)
        print(currentDate)
        Task {
            if missedDay > 0 {
                for i in 1...missedDay {
                    if let missedDate = calendar.date(byAdding: .day, value: -i, to: currentDate)
                    {
                        print("missed Date: \(missedDate)")
                        try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: missedDate)
                        print("Generate missed Journal")
                        getSubJournals(from: currentDate)
                    }
                }
            } else {
                try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: currentDate)
                print("Generate Today Journal")
                getSubJournals(from: currentDate)
            }
        }
    }
    
    // DONE
    func filterJournal(date: Date, labels: [String]) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if let subJournals = try await userManager.filterSubJournalByLabel(userId: userId, from: date, label: labels) {
                self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
            }
        }
    }
    
    // Not Yet Tested
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

    // DONE
    func getSubJournals(from date: Date){
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard let subJournals = try await userManager.getSubJournal(userId: userId, from: date.formattedDate(to: .fullMonthName)),
            !subJournals.isEmpty
            else {
                self.subJournals = nil
                return
            }
                self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
            }
        }
    
    // DONE
    func calculateFraction(startProgress: Int, endProgress: Int) {
        guard endProgress != 0 else { return }
        self.fraction = floor(Double(startProgress) / Double(endProgress) * 10) / 10
    }
    
    func undoCount(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getJournal(userId: userId, from: date)
            try await userManager.undoCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            if try await !userManager.checkCompletedSubJournal(userId: userId, from: Date()) {
                UserDefaultManager.hasTodayStreak = false
            }
            getSubJournals(from: date)
        }
    }

    // BUG -> di hasTodayStreak, jadi setiap si UserViewModel ke init dia jadi false terus, salah penempatan
    func updateFreqeuncySubJournal(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getJournal(userId: userId, from: date)
            let complete = try await userManager.isSubJournalComplete(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            print("isComplete: \(complete)")
            print("Has Today Streak: \(UserDefaultManager.hasTodayStreak)")
            try await userManager.updateCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            if complete {
                if (try await userManager.getStreak(userId: userId) != nil) {
                    updateCountStreak()
                    print("A")
                } else {
                    print("B")
                    try await userManager.createStreak(userId: userId, description: "")
                    UserDefaultManager.hasTodayStreak = true
                    UserDefaultManager.isFirstStreak = true
                }
                try await userManager.updateSubJournalCompleted(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            }
            getSubJournals(from: date)
        }
    }
    
    // DONE
    func checkIsStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let calendar = Calendar.current
            let formattedDate = DateFormatUtil.shared.formattedDate(date: Date(), to: .fullMonthName)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: formattedDate)
            let checkYesterdayJournalCompleted = try await userManager.checkCompletedSubJournal(userId: userId, from: yesterday ?? Date())
            print("Journal Completed yesterday: \(checkYesterdayJournalCompleted)")
            print("yesterday: \(String(describing: yesterday))")
            if let subJournals = try await userManager.getSubJournal(userId: userId, from: formattedDate) {
                for _ in subJournals {
                    if !UserDefaultManager.isFirstStreak,
                       (try await userManager.getStreak(userId: userId) != nil),
                       !checkYesterdayJournalCompleted
                    {
                        try await userManager.deleteStreak(userId: userId)
                        print("TRigegrerere")
                    }
                }
            }
        }
    }
    
    // BUG -> Kalo last entry date == Date sekarang 
    func checkIsToday() {
        if UserDefaultManager.lastEntryDate.isSameDay(Date().formattedDate(to: .fullMonthName)) {
            UserDefaultManager.hasTodayStreak = false
            print(UserDefaultManager.hasTodayStreak)
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
        return localArray
    }
    
    // DONE
    func updateCountStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if !UserDefaultManager.hasTodayStreak
            {
                try await userManager.updateCountStreak(userId: userId)
                UserDefaultManager.isFirstStreak = false
                UserDefaultManager.hasTodayStreak = true
            }
            
        }
    }
}
