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


// MARK: CRUD For USER - DONE
extension UserManager: UserUseCase{
    // Create User to Firestore
    func addUser(user: UserDB) async throws {
        let document = try await userDocument(userId: user.id).getDocument()
        if document.exists {
            let data: [String: Any] = [ UserDB.CodingKeys.lastSignIn.rawValue: Date()]
            try await userDocument(userId: user.id).updateData(data)
        } else {
            try userDocument(userId: user.id).setData(from: user, merge: true)
            try await initFutureJournal(userId: user.id, repeatDay: dayInteger)
        }
    }
    
    // Check if user has a streak in firestore
    func checkIsUserStreak(userId: String) async throws -> Bool {
        let userDoc = try await getUserDB(userId: userId)
        return ((userDoc.streak?.id.isEmpty) != nil)
    }
    
    // Update is User Streak or not
    func updateUserStreak(userId: String, isStreak: Bool = false) async throws {
        let updatedData: [String: Any] = [
            UserDB.CodingKeys.isStreak.rawValue: isStreak
        ]
        try await userDocument(userId: userId).updateData(updatedData)
    }
    
    // Get User DB from Firestore than convert it to UserDB
    func getUserDB(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
    }
    
}

// MARK: CRUD For FutureJournal - DONE
extension UserManager: FutureJournalUseCase {
    // DONE -> Create Future Journal to Firestore
    func generateFutureJournal(userId: String, dateName: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .futureJournal)
        let futureJournal = FutureJournalDB(id: id, dateName: dateName)
        try document.setData(from: futureJournal, merge: false)
    }
    
    // DONE -> Get All Future Journal DB from FireStore
    func getAllFutureJournals(userId: String) async throws -> [FutureJournalDB]? {
        try await userFutureJournalCollection(userId: userId).getAllDocuments(as: FutureJournalDB.self)
    }
    
    // DONE -> Get Specify Future Journal DB from Firestore, tapi ga kepake
    func getFutureJournal(userId: String, from date: Date) async throws -> FutureJournalDB? {
        let snapshot = try await userFutureJournalCollection(userId: userId).whereField(FutureJournalDB.CodingKeys.dateName.rawValue, isEqualTo: date.getDayName).getDocuments()
        if let document = snapshot.documents.first {
            return try document.data(as: FutureJournalDB.self)
        }
        return nil
    }
}

// MARK: - CRUD For SubFutureJournal
extension UserManager: SubFutureJournalUseCase {
    // DONE -> Create subfuture journal
    func generateSubFutureJournal(userId: String, futureJournalId: String, subJournalType: SubJournalType, habitPomodoroId: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, futureJournalId: futureJournalId, type: .subFutureJournal)
        let subFutureJournal = SubFutureJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: subJournalType)
        try document.setData(from: subFutureJournal, merge: false)
    }
    
    func getAllSubFutureJournalsByDateName(userId: String) async throws -> [String: [SubFutureJournalDB]]? {
        var subFutureJournalsByDateName: [String: [SubFutureJournalDB]] = [:]

        guard let futureJournals = try await getAllFutureJournals(userId: userId) else {
            return subFutureJournalsByDateName
        }

        for futureJournal in futureJournals {
            guard let subFutureJournals = try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournal.id ?? "").getAllDocuments(as: SubFutureJournalDB.self) else {
                continue
            }
            subFutureJournalsByDateName[futureJournal.dateName ?? "", default: []].append(contentsOf: subFutureJournals)
        }
        print(subFutureJournalsByDateName)
        return subFutureJournalsByDateName
    }

    
    // DONE
    func getAllSubFutureJournals(userId: String, from date: Date) async throws -> [SubFutureJournalDB]? {
        let futureJournal = try await getFutureJournal(userId: userId, from: date)
        if let futureJournal {
            return try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournal.id ?? "").getAllDocuments(as: SubFutureJournalDB.self)
        }
        return nil
    }
    
    // DONE -> Delete subFutureJournal
    func deleteSubFutureJournal(userId: String, futureJournalId: String, subFutureJournalId: String) async throws {
        try await userSubFutureJournalDocument(userId: userId, futureJournalId: futureJournalId, subFutureJournalId: subFutureJournalId).delete()
    }
}

