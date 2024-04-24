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
    
    func generateInitial() -> String {
        guard let user else { return "NO User" }
        let splitName = user.fullName?.split(separator: " ")
        guard let lastName = splitName?.last,
              let firstLastName = lastName.first
        else { return String(user.fullName?.prefix(1) ?? "").uppercased() }
        let initial = String(user.fullName?.prefix(1) ?? "") + String(firstLastName)
        return initial.uppercased()
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
                        print("Generate missed Journal")
                        getSubJournals(from: currentDate)
                    }
                }
            } else {
                try await userManager.generateJournal(userId: UserDefaultManager.userID ?? "", date: formattedCurrentDate)
                print("Generate Today Journal")
                getSubJournals(from: currentDate)
            }
        }
    }
    
    func filterJournal(date: Date, label: String) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if let subJournals = try await userManager.filterSubJournalByLabel(userId: userId, from: date, label: label) {
                self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
                getSubJournals(from: date)
            }
        }
    }
    
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

    func getSubJournals(from date: Date){
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if let subJournals = try await userManager.getSubJournal(userId: userId, from: date.formattedDate(to: .fullMonthName)) {
                print("Get sub Journals from: \(date) with subJournalId: \(subJournals.first?.id ?? "No Id")")
                self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
                print("self: \(subJournals.count)\n")
            } else {
                self.subJournals = nil
                print("\(subJournals?.count)\n")
            }
        }
    }
    
    func calculateFraction(startProgress: Int, endProgress: Int) {
        guard endProgress != 0 else { return }
        self.fraction = floor(Double(startProgress) / Double(endProgress) * 10) / 10
    }
    
    func updateFreqeuncySubJournal(subJournalId: String, from date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getDetailJournal(userId: userId, from: date)
            try await userManager.updateCountSubJournal(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId)
            if let _ = try await userManager.getStreak(userId: userId),
               try await userManager.isSubJournalComplete(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalId) {
                UserDefaultManager.hasOneStreak = true
                updateCountStreak(subJournalId: subJournalId)
            } else {
                UserDefaultManager.hasOneStreak = true
                try await userManager.createStreak(userId: userId, description: "")
            }
            getSubJournals(from: date)
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

private extension UserViewModel {
    
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
    
    func checkIsStreak() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let calendar = Calendar.current
            let formattedDate = DateFormatUtil.shared.formattedDate(date: Date(), to: .fullMonthName)
            let yesterday = calendar.date(byAdding: .weekday, value: -1, to: formattedDate)
            let journal = try await userManager.getDetailJournal(userId: userId, from: yesterday ?? Date())
            if let subJournals = try await userManager.getSubJournal(userId: userId, from: formattedDate) {
                for subJournal in subJournals {
                    if UserDefaultManager.isStreak,
                       try await userManager.checkHasSubJournal(userId: userId),
                       try await userManager.isSubJournalComplete(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournal.id ?? "")
                    {
                        UserDefaultManager.isStreak = false
                        try await userManager.deleteStreak(userId: userId)
                    }
                }
            }
        }
    }
    
    func checkIsToday() {
        if UserDefaultManager.lastEntryDate.isSameDay(Date()) {
            UserDefaultManager.hasOneStreak = false
        }
    }
    
    func updateCountStreak(subJournalId: String) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let journal = try await userManager.getDetailJournal(userId: userId, from: DateFormatUtil.shared.formattedDate(date: Date(), to: .fullMonthName))
            if try await userManager.checkHasSubJournal(userId: userId),
               !UserDefaultManager.hasOneStreak
            {
                try await userManager.updateCountStreak(userId: userId)
            }
            
        }
    }
}
