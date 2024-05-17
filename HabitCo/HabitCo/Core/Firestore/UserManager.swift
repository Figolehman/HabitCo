//
//  UserManager.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 15/03/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private enum JournalType: String{
    case habit = "habits"
    case pomodoro = "pomodoros"
    case subJournal = "sub_journals"
    case futureJournal = "future_journals"
    case subFutureJournal = "sub_future_journals"
}

private enum MethodType {
    case generate
    case delete
}

@MainActor
final class UserManager {
    
    static let shared = UserManager()
    private let dayInteger: [Int] = [1, 2, 3, 4, 5, 6, 7]
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private let encoder: Firestore.Encoder = {
        return Firestore.Encoder()
    }()
    
    private let decoder: Firestore.Decoder = {
        return Firestore.Decoder()
    }()
}


// MARK: CRUD For USER
extension UserManager: UserUseCase{
    // Create User to Firestore
    func createUser(user: UserDB) async throws {
        let document = try await userDocument(userId: user.id).getDocument()
        // If user already registered, just update the user last sign in
        if document.exists {
            let data: [String: Any] = [ UserDB.CodingKeys.lastSignIn.rawValue: Date()]
            try await userDocument(userId: user.id).updateData(data)
        } else {
            try userDocument(userId: user.id).setData(from: user, merge: true)
            try await initFutureJournal(userId: user.id, repeatDay: dayInteger)
        }
    }
    
    // Get User DB from Firestore than convert it to UserDB
    func getUserData(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
    }
    
    // * Not Used will be delete in the future *
    // Check if User have a streak or not from Firestore
    func isUserHaveStreak(userId: String) async throws -> Bool {
        let userDoc = try await getUserData(userId: userId)
        return ((userDoc.streak?.id.isEmpty) != nil)
    }
    
}

// MARK: CRUD For FutureJournal
extension UserManager: FutureJournalUseCase {
    // Create Future Journal to Firestore
    // Only create once when user register
    func createFutureJournal(userId: String, dateName: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .futureJournal)
        let futureJournal = FutureJournalDB(id: id, dateName: dateName)
        try document.setData(from: futureJournal, merge: false)
    }
    
    // Get All Future Journal from FireStore
    func getAllFutureJournals(userId: String) async throws -> [FutureJournalDB]? {
        try await userFutureJournalCollection(userId: userId).getAllDocuments(as: FutureJournalDB.self)
    }
    
    // Get Specific Future Journal By Given Date
    func getFutureJournalByDate(userId: String, _ date: Date) async throws -> FutureJournalDB? {
        let snapshot = try await userFutureJournalCollection(userId: userId).whereField(FutureJournalDB.CodingKeys.dateName.rawValue, isEqualTo: date.getDayName).getDocuments()
        if let document = snapshot.documents.first {
            return try document.data(as: FutureJournalDB.self)
        }
        return nil
    }
}

// MARK: - CRUD For SubFutureJournal
extension UserManager: SubFutureJournalUseCase {
    // Create Sub Future journal
    func createSubFutureJournal(userId: String, futureJournalId: String, subJournalType: SubJournalType, habitPomodoroId: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, futureJournalId: futureJournalId, type: .subFutureJournal)
        let subFutureJournal = SubFutureJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: subJournalType)
        try document.setData(from: subFutureJournal, merge: false)
    }
    
    // Get All Sub Future Journals for Scrollable Calendar View
    // Return ["Mon": [SubFutureJournalDB], "Tue": [SubFutureJournalDB]]
    func getAllSubFutureJournalsByDateName(userId: String) async throws -> [String: [SubFutureJournalDB]]? {
        var subFutureJournals: [String: [SubFutureJournalDB]] = [:]

        // Get all future journals
        guard let futureJournals = try await getAllFutureJournals(userId: userId) else {
            return subFutureJournals
        }

        // Check if future journal has a sub journal or not
        for futureJournal in futureJournals {
            // Get All Sub Future Journals DB
            guard let subFutureJournalsDB = try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournal.id ?? "").getAllDocuments(as: SubFutureJournalDB.self) else {
                continue
            }
            // Append ["Mon": [SubJournalsDB]
            subFutureJournals[futureJournal.dateName ?? "", default: []].append(contentsOf: subFutureJournalsDB)
        }
        return subFutureJournals
    }
    
    func checkAllJournalThatHasSubJournal(userId: String) async throws -> [String: Bool]? {
        var hasSubFutureJournal: [String: Bool] = [:]

        // Get all future journals
        guard let futureJournals = try await getAllFutureJournals(userId: userId) else {
            return hasSubFutureJournal
        }

        // Check if future journal has a sub journal or not
        for futureJournal in futureJournals {
            // Get All Sub Future Journals DB
            let snapshot = try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournal.id ?? "").getDocuments()
            // Append ["Mon": [SubJournalsDB]
            if !snapshot.isEmpty {
                hasSubFutureJournal[futureJournal.dateName ?? ""] = true
            } else {
                hasSubFutureJournal[futureJournal.dateName ?? ""] = false
            }
        }
        return hasSubFutureJournal
    }

    
    // Get All Sub Future Journals By Give Date
    func getAllSubFutureJournalsByDate(userId: String, from date: Date) async throws -> [SubFutureJournalDB]? {
        let futureJournal = try await getFutureJournalByDate(userId: userId, date)
        if let futureJournal {
            return try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournal.id ?? "").getAllDocuments(as: SubFutureJournalDB.self)
        }
        return nil
    }
    
    // Delete Sub Future Journal For Edit Repeat Date
    func deleteSubFutureJournal(userId: String, futureJournalId: String, subFutureJournalId: String) async throws {
        try await userSubFutureJournalDocument(userId: userId, futureJournalId: futureJournalId, subFutureJournalId: subFutureJournalId).delete()
    }
}