// MARK: - For Journal Use Case - DONE
extension UserManager: JournalUseCase {
    // DONE -> Create Journal aja
    func generateJournal(userId: String, date: Date) async throws {
        guard let subFutureJournals = try await getAllSubFutureJournals(userId: userId, from: date),
              try await (getJournal(userId: userId, from: date) == nil)
        else { return }
        let (document, id) = generateDocumentID(userId: userId, type: nil)
        let journal = JournalDB(id: id, date: date, dateName: date.getDayName, undoStreak: false, todayStreak: false, hasSubJournal: false)
        try document.setData(from: journal, merge: false)
        
        for subFutureJournal in subFutureJournals {
            if subFutureJournal.subJournalType == .habit {
                let habit = try await getHabitDetail(userId: userId, habitId: subFutureJournal.habitPomodoroId ?? "")
                try await generateSubJournal(userId: userId, journalId: id, type: subFutureJournal.subJournalType ?? .habit, habitPomodoroId: subFutureJournal.habitPomodoroId ?? "", label: habit?.label ?? "", frequencyCount: habit?.frequency ?? 0)
                try await updateHasSubJournal(userId: userId, from: date)
            } else {
                let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: subFutureJournal.habitPomodoroId ?? "")
                try await generateSubJournal(userId: userId, journalId: id, type: subFutureJournal.subJournalType ?? .pomodoro, habitPomodoroId: subFutureJournal.habitPomodoroId ?? "", label: pomodoro?.label ?? "", frequencyCount: pomodoro?.session ?? 0)
                try await updateHasSubJournal(userId: userId, from: date)
            }
        }
    }
    
    // DONE -> Ngecek apakah journal punya subjournal dan apakah journal itu ada yang complete atau ga -> Ini buat di checkIsStreak
    func checkHasSubJournalAndIsComepleted(userId: String, startDate: Date, endDate: Date) async throws -> Bool {
        let snapshotHasSubJournal = try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(JournalDB.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
            .whereField(JournalDB.CodingKeys.hasSubJournal.rawValue, isEqualTo: true)
            .getDocuments()
        
        let snapshotTodayStreak = try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.date.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(JournalDB.CodingKeys.date.rawValue, isLessThanOrEqualTo: endDate)
            .whereField(JournalDB.CodingKeys.todayStreak.rawValue, isEqualTo: true)
            .getDocuments()
        return snapshotTodayStreak.count == snapshotHasSubJournal.count
    }
    
    // DONE -> Ngecek apakah si journal punya subjournal atau ga
    func checkHasSubJournals(userId: String) async throws -> [Date]? {
        guard let journals = try await getAllJournal(userId: userId) else {
            return []
        }
        var results: [Date] = []
        for journal in journals {
            guard let hasSubJournal = journal.hasSubJournal,
                  hasSubJournal != false
            else {
                continue
            }
            results.append(journal.date ?? Date())
        }
        return results
    }
    
    // DONE -> Update apakah si journal punya subjournal atau ga, kalo ada update true
    func updateHasSubJournal(userId: String, from date: Date, hasSubJournal: Bool = true) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.hasSubJournal.rawValue: hasSubJournal
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    // DONE -> Ngecek apakah user pada hari itu pernah undo si journal atau ga
    func checkHasUndo(userId: String, from date: Date) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: date)
        return journal?.undoStreak ?? false
    }
    
    // DONE -> update apakah user pada hari itu pernah undo si journal atau ga
    func updateHasUndo(userId: String, from date: Date, isUndo: Bool = false) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.undoStreak.rawValue: isUndo
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    // DONE -> Ngecek apakah user pada hari itu ngelakuin Streak atau ga
    func checkTodayStreak(userId: String, from date: Date) async throws -> Bool {
        let journal = try await getJournal(userId: userId, from: date)
        return journal?.todayStreak ?? false
    }
    
    // DONE -> update apakah user pada hari itu ngelakuin streak atau ga, kalo dia ngelakuin streak dia true
    func updateTodayStreak(userId: String, from date: Date, isTodayStreak: Bool = false) async throws {
        let journal = try await getJournal(userId: userId, from: date)
        let updatedData: [String: Any] = [
            JournalDB.CodingKeys.todayStreak.rawValue: isTodayStreak
        ]
        try await userJournalDocument(userId: userId, journalId: journal?.id ?? "").updateData(updatedData)
    }
    
    // DONE -> Dapetin semua journal, keknya gakepake
    func getAllJournal(userId: String) async throws -> [JournalDB]? {
        return try await userJournalCollection(userId: userId).order(by: JournalDB.CodingKeys.date.rawValue, descending: false).getAllDocuments(as: JournalDB.self)
    }
    
    // DONE -> Dapetin journal spesifik berdasarkan date yang diberikan
    func getJournal(userId: String, from date: Date) async throws -> JournalDB? {
        let snapshot = try await userJournalCollection(userId: userId).whereDateField(JournalDB.CodingKeys.date.rawValue, isEqualToDate: date).getDocuments()
        if let document = snapshot.documents.first {
            let journal = try document.data(as: JournalDB.self)
            return journal
        } else {
            return nil
        }
    }
    
    // DONE -> Dapetin semua journal selama 1 bulan
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
}