// MARK: - For Journal Use Case
extension UserManager: JournalUseCase {
    
    // Create Journal DB From Given Date
    func createJournal(userId: String, date: Date) async throws {
        guard let subFutureJournals = try await getAllSubFutureJournalsByDate(userId: userId, from: date),
              try await (getJournal(userId: userId, from: date) == nil)
        else { return }
        let (document, id) = generateDocumentID(userId: userId, type: nil)
        let journal = JournalDB(id: id, date: date, dateName: date.getDayName, undoStreak: false, todayStreak: false, popUpGainStreak: false, popUpLossStreak: false, hasSubJournal: false)
        try document.setData(from: journal, merge: false)
        
        // When journal is created, Sub Journal also created in the same day
        for subFutureJournal in subFutureJournals {
            if subFutureJournal.subJournalType == .habit {
                let habit = try await getHabitDetail(userId: userId, habitId: subFutureJournal.habitPomodoroId ?? "")
                try await createSubJournal(userId: userId, journalId: id, type: subFutureJournal.subJournalType ?? .habit, habitPomodoroId: subFutureJournal.habitPomodoroId ?? "", label: habit?.label ?? "", frequencyCount: habit?.frequency ?? 0)
                try await updateHasSubJournal(userId: userId, from: date)
            } else {
                let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: subFutureJournal.habitPomodoroId ?? "")
                try await createSubJournal(userId: userId, journalId: id, type: subFutureJournal.subJournalType ?? .pomodoro, habitPomodoroId: subFutureJournal.habitPomodoroId ?? "", label: pomodoro?.label ?? "", frequencyCount: pomodoro?.session ?? 0)
                try await updateHasSubJournal(userId: userId, from: date)
            }
        }
    }
    
    // Get All Journal
    func getAllJournal(userId: String) async throws -> [JournalDB]? {
        return try await userJournalCollection(userId: userId).order(by: JournalDB.CodingKeys.date.rawValue, descending: false).getAllDocuments(as: JournalDB.self)
    }
    
    // Get Spesific Journal from the given date
    func getJournal(userId: String, from date: Date) async throws -> JournalDB? {
        let snapshot = try await userJournalCollection(userId: userId).whereDateField(JournalDB.CodingKeys.date.rawValue, isEqualToDate: date).getDocuments()
        if let document = snapshot.documents.first {
            let journal = try document.data(as: JournalDB.self)
            return journal
        } else {
            return nil
        }
    }
    
    // Get Journal for one month
    func getJournalForOneMonth(userId: String, forMonth date: Date) async throws -> [JournalDB]? {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        guard let startOfMonth = startOfMonth else {
            return nil
        }
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)

        let journalDocuments = try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startOfMonth)
            .whereField(JournalDB.CodingKeys.date.rawValue, isLessThanOrEqualTo: endOfMonth ?? startOfMonth)
            .getAllDocuments(as: JournalDB.self)

        return journalDocuments
    }
    
    // Check if the journal has sub journal and the journal already has a streak in that day or not for checkIsStreak function by given date
    func checkHasSubJournalAndHasTodayStreak(userId: String, startDate: Date, endDate: Date) async throws -> Bool {
        // Check if the Journal has a sub journal or not
        let snapshotHasSubJournal = try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(JournalDB.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
            .whereField(JournalDB.CodingKeys.hasSubJournal.rawValue, isEqualTo: true)
            .getDocuments()
        
        // Check if the Journal has already streak or not in that day
        let snapshotTodayStreak = try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(JournalDB.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
            .whereField(JournalDB.CodingKeys.todayStreak.rawValue, isEqualTo: true)
            .getDocuments()
        return snapshotTodayStreak.count == snapshotHasSubJournal.count
    }
    
    func checkHasSubJournalToday(userId: String) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let snapshotHasSubJournal = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "").getDocuments()
        return !snapshotHasSubJournal.isEmpty
    }
    
    func checkHasSubJournalTodayWithHabitPomodoroId(userId: String, habitPomodoroId: String) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let snapshotHasSubJournal = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "").whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitPomodoroId).getDocuments()
        return !snapshotHasSubJournal.isEmpty
    }
    
    func checkHasSubJournalByDate(userId: String, date: Date) async throws -> Bool {
        guard let journal = try await getJournal(userId: userId, from: date) else { return false }
        let snapshotHasSubJournal = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "").getDocuments()
        return !snapshotHasSubJournal.isEmpty
    }
        
    // Check if journal has a sub journals or not for circle scrollableView
    func checkHasHabit(userId: String) async throws -> [Date]? {
        guard let journals = try await getAllJournal(userId: userId) else {
            return []
        }
        
        var results: [Date] = []
        // If Journal has a subJournal, append that Date
        for journal in journals {
            let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "").getDocuments()
            guard !snapshot.isEmpty
                  //hasSubJournal != false
            else {
                continue
            }
            results.append(journal.date ?? Date())
        }
        return results
    }
    
    // Check if streak is already undoed or not in that day
    // This validation check streak is already undoed onece per day
    func checkHasUndoStreak(userId: String, from date: Date) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: date)
        return journal?.undoStreak ?? false
    }
    
    
    // Check if user is already streak or not in that day
    // This validation check update streak only trigger once per day
    func checkTodayStreak(userId: String, from date: Date) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: date)
        return journal?.todayStreak ?? false
    }
    
    // Check if app is already trigger the pop up streak or not
    func checkPopUpGainStreak(userId: String) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        return journal?.popUpGainStreak ?? false
    }
    
    func updatePopUpGainStreak(userId: String, popUpStreak: Bool) async throws {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.popUpGainStreak.rawValue: popUpStreak
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    func checkPopUpLossStreak(userId: String) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        return journal?.popUpLossStreak ?? false
    }
    
    func updatePopUpLossStreak(userId: String, popUpStreak: Bool) async throws {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.popUpLossStreak.rawValue: popUpStreak
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    // Update field hasSubJournal in firestore
    func updateHasSubJournal(userId: String, from date: Date, hasSubJournal: Bool = true) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.hasSubJournal.rawValue: hasSubJournal
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    //  Update if streak is already undoed or not in that day
    func updateHasUndoStreak(userId: String, from date: Date, isUndo: Bool = false) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.undoStreak.rawValue: isUndo
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    // Update if user is already streak or not in that day
    func updateTodayStreak(userId: String, from date: Date, isTodayStreak: Bool = false) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.todayStreak.rawValue: isTodayStreak
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
}

// MARK: - For SubJournal Use Case
extension UserManager: SubJournalUseCase {
    // Create Sub Journal
    func createSubJournal(userId: String, journalId: String, type: SubJournalType, habitPomodoroId: String, label: String, frequencyCount: Int) async throws {
        let (document, id) = generateDocumentID(userId: userId, journalId: journalId, type: .subJournal)
        let subJournal = SubJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: type, label: label, frequencyCount: frequencyCount, startFrequency: 0, fraction: 0, isCompleted: false)
        try document.setData(from: subJournal, merge: false)
    }
    
    // Get All Sub Journals based on date, label, and isAscending
    func getSubJournals(userId: String, from date: Date, label: [String]?, isAscending: Bool?) async throws -> [SubJournalDB]? {
        if let label, !label.isEmpty, let isAscending {
            return try await getFilteredAndSortedAllSubJournals(userId: userId, from: date, label: label, isAscending: isAscending)
        } else if let isAscending {
            return try await getSortedSubJournalByProgress(userId: userId, from: date, isAscending: isAscending)
        } else if let label {
            return try await getFilterSubJournalByLabel(userId: userId, from: date, label: label)
        } else {
            return try await getAllSubJournalsByDate(userId: userId, from: date)
        }
    }
    
    // Get spesific SubJournal based on Habit ID
    func getSubJournalByHabitID(userId: String, habitId: String, date: Date) async throws -> DocumentReference? {
        let journal = try await getJournal(userId: userId, from: date)
        let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "")
            .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId)
            .getDocuments()
        if let document = snapshot.documents.first {
            return document.reference
        }
        return nil
    }
    
    func deleteSubJournalByHabitID(userId: String, habitId: String) async throws {
        guard let journals = try await getAllJournal(userId: userId) else { return }
        for journal in journals {
            let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "")
                .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId)
                .getDocuments()
            if let document = snapshot.documents.first {
                try await document.reference.delete()
            }
        }
    }
    
    func deleteSubJournalByPomodoroID(userId: String, pomodoroId: String) async throws {
        guard let journals = try await getAllJournal(userId: userId) else { return }
        for journal in journals {
            let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "")
                .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: pomodoroId)
                .getDocuments()
            if let document = snapshot.documents.first {
                try await document.reference.delete()
            }
        }
    }
    
    // Get spesific SubJournal based on Pomodoro ID
    func getSubJournalByPomodoroID(userId: String, pomodoroID: String) async throws -> DocumentReference? {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "")
            .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: pomodoroID)
            .getDocuments()
        if let document = snapshot.documents.first {
            return document.reference
        }
        return nil
    }
    
    // Get all sub journal from the journal and filter is there any completed journal or not
    func checkCompletedSubJournal(userId: String, from date: Date) async throws -> Bool {
        guard let journal = try await getJournal(userId: userId, from: date) else { return false }
        let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "").whereField(SubJournalDB.CodingKeys.isCompleted.rawValue, isEqualTo: true).getDocuments()
        if let document = snapshot.documents.first {
            return document.exists
        }
        return false
    }
    
    func editSubJournal(userId: String, from date: Date, habitId: String?, pomodoroId: String?, frequency: Int, label: String) async throws -> Bool {
            let journal = try await getJournal(userId: userId, from: date)
            let subJournalDocument = try await getSubJournalByDate(userId: userId, date: date, habitId: habitId, pomodoroId: pomodoroId)
    
            let count = subJournalDocument?.startFrequency ?? 0
            let frequencySubJournal = subJournalDocument?.frequencyCount ?? 0
            let newFraction = ((Double(count)) / Double(frequency) * 100) / 100
            var updatedData: [String: Any] = [:]
            if frequencySubJournal < frequency {
                updatedData[SubJournalDB.CodingKeys.label.rawValue] = label
                updatedData[SubJournalDB.CodingKeys.frequencyCount.rawValue] = frequency
                updatedData[SubJournalDB.CodingKeys.isCompleted.rawValue] = false
                updatedData[SubJournalDB.CodingKeys.fraction.rawValue] = newFraction
                try await userSubJournalDocument(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalDocument?.id ?? "").updateData(updatedData)
                return true
            } else {
                updatedData[SubJournalDB.CodingKeys.label.rawValue] = label
                updatedData[SubJournalDB.CodingKeys.frequencyCount.rawValue] = frequency
                if count >= frequency {
                    updatedData[SubJournalDB.CodingKeys.startFrequency.rawValue] = frequency
                    updatedData[SubJournalDB.CodingKeys.isCompleted.rawValue] = true
                    updatedData[SubJournalDB.CodingKeys.fraction.rawValue] = 1
                }
                try await userSubJournalDocument(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournalDocument?.id ?? "").updateData(updatedData)
                return false
            }
        }
    
        func getSubJournalByDate(userId: String, date: Date, habitId: String?, pomodoroId: String?) async throws -> SubJournalDB? {
            let journal = try await getJournal(userId: userId, from: date)
            if habitId != nil {
                let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "")
                    .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId ?? "")
                    .getDocuments()
                if let subJournalDocument = snapshot.documents.first {
                    return try subJournalDocument.data(as: SubJournalDB.self)
                }
            } else if pomodoroId != nil {
                let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "")
                    .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: pomodoroId ?? "")
                    .getDocuments()
                if let subJournalDocument = snapshot.documents.first {
                    return try subJournalDocument.data(as: SubJournalDB.self)
                }
            }
            return nil
        }
    
    func checkHabitSubJournalIsCompleteByDate(userId: String, habitId: String, date: Date) async throws -> Bool {
        let subJournal = try await getSubJournalByHabitID(userId: userId, habitId: habitId, date: date)?.getDocument(as: SubJournalDB.self)
        return subJournal?.isCompleted == true
    }
    
    func checkPomodoroSubJournalIsCompleteByDate(userId: String, pomodoroId: String, date: Date) async throws -> Bool {
        let subJournal = try await getSubJournalByPomodoroID(userId: userId, pomodoroID: pomodoroId)?.getDocument(as: SubJournalDB.self)
        return subJournal?.isCompleted == true
    }
    
    // Check if the spesific subJournal already complete or not based on startFrequenct / frequencyCount
    func checkSubJournalIsCompleteByProgress(userId: String, journalId: String, subJournalId: String) async throws -> Bool {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        return subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int == (((subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue]) as? Int ?? 0) - 1 )
    }
    
    func checkSubJournalIsCompleted(userId: String, journalId: String, subJournalId: String) async throws -> Bool {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        return subJournalDocument.data()?[SubJournalDB.CodingKeys.isCompleted.rawValue] as? Bool == true
    }
    
    // Check if the startFrequency is already zero
    func checkStartFrequencyIsZero(userId: String, journalId: String, subJournalId: String) async throws -> Bool {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        return subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int == 0
    }
    
    // Update frequency count for subJournal -> Card
    func updateCountSubJournal(userId: String, journalId: String, subJournalId: String) async throws {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        guard var count = subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int,
              count < subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue] as? Int ?? 0,
              let frequency = subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue] as? Double
        else { return }
        count += 1
        let newFraction = floor(Double(count) / frequency * 100) / 100
        let data: [String: Any] = [
            SubJournalDB.CodingKeys.startFrequency.rawValue: count,
            SubJournalDB.CodingKeys.fraction.rawValue: newFraction
        ]
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).updateData(data)
    }
    
    // Undo frequency count for subJournal
    func undoCountSubJournal(userId: String, journalId: String, subJournalId: String) async throws {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        guard var count = subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int,
              count <= subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue] as? Int ?? 0,
              count > 0,
              let frequency = subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue] as? Double
        else { return }
        count -= 1
        let newFraction = (Double(count) / frequency * 100) / 100
        let data: [String: Any] = [
            SubJournalDB.CodingKeys.startFrequency.rawValue: count,
            SubJournalDB.CodingKeys.fraction.rawValue: newFraction
        ]
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).updateData(data)
        try await updateSubJournalCompleted(userId: userId, journalId: journalId, subJournalId: subJournalId, isCompleted: false)
    }
    
    // Update when subJournal is already completed
    func updateSubJournalCompleted(userId: String, journalId: String, subJournalId: String, isCompleted: Bool = true) async throws {
        let data: [String: Any] = [
            SubJournalDB.CodingKeys.isCompleted.rawValue: isCompleted
        ]
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).updateData(data)
    }
    
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    
    // Create new habit
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String) async throws {
        let journalDocument = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let (document, id) = generateDocumentID(userId: userId, type: .habit)
        let habit = HabitDB(id: id, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: reminderHabit, dateCreated: Date())
        try document.setData(from: habit, merge: false)
        
        //Create Notification Handler
        if reminderHabit != "No Reminder" {
            let notif = NotificationHandler()
            let reminderHabitDate = reminderHabit.stringToDate(to: .hourAndMinute)
            notif.sendNotification(date: reminderHabitDate, weekdays: repeatHabit, title: habitName, body: description, withIdentifier: id)
        }
        
        // Create habit in Sub Future Journal
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: id, type: .habit, method: .generate, repeatHabit: repeatHabit, frequencyCount: frequency)
        
        // Check if today is matching with [repeatHabit]
        if checkIfTodayIsMatching(repeatDays: repeatHabit) {
            try await createSubJournal(userId: userId, journalId: journalDocument?.id ?? "No ID", type: .habit, habitPomodoroId: id, label: label, frequencyCount: frequency)
            try await updateHasSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        }
    }
    
    func getHabitId(userId: String, habitId: String) async throws -> String {
        let snapshot = try await userHabitCollection(userId: userId).whereField(HabitDB.CodingKeys.id.rawValue, isEqualTo: habitId).getDocuments()
        return snapshot.documents.first?.documentID ?? ""
    }
    
    // Get habit detail from habit ID
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB? {
        return try await userHabitDocument(userId: userId, habitId: habitId).getDocument(as: HabitDB.self)
    }
    
    // Get progress habit for one month
    func getProgressHabit(userId: String, habitId: String, month: Date) async throws -> [Date: CGFloat]? {
        var progressValues: [Date: CGFloat] = [:]
        guard let journalDocuments = try await getJournalForOneMonth(userId: userId, forMonth: month) else {
            return nil
        }
        for journalDocument in journalDocuments {
            // Get SubJournal if habitPomodoroId == habitId
            guard let subJournalDocuments = try await userSubJournalCollection(userId: userId, journalId: journalDocument.id ?? "")
                    .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId)
                    .getAllDocuments(as: SubJournalDB.self), subJournalDocuments.count != 0
            else {
                // if subJournal == nil, append progress = 0.0
                progressValues[journalDocument.date!] = 0.0
                continue
            }
            
            for subJournalDocument in subJournalDocuments {
                if subJournalDocument.frequencyCount != 0 {
                    let progress = Float(subJournalDocument.startFrequency ?? 0) / Float(subJournalDocument.frequencyCount ?? 0)
                    progressValues[journalDocument.date!] = CGFloat(progress)
                }
            }
        }
        return progressValues.isEmpty ? nil : progressValues
    }
    
    // Edit Habit from the given parameter
    func editHabit(userId: String, habitId: String, habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Int]?, reminderHabit: String?) async throws  -> HabitDB? {
        let habit = try await getHabitDetail(userId: userId, habitId: habitId)
        let notif = NotificationHandler()
        notif.removeNotification(withIdentifier: habitId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: habitId, method: .delete, repeatHabit: habit?.repeatHabit ?? [])
        var updatedData: [String: Any] = [:]
        if let habitName {
            updatedData[HabitDB.CodingKeys.habitName.rawValue] = habitName
        }
        if let description {
            updatedData[HabitDB.CodingKeys.description.rawValue] = description
        }
        if let label {
            updatedData[HabitDB.CodingKeys.label.rawValue] = label
        }
        if let frequency {
            updatedData[HabitDB.CodingKeys.frequency.rawValue] = frequency
        }
        if let repeatHabit {
            updatedData[HabitDB.CodingKeys.repeatHabit.rawValue] = repeatHabit
        }
        if let reminderHabit {
            updatedData[HabitDB.CodingKeys.reminderHabit.rawValue] = reminderHabit
            notif.sendNotification(date: reminderHabit.stringToDate(to: .hourAndMinute), weekdays: repeatHabit ?? [], title: habitName ?? "", body: description ?? "", withIdentifier: habitId)
        }
        try await userHabitDocument(userId: userId, habitId: habitId).updateData(updatedData)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: habitId, method: .generate, repeatHabit: repeatHabit ?? [])
        return try await getHabitDetail(userId: userId, habitId: habitId)
    }
    
    
    // Delete Habit
    func deleteHabit(userId: String, habitId: String) async throws {
        let habit = try await getHabitDetail(userId: userId, habitId: habitId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: habitId, method: .delete, repeatHabit: habit?.repeatHabit ?? [])
        try await deleteSubJournalByHabitID(userId: userId, habitId: habitId)
        try await userHabitDocument(userId: userId, habitId: habitId).delete()
    }
}