// MARK: - For SubJournal Use Case - WIP
extension UserManager: SubJournalUseCase {
    // DONE - For Generate Sub Journal
    func generateSubJournal(userId: String, journalId: String, type: SubJournalType, habitPomodoroId: String, label: String, frequencyCount: Int) async throws {
        let (document, id) = generateDocumentID(userId: userId, journalId: journalId, type: .subJournal)
        let subJournal = SubJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: type, label: label, frequencyCount: frequencyCount, startFrequency: 0, fraction: 0, isCompleted: false)
        try document.setData(from: subJournal, merge: false)
    }
    
    //DONE -> Update count si subjournal yang ada di card"nya itu
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
    
    // DONE -> Undo count si subjournal yang ada di card"nya itu
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
    
    // DONE -> Ngecek apakah ada subJournal yang complete dari si journal dari date yang diberikan
    func checkCompletedSubJournal(userId: String, from date: Date) async throws -> Bool {
        guard let journal = try await getJournal(userId: userId, from: date) else { return false }
        let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "").whereField(SubJournalDB.CodingKeys.isCompleted.rawValue, isEqualTo: true).getDocuments()
        if let document = snapshot.documents.first {
            return document.exists
        }
        return false
    }
    
    // DONE -> Ngelakuin update kalau dari journal tersebut si subJournalnya ada yang complete
    func updateSubJournalCompleted(userId: String, journalId: String, subJournalId: String, isCompleted: Bool = true) async throws {
        let data: [String: Any] = [
            SubJournalDB.CodingKeys.isCompleted.rawValue: isCompleted
        ]
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).updateData(data)
    }
    
    // DONE -> Cari tau apakah journal tersebut sudah complete atau belum dari pembagian startFrequency/frequencyCount
    func isSubJournalComplete(userId: String, journalId: String, subJournalId: String) async throws -> Bool {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        return subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int == (((subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue]) as? Int ?? 0) - 1 )
    }
    
    // DONE -> Ngasih tau kalau si startFrequency udah 0, tujuannya kalo udah 0 gabisa di undo lagi
    func checkStartFrequencyIsZero(userId: String, journalId: String, subJournalId: String) async throws -> Bool {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        return subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int == 0
    }
    
    // DONE -> Dapetin seluruh subjournals berdasarkan date, label, dan isAscending
    func getSubJournals(userId: String, from date: Date, label: [String]?, isAscending: Bool?) async throws -> [SubJournalDB]? {
        if let label, let isAscending {
            return try await getFilteredAndSortedAllSubJournals(userId: userId, from: date, label: label, isAscending: isAscending)
        } else if let isAscending {
            return try await getFilteredSubJournalByProgress(userId: userId, from: date, isAscending: isAscending)
        } else if let label {
            return try await getFilterSubJournalByLabel(userId: userId, from: date, label: label)
        } else {
            return try await getAllSubJournalsByDate(userId: userId, from: date)
        }
    }
    
    func getSubJournalByHabitID(userId: String, habitId: String) async throws -> DocumentReference? {
        let journal = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let snapshot = try await userSubJournalCollection(userId: userId, journalId: journal?.id ?? "")
            .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId)
            .getDocuments()
        if let document = snapshot.documents.first {
            return document.reference
        }
        return nil
    }
    
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
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    
    // DONE -> Create habit baru
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String) async throws {
        let journalDocument = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let (document, id) = generateDocumentID(userId: userId, type: .habit)
        let habit = HabitDB(id: id, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: reminderHabit, dateCreated: Date())
        try document.setData(from: habit, merge: false)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: id, type: .habit, method: .generate, repeatHabit: repeatHabit, frequencyCount: frequency)
        if checkIfTodayIsMatching(repeatDays: repeatHabit) {
            try await generateSubJournal(userId: userId, journalId: journalDocument?.id ?? "No ID", type: .habit, habitPomodoroId: id, label: label, frequencyCount: frequency)
            try await updateHasSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        }
    }
    
    func getHabitNotificationId(userId: String) async throws -> String {
        let habitDocument = try await userHabitCollection(userId: userId).getAllDocuments(as: HabitDB.self)
        let pomodoroDocument = try await userHabitCollection(userId: userId).getAllDocuments(as: PomodoroDB.self)
        return "\((habitDocument?.count ?? 0) + (pomodoroDocument?.count ?? 0))"
    }
    
    // DONE -> Dapetin detail habit
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB? {
        return try await userHabitDocument(userId: userId, habitId: habitId).getDocument(as: HabitDB.self)
    }
    
    // DONE -> Dapetin progress habit buat di HabitDetailView yang calendar
    func getProgressHabit(userId: String, habitId: String, month: Date) async throws -> [Int: CGFloat]? {
        var progressValues: [Int: CGFloat] = [:]

        guard let journalDocuments = try await getJournalForOneMonth(userId: userId, forMonth: month) else {
            return nil
        }
        for journalDocument in journalDocuments {
            // dapetin subjournal yang punya habit pomodoro id sama kek habit id
            guard let subJournalDocuments = try await userSubJournalCollection(userId: userId, journalId: journalDocument.id ?? "")
                    .whereField(SubJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitId)
                    .getAllDocuments(as: SubJournalDB.self), subJournalDocuments.count != 0
            else {
                // subjournal ga ada di hari itu
                progressValues[journalDocument.date!.get(.day)] = 0.0
                continue
            }
            
            for subJournalDocument in subJournalDocuments {
                if subJournalDocument.frequencyCount != 0 {
                    let progress = Float(subJournalDocument.startFrequency ?? 0) / Float(subJournalDocument.frequencyCount ?? 0)
                    progressValues[journalDocument.date!.get(.day)] = CGFloat(progress)
                }
            }
        }
        return progressValues.isEmpty ? nil : progressValues
    }
    
    // Buat edit habit
    func editHabit(userId: String, habitId: String, habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Int]?, reminderHabit: String?) async throws  {
        let habit = try await getHabitDetail(userId: userId, habitId: habitId)
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
        }
        try await userHabitDocument(userId: userId, habitId: habitId).updateData(updatedData)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: habitId, method: .generate, repeatHabit: [3, 4])
    }
    
    // DONE -> Buat delete habit
    func deleteHabit(userId: String, habitId: String) async throws {
        try await userHabitDocument(userId: userId, habitId: habitId).delete()
        try await getSubJournalByHabitID(userId: userId, habitId: habitId)?.delete()
        let habit = try await getHabitDetail(userId: userId, habitId: habitId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: habitId, method: .delete, repeatHabit: habit?.repeatHabit ?? [])
    }
}