extension UserManager: PomodoroUseCase {
    
    // Create Pomodoro
    func createNewPomodoro(userId: String, pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, longBreakTime: Int, repeatPomodoro: [Int], reminderPomodoro: String) async throws {
        let journalDocument = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let (document, id) = generateDocumentID(userId: userId, type: .pomodoro)
        let pomodoro = PomodoroDB(id: id, pomodoroName: pomodoroName, description: description, label: label, session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderPomodoro: reminderPomodoro, dateCreated: Date())
        try document.setData(from: pomodoro, merge: false)
        
        if reminderPomodoro != "No Reminder" {
            let notif = NotificationHandler()
            let reminderHabitDate = reminderPomodoro.stringToDate(to: .hourAndMinute)
            notif.sendNotification(date: reminderHabitDate, weekdays: repeatPomodoro, title: pomodoroName, body: description, withIdentifier: id)
        }
        
        // Create Pomodoro in SubFutureJournal
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: id, type: .pomodoro, method: .generate, repeatHabit: repeatPomodoro, frequencyCount: session)
        
        // Check if today is matching with [repeatHabit]
        if checkIfTodayIsMatching(repeatDays: repeatPomodoro) {
            try await createSubJournal(userId: userId, journalId: journalDocument?.id ?? "No ID", type: .pomodoro, habitPomodoroId: id, label: label, frequencyCount: session)
            try await updateHasSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        }
    }
    
    func getPomodoroId(userId: String, pomodoroId: String) async throws -> String {
        let snapshot = try await userHabitCollection(userId: userId).whereField(PomodoroDB.CodingKeys.id.rawValue, isEqualTo: pomodoroId).getDocuments()
        return snapshot.documents.first?.documentID ?? ""
    }
    
    // Get pomodoro detail
    func getPomodoroDetail(userId: String, pomodoroId: String) async throws -> PomodoroDB? {
        return try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).getDocument(as: PomodoroDB.self)
    }
    
    // Get progress pomodoro for 1 month
    func getProgressPomodoro(userId: String, pomodoroId: String, month: Date) async throws -> [CGFloat]? {
            var progressValues: [CGFloat] = []
            
            guard let journalDocuments = try await getJournalForOneMonth(userId: userId, forMonth: month) else {
                return nil
            }
            for journalDocument in journalDocuments {
                guard let subJournalDocuments = try await userSubJournalCollection(userId: userId, journalId: journalDocument.id ?? "")
                        .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: pomodoroId)
                        .getAllDocuments(as: SubJournalDB.self), subJournalDocuments.count != 0
                else {
                    progressValues.append(0.0)
                    continue
                }
                
                for subJournalDocument in subJournalDocuments {
                    if subJournalDocument.frequencyCount != 0 {
                        let progress = Float(subJournalDocument.startFrequency ?? 0) / Float(subJournalDocument.frequencyCount ?? 0)
                        progressValues.append(CGFloat(progress))
                    }
                }
            }
            return progressValues.isEmpty ? nil : progressValues
        }
    
    // Edit Pomodoro
    func editPomodoro(userId: String, pomodoroId: String, pomodoroName: String?, description: String?, label: String?, session: Int?, focusTime: Int?, breakTime: Int?, repeatPomodoro: [Int]?, longBreakTime: Int?, reminderPomodoro: String?) async throws -> PomodoroDB? {
        let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
        let notif = NotificationHandler()
        notif.removeNotification(withIdentifier: pomodoroId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, type: .pomodoro, method: .delete, repeatHabit: pomodoro?.repeatPomodoro ?? [])
        var updatedData: [String: Any] = [:]
        if let pomodoroName {
            updatedData[PomodoroDB.CodingKeys.pomodoroName.rawValue] = pomodoroName
        }
        if let description {
            updatedData[PomodoroDB.CodingKeys.description.rawValue] = description
        }
        if let label {
            updatedData[PomodoroDB.CodingKeys.label.rawValue] = label
        }
        if let session {
            updatedData[PomodoroDB.CodingKeys.session.rawValue] = session
        }
        if let focusTime {
            updatedData[PomodoroDB.CodingKeys.focusTime.rawValue] = focusTime
        }
        if let longBreakTime {
            updatedData[PomodoroDB.CodingKeys.longBreakTime.rawValue] = longBreakTime
        }
        if let breakTime {
            updatedData[PomodoroDB.CodingKeys.breakTime.rawValue] = breakTime
        }
        if let repeatPomodoro {
            updatedData[PomodoroDB.CodingKeys.repeatPomodoro.rawValue] = repeatPomodoro
        }
        if let reminderPomodoro {
            updatedData[PomodoroDB.CodingKeys.reminderPomodoro.rawValue] = reminderPomodoro
            notif.sendNotification(date: reminderPomodoro.stringToDate(to: .hourAndMinute), weekdays: repeatPomodoro ?? [], title: pomodoroName ?? "", body: description ?? "", withIdentifier: pomodoroId)
        }
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).updateData(updatedData)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, type: .pomodoro, method: .generate, repeatHabit: repeatPomodoro ?? [])
        return try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
    }
    
    func editPomodoroTimer(userId: String, pomodoroId: String, focusTime: Int?, breakTime: Int?,  longBreakTime: Int?) async throws -> PomodoroDB? {
        let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
        var updatedData: [String: Any] = [:]
        if let focusTime {
            updatedData[PomodoroDB.CodingKeys.focusTime.rawValue] = focusTime
        }
        if let longBreakTime {
            updatedData[PomodoroDB.CodingKeys.longBreakTime.rawValue] = longBreakTime
        }
        if let breakTime {
            updatedData[PomodoroDB.CodingKeys.breakTime.rawValue] = breakTime
        }
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).updateData(updatedData)
        return try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
    }
    
    // Delete pomodoro
    func deletePomodoro(userId: String, pomodoroId: String) async throws {
        let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, method: .delete, repeatHabit: pomodoro?.repeatPomodoro ?? [])
        try await deleteSubJournalByPomodoroID(userId: userId, pomodoroId: pomodoroId)
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).delete()
    }
}

// MARK: - CRUD for Streak
extension UserManager: StreakUseCase {
    // Create habit
    func createStreak(userId: String) async throws {
        let streak = StreakDB(streaksCount: 1, dateCreated: Date())
        guard let data = try? encoder.encode(streak) else { return }
        let dict: [String: Any] = [
            UserDB.CodingKeys.streak.rawValue: data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    // Get Streak Data
    func getStreak(userId: String) async throws -> StreakDB? {
        let userDoc = try await getUserData(userId: userId)
        return userDoc.streak
    }
    
    // Check streak if streak is first streak or not
    func checkIsFirstStreak(userId: String) async throws -> Bool {
        let streak = try await getStreak(userId: userId)
        return streak?.streaksCount == 1
    }
    
    // Update count streak
    func updateCountStreak(userId: String, undo: Bool = false) async throws {
        let userDoc = try await userDocument(userId: userId).getDocument()
        if var streak = userDoc.data()?[UserDB.CodingKeys.streak.rawValue] as? [String: Any],
           let streakCount = streak[StreakDB.CodingKeys.streaksCount.rawValue] as? Int
        {
            var newStreakCount = 0
            if undo {
                newStreakCount = max(0, streakCount - 1) 
            } else {
                newStreakCount = streakCount + 1
            }
            streak[StreakDB.CodingKeys.streaksCount.rawValue] = newStreakCount
            let data: [String: Any] = [
                UserDB.CodingKeys.streak.rawValue: streak
            ]
            try await userDocument(userId: userId).updateData(data)
        }
    }
    
    // Delete Streak
    func deleteStreak(userId: String) async throws {
        
        let data: [String: Any?] = [
            UserDB.CodingKeys.streak.rawValue: nil
        ]
        try await userDocument(userId: userId).updateData(data as [AnyHashable: Any])
    }
}

private extension UserManager {
    
    func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func userJournalCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("journals")
    }
    
    func userJournalDocument(userId: String, journalId: String) -> DocumentReference{
        userJournalCollection(userId: userId).document(journalId)
    }
    
    // SubJournalCollection
    func userSubJournalCollection(userId: String, journalId: String) -> CollectionReference {
        userJournalDocument(userId: userId, journalId: journalId).collection("sub_journals")
    }
    
    func userSubJournalDocument(userId: String, journalId: String, subJournalId: String) -> DocumentReference{
        userSubJournalCollection(userId: userId, journalId: journalId).document(subJournalId)
    }
    
    // Future Journal
    func userFutureJournalCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("future_journals")
    }
    