extension UserManager: PomodoroUseCase {
    // DONE -> Buat create pomodoro baru
    func createNewPomodoro(userId: String, pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, longBreakTime: Int, repeatPomodoro: [Int], reminderPomodoro: String) async throws {
        let journalDocument = try await getJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        let (document, id) = generateDocumentID(userId: userId, type: .pomodoro)
        let pomodoro = PomodoroDB(id: id, pomodoroName: pomodoroName, description: description, label: label, session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderPomodoro: reminderPomodoro, dateCreated: Date())
        try document.setData(from: pomodoro, merge: false)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: id, type: .pomodoro, method: .generate, repeatHabit: repeatPomodoro, frequencyCount: session)
        if checkIfTodayIsMatching(repeatDays: repeatPomodoro) {
            try await generateSubJournal(userId: userId, journalId: journalDocument?.id ?? "No ID", type: .pomodoro, habitPomodoroId: id, label: label, frequencyCount: session)
            try await updateHasSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName))
        }
    }
    
    // DONE -> Buat dapetin progress pomodoro selama 1 bulan, buat di PomodoroDetailView bagian calendar
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
    
    // DONE -> Buat dapetin pomodoroDetail
    func getPomodoroDetail(userId: String, pomodoroId: String) async throws -> PomodoroDB? {
        return try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).getDocument(as: PomodoroDB.self)
    }
    
    // NOT YET TEST - Functionality is DONE, but for APP not tested -> Buat edit pomodoro
    func editPomodoro(userId: String, pomodoroId: String, pomodoroName: String?, description: String?, label: String?, session: Int?, focusTime: Int?, breakTime: Int?, repeatPomodoro: [Int]?, reminderPomodoro: String?) async throws -> PomodoroDB? {
        let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, method: .delete, repeatHabit: pomodoro?.repeatPomodoro ?? [])
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
        if let breakTime {
            updatedData[PomodoroDB.CodingKeys.breakTime.rawValue] = breakTime
        }
        if let repeatPomodoro {
            updatedData[PomodoroDB.CodingKeys.repeatPomodoro.rawValue] = repeatPomodoro
        }
        if let reminderPomodoro {
            updatedData[PomodoroDB.CodingKeys.reminderPomodoro.rawValue] = reminderPomodoro
        }
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).updateData(updatedData)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, method: .generate, repeatHabit: [3, 4])
        return try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
    }
    
    // DONE -> Delete pomodoro
    func deletePomodoro(userId: String, pomodoroId: String) async throws {
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).delete()
        try await getSubJournalByPomodoroID(userId: userId, pomodoroID: pomodoroId)?.delete()
        let pomodoro = try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
        try await manageSubFutureJournal(userId: userId, habitPomodoroId: pomodoroId, method: .delete, repeatHabit: pomodoro?.repeatPomodoro ?? [])
    }
}