    func userFutureJournalDocument(userId: String, futureJournalId: String) -> DocumentReference{
        userFutureJournalCollection(userId: userId).document(futureJournalId)
    }
    
    // Sub Future Journal
    func userSubFutureJournalCollection(userId: String, futureJournalId: String) -> CollectionReference {
        userFutureJournalDocument(userId: userId, futureJournalId: futureJournalId).collection("sub_future_journals")
    }
    
    func userSubFutureJournalDocument(userId: String, futureJournalId: String, subFutureJournalId: String) -> DocumentReference{
        userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId).document(subFutureJournalId)
    }
    
    // Habit
    func userHabitCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("habits")
    }
    
    func userHabitDocument(userId: String, habitId: String) -> DocumentReference {
        userHabitCollection(userId: userId).document(habitId)
    }
    
    // Pomodoro
    func userPomodoroCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("pomodoro")
    }
    
    func userPomodoroDocument(userId: String, pomodoroId: String) -> DocumentReference {
        userPomodoroCollection(userId: userId).document(pomodoroId)
    }
    
    // Generate Document ID for firestore
    func generateDocumentID(userId: String, journalId: String? = nil, futureJournalId: String? = nil, type: JournalType?) -> (DocumentReference, String) {
        switch type {
        case .habit:
            let habitDocument = userHabitCollection(userId: userId).document()
            return (habitDocument, habitDocument.documentID)
        case .pomodoro:
            let pomodoroDocument = userPomodoroCollection(userId: userId).document()
            return (pomodoroDocument, pomodoroDocument.documentID)
        case .subJournal:
            let subJournalDocument = userSubJournalCollection(userId: userId, journalId: journalId ?? "").document()
            return (subJournalDocument, subJournalDocument.documentID)
        case .futureJournal:
            let futureJournalDocument = userFutureJournalCollection(userId: userId).document()
            return (futureJournalDocument, futureJournalDocument.documentID)
        case .subFutureJournal:
            let subFutureJournalDocument = userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId ?? "").document()
            return (subFutureJournalDocument, subFutureJournalDocument.documentID)
        case .none:
            let journalDocument =  userJournalCollection(userId: userId).document()
            return (journalDocument, journalDocument.documentID)
        }
    }
    
    // Init Future Journal, only triggered once
    func initFutureJournal(userId: String, repeatDay: [Int]) async throws {
        createJournalByRepeatDay(repeatDay: repeatDay, dateComponent: .weekday, value: 7) { [weak self] date in
            try await self?.createFutureJournal(userId: userId, dateName: date.getDayName)
        }
    }
    
    // Get Future Journal From Day Name ex: Mon
    func getFutureJournalByDayName(userId: String, dayName: String) async  throws -> QuerySnapshot {
        try await userFutureJournalCollection(userId: userId)
            .whereField(FutureJournalDB.CodingKeys.dateName.rawValue, isEqualTo: dayName)
            .getDocuments()
    }
    
    // Get Sub Future Journal By Habit Pomodoro ID
    func getSubFutureJournalByHabitPomodoroId(userId: String, futureJournalId: String, habitPomodoroId: String) async throws -> QuerySnapshot {
        try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId)
            .whereField(SubFutureJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitPomodoroId)
            .getDocuments()
    }
     
    // For Manage subFutureJournal by given method
    func manageSubFutureJournal(userId: String, habitPomodoroId: String, type: SubJournalType? = nil, method: MethodType, repeatHabit: [Int], frequencyCount: Int? = nil) async throws {
        createJournalByRepeatDay(method: method, repeatDay: repeatHabit, dateComponent: .weekday, value: 7) { [weak self] date in
            guard let snapshot = try await self?.getFutureJournalByDayName(userId: userId, dayName: date.getDayName) else { return }
            for futureJournalDocument in snapshot.documents {
                switch method {
                case .generate:
                    try await self?.createSubFutureJournal(userId: userId, futureJournalId: futureJournalDocument.documentID, subJournalType: type ?? .habit, habitPomodoroId: habitPomodoroId)
                case .delete:
                    let subFutureJournalQueryDocument = try await self?.getSubFutureJournalByHabitPomodoroId(userId: userId, futureJournalId: futureJournalDocument.documentID, habitPomodoroId: habitPomodoroId)
                    try await self?.deleteSubFutureJournal(userId: userId, futureJournalId: futureJournalDocument.documentID, subFutureJournalId: subFutureJournalQueryDocument?.documents.first?.documentID ?? "")
                }
            }
        }
    }
    
    // Check if today is matching by given repeatDays
    func checkIfTodayIsMatching(repeatDays: [Int]) -> Bool {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())
        
        return repeatDays.contains(todayWeekday)
    }
    
    // Create Journal By Repeat Day
    func createJournalByRepeatDay(
        method: MethodType? = nil,
        repeatDay: [Int],
        dateComponent: Calendar.Component,
        value: Int,
        completion: @escaping (Date) async throws -> Void)
    {
        let (calendar, startDate) = getStartDate()
        if let endDate = calendar.date(byAdding: dateComponent, value: value, to: startDate) {
            for day in repeatDay {
                var dateDate = Date()
                calendar.enumerateDates(startingAfter: startDate-1, matching: DateComponents(weekday: day), matchingPolicy: .nextTime) { date, _, stop in
                    guard let date, date < endDate else {
                        stop = true
                        return
                    }
                    dateDate = date
                }
                Task {
                    do {
                        try await completion(dateDate)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    // Get StartDate
    func getStartDate() -> (Calendar, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        return (calendar, calendar.startOfDay(for: currentDate))
    }
    
    // Get All SubJournals From Given date
    func getAllSubJournalsByDate(userId: String, from date: Date) async throws -> [SubJournalDB]? {
        guard let journal = try await getJournal(userId: userId, from: date) else { return nil }
        return try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "NO ID").getAllDocuments(as: SubJournalDB.self)
    }
    
    // Get All SubJournals that filtered by Label
    func getFilterSubJournalByLabel(userId: String, from date: Date, label: [String]?) async throws -> [SubJournalDB]? {
        let journal = try await getJournal(userId: userId, from: date)
        if let journal,
           let label,
           !label.isEmpty
        {
            return try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "").whereField(SubJournalDB.CodingKeys.label.rawValue, in: label).getAllDocuments(as: SubJournalDB.self)
        }
        return try await getAllSubJournalsByDate(userId: userId, from: date)
    }
    
    // Get All SubJournals that filtered by progress
    func getSortedSubJournalByProgress(userId: String, from date: Date, isAscending: Bool) async throws -> [SubJournalDB]? {
        guard let subJournals = try await getAllSubJournalsByDate(userId: userId, from: date) else { return nil }
        return sortedSubJournals(subJournals, isAscending)
    }
    
    // Get All SubJournals that filtered by label and sorted by progress
    func getFilteredAndSortedAllSubJournals(userId: String, from date: Date, label: [String], isAscending: Bool) async throws -> [SubJournalDB]? {
        guard let subJournals = try await getFilterSubJournalByLabel(userId: userId, from: date, label: label) else { return nil }
        return sortedSubJournals(subJournals, isAscending)
    }
    
    //  Sort Sub Journals
    func sortedSubJournals(_ subJournals: [SubJournalDB], _ isAscending: Bool) -> [SubJournalDB]? {
        let sortedSubJournals = subJournals
            .filter { $0.frequencyCount != 0 }
            .sorted {
                let progress1 = Float($0.startFrequency ?? 0) / Float($0.frequencyCount ?? 1)
                let progress2 = Float($1.startFrequency ?? 0) / Float($1.frequencyCount ?? 1)
                return !isAscending ? progress1 < progress2 : progress1 > progress2
            }
        return sortedSubJournals
    }

}