// MARK: - CRUD for Streak - DONE
extension UserManager: StreakUseCase {
    // DONE -> Buat ngecreate streak
    func createStreak(userId: String, description: String) async throws {
        let streak = StreakDB(streaksCount: 1, dateCreated: Date())
        guard let data = try? encoder.encode(streak) else { return }
        let dict: [String: Any] = [
            UserDB.CodingKeys.streak.rawValue: data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    // DONE -> Buat dapeting data streak
    func getStreak(userId: String) async throws -> StreakDB? {
        let userDoc = try await getUserDB(userId: userId)
        return userDoc.streak
    }
    
    // DONE -> Ngecek apakah si streak merupakan streak yang pertama atau bukan
    func checkIsFirstStreak(userId: String) async throws -> Bool {
        let streak = try await getStreak(userId: userId)
        return streak?.streaksCount == 1
    }
    
    // DONE -> Ngeupdate count streak
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
    
    // DONE -> Delete Streak
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
    
    // Ini buat generateDocumentID aja bawaan dari si firestore
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
    
    // Buat nge init future journal pertama kali kalo user login
    func initFutureJournal(userId: String, repeatDay: [Int]) async throws {
        createJournalByRepeatDay(repeatDay: repeatDay, dateComponent: .weekday, value: 7) { [weak self] date in
            try await self?.generateFutureJournal(userId: userId, dateName: date.getDayName)
        }
    }
    
    // Buat dapet si futureJournal berdasarkan dayNamenya
    func getFutureJournalByDateName(userId: String, dayName: String) async  throws -> QuerySnapshot {
        try await userFutureJournalCollection(userId: userId)
            .whereField(FutureJournalDB.CodingKeys.dateName.rawValue, isEqualTo: dayName)
            .getDocuments()
    }
    
    // Buat dapet si futureJournal berdasarkan HabitPomodoroID
    func getSubFutureJournalByHabitPomodoroId(userId: String, futureJournalId: String, habitPomodoroId: String) async throws -> QuerySnapshot {
        try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId)
            .whereField(SubFutureJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitPomodoroId)
            .getDocuments()
    }
     
    // Buat manage so SubFutureJournal apakah dia bakal ngegenerate atau ngedelete
    func manageSubFutureJournal(userId: String, habitPomodoroId: String, type: SubJournalType? = nil, method: MethodType, repeatHabit: [Int], frequencyCount: Int? = nil) async throws {
        createJournalByRepeatDay(method: method, repeatDay: repeatHabit, dateComponent: .weekday, value: 7) { [weak self] date in
            guard let snapshot = try await self?.getFutureJournalByDateName(userId: userId, dayName: date.getDayName) else { return }
            for futureJournalDocument in snapshot.documents {
                switch method {
                case .generate:
                    try await self?.generateSubFutureJournal(userId: userId, futureJournalId: futureJournalDocument.documentID, subJournalType: type ?? .habit, habitPomodoroId: habitPomodoroId)
                case .delete:
                    let subFutureJournalQueryDocument = try await self?.getSubFutureJournalByHabitPomodoroId(userId: userId, futureJournalId: futureJournalDocument.documentID, habitPomodoroId: habitPomodoroId)
                    try await self?.deleteSubFutureJournal(userId: userId, futureJournalId: futureJournalDocument.documentID, subFutureJournalId: subFutureJournalQueryDocument?.documents.first?.documentID ?? "")
                }
            }
        }
    }
    
    // Ngecek aja kalo hari ini sama dari si RepeatDays dia bakal ngegenerate si user
    func checkIfTodayIsMatching(repeatDays: [Int]) -> Bool {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())
        
        return repeatDays.contains(todayWeekday)
    }
    
    // Ngenerate journal berdasarkan repeatDay si Habit
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
    
    // Buat dapetin startdate
    func getStartDate() -> (Calendar, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        return (calendar, calendar.startOfDay(for: currentDate))
    }
    
    // DONE -> Buat dapetin seluruh subjournal berdasarkan date
    func getAllSubJournalsByDate(userId: String, from date: Date) async throws -> [SubJournalDB]? {
        guard let journal = try await getJournal(userId: userId, from: date) else { return nil }
        return try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "NO ID").getAllDocuments(as: SubJournalDB.self)
    }
    
    // DONE -> Buat filter subjournal berdasarkan label
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
    
    // DONE -> Buat filter subjournal berdasarkan progressnya
    func getFilteredSubJournalByProgress(userId: String, from date: Date, isAscending: Bool) async throws -> [SubJournalDB]? {
        guard let subJournals = try await getAllSubJournalsByDate(userId: userId, from: date) else { return nil }
        return sortedSubJournals(subJournals, isAscending)
    }
    
    // DONE -> Buat filter subjournal berdasarkan label dan sorted berdasarkan progress
    func getFilteredAndSortedAllSubJournals(userId: String, from date: Date, label: [String], isAscending: Bool) async throws -> [SubJournalDB]? {
        guard let subJournals = try await getFilterSubJournalByLabel(userId: userId, from: date, label: label) else { return nil }
        return sortedSubJournals(subJournals, isAscending)
    }
    
    // DONE -> Sort si subjournal berdasarkan progress
    func sortedSubJournals(_ subJournals: [SubJournalDB], _ isAscending: Bool) -> [SubJournalDB]? {
        let sortedSubJournals = subJournals
            .filter { $0.frequencyCount != 0 }
            .sorted {
                let progress1 = Float($0.startFrequency ?? 0) / Float($0.frequencyCount ?? 1)
                let progress2 = Float($1.startFrequency ?? 0) / Float($1.frequencyCount ?? 1)
                return isAscending ? progress1 < progress2 : progress1 > progress2
            }
        return sortedSubJournals
    }

}

