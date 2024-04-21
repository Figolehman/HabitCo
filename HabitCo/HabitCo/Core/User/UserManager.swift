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

// MARK: - For private func
private extension UserManager{
    
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
        userFutureJournalDocument(userId: userId, futureJournalId: futureJournalId).collection("future_journals")
    }
    
    func userSubFutureJournalDocument(userId: String, futureJournalId: String, subFutureJournalId: String) -> DocumentReference{
        userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId).document(subFutureJournalId)
    }
    
    // HabitDB Collection
    func userHabitCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("habits")
    }
    
    func userHabitDocument(userId: String, habitId: String) -> DocumentReference {
        userHabitCollection(userId: userId).document(habitId)
    }
    
    // Pomodoro Collection
    func userPomodoroCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("pomodoro")
    }
    
    func userPomodoroDocument(userId: String, pomodoroId: String) -> DocumentReference {
        userPomodoroCollection(userId: userId).document(pomodoroId)
    }
    
    func generateDocumentID(userId: String, journalId: String? = nil, futureJournalId: String? = nil, type: JournalType?) -> (DocumentReference, String){
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
    
    func getJournalDocumentByDateName(userId: String, dayName: String) async throws -> QuerySnapshot {
        try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.dateName.rawValue, isEqualTo:  dayName)
            .getDocuments()
    }
    
    func getFutureJournalByDateName(userId: String, dayName: String) async  throws -> QuerySnapshot {
        try await userFutureJournalCollection(userId: userId)
            .whereField(FutureJournalDB.CodingKeys.dateName.rawValue, isEqualTo: dayName)
            .getDocuments()
    }
    
    func getSubFutureJournalByHabitPomodoroId(userId: String, futureJournalId: String, habitPomodoroId: String) async throws -> QuerySnapshot {
        try await userSubFutureJournalCollection(userId: userId, futureJournalId: futureJournalId)
            .whereField(SubFutureJournalDB.CodingKeys.habitPomodoroId.rawValue, isEqualTo: habitPomodoroId)
            .getDocuments()
    }
    
    func initFutureJournal(userId: String, repeatDay: [Int]) async throws {
        generateAnyJournal(userId: userId, repeatDay: repeatDay) { [weak self] date in
            try await self?.generateFutureJournal(userId: userId, dateName: date.getDayName)
        }
    }
    
    func manageSubJournalBasedOnRepeatDay(userId: String, habitPomodoroId: String, type: SubJournalType? = nil, method: MethodType, repeatHabit: [Int], frequencyCount: Int? = nil) async throws {
        generateAnyJournal(userId: userId, habitPomodoroId: habitPomodoroId, type: type, method: method, repeatDay: repeatHabit) { [weak self] date in
            guard let futureJournalQueryDocument = try await self?.getFutureJournalByDateName(userId: userId, dayName: date.getDayName) else { return }
            for futureJournalDocument in futureJournalQueryDocument.documents {
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
    
    func generateAnyJournal(userId: String, 
                            habitPomodoroId: String? = nil,
                            type: SubJournalType? = nil,
                            method: MethodType? = nil,
                            repeatDay: [Int],
                            frequencyCount: Int? = nil,
                            completion: @escaping (Date) async throws -> ()) {
        let (calendar, startDate) = getStartDate()
        if let endDate = calendar.date(byAdding: .weekday, value: 7, to: startDate) {
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
    
    func getStartDate() -> (Calendar, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        return (calendar, calendar.startOfDay(for: currentDate))
    }
    
}

// MARK: CRUD For USER - DONE
extension UserManager: UserUseCase{
    
    func addUser(user: UserDB) async throws{
        let document = try await userDocument(userId: user.id).getDocument()
        if document.exists {
            let data: [String: Any] = [ UserDB.CodingKeys.lastSignIn.rawValue: Date()]
            try await userDocument(userId: user.id).updateData(data)
        } else {
            try userDocument(userId: user.id).setData(from: user, merge: true)
            try await initFutureJournal(userId: user.id, repeatDay: dayInteger)
        }
    }
    
    func getUserDB(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
    }
}

// MARK: CRUD For FutureJournal - DONE
extension UserManager: FutureJournalUseCase {
    func generateFutureJournal(userId: String, dateName: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .futureJournal)
        let futureJournal = FutureJournalDB(id: id, dateName: dateName)
        try document.setData(from: futureJournal, merge: false)
    }
}

// MARK: - CRUD For SubFutureJournal - DONE
extension UserManager: SubFutureJournalUseCase {
    func generateSubFutureJournal(userId: String, futureJournalId: String, subJournalType: SubJournalType, habitPomodoroId: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, futureJournalId: futureJournalId, type: .subFutureJournal)
        let subFutureJournal = SubFutureJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: subJournalType)
        try document.setData(from: subFutureJournal, merge: false)
    }
    
    func deleteSubFutureJournal(userId: String, futureJournalId: String, subFutureJournalId: String) async throws {
        try await userSubFutureJournalDocument(userId: userId, futureJournalId: futureJournalId, subFutureJournalId: subFutureJournalId).delete()
    }
}

// MARK: - For Journal Use Case
extension UserManager: JournalUseCase {
    func generateJournal(userId: String, date: Date) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: nil)
        let journal = JournalDB(id: id, date: date, dateName: date.getDayName)
        try document.setData(from: journal, merge: false)
    }
    
    // Use for calendar
    func getAllJournal(userId: String) async throws -> [JournalDB]? {
        return try await userJournalCollection(userId: userId).order(by: JournalDB.CodingKeys.date.rawValue, descending: false).getAllDocuments(as: JournalDB.self)
    }
    
    func getDetailJournal(userId: String, from date: Date) async throws -> JournalDB? {
        let snapshot = try await userJournalCollection(userId: userId).whereDateField(JournalDB.CodingKeys.date.rawValue, isEqualToDate: date).getDocuments()
        if let document = snapshot.documents.first {
            let journal = try document.data(as: JournalDB.self)
            return journal
        } else {
            return nil
        }
    }
}

// MARK: - For SubJournal Use Case - WIP
extension UserManager: SubJournalUseCase {
    func generateSubJournal(userId: String, journalId: String, type: SubJournalType, habitPomodoroId: String, frequencyCount: Int) async throws {
        let (document, id) = generateDocumentID(userId: userId, journalId: journalId, type: .subJournal)
        let subJournal = SubJournalDB(id: id, habitPomodoroId: habitPomodoroId, subJournalType: type, frequencyCount: frequencyCount, startFrequency: 0)
        try document.setData(from: subJournal, merge: false)
    }
    
    func getSubJournal(userId: String, from date: Date) async throws -> [SubJournalDB]? {
        let journal = try await getDetailJournal(userId: userId, from: date)
        if let journal {
            let subJournal = try await userSubJournalCollection(userId: userId, journalId: journal.id ?? "NO ID").getAllDocuments(as: SubJournalDB.self)
            return subJournal
        }
        return nil
    }
    
    func updateCountSubJournal(userId: String, journalId: String, subJournalId: String) async throws {
        let subJournalDocument = try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).getDocument()
        guard var count = subJournalDocument.data()?[SubJournalDB.CodingKeys.startFrequency.rawValue] as? Int, count < subJournalDocument.data()?[SubJournalDB.CodingKeys.frequencyCount.rawValue] as? Int ?? 0 else { return }
        let data: [String: Any] = [
            SubJournalDB.CodingKeys.startFrequency.rawValue: count += 1
        ]
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).updateData(data)
    }
    
    func deleteSubJournal(userId: String, journalId: String, subJournalId: String) async throws {
        try await userSubJournalDocument(userId: userId, journalId: journalId, subJournalId: subJournalId).delete()
    }
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String, dateCreated: Date) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .habit)
        let habit = HabitDB(id: id, habitName: "Baca kamus", description: "Baca buku supaya pintar", label: "Blue Label", frequency: 2, repeatHabit: [1, 2, 6], reminderHabit: "12:00", dateCreated: Date())
        try document.setData(from: habit, merge: false)
        try await manageSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: id, type: .habit, method: .generate, repeatHabit: [1, 2, 6], frequencyCount: frequency)
    }
    
    func getAllHabitByDate(userId: String, date: Date) async throws -> [HabitDB]?{
        try await userHabitCollection(userId: userId).getAllDocuments(as: HabitDB.self)
    }
    
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB? {
        return try await userHabitDocument(userId: userId, habitId: habitId).getDocument(as: HabitDB.self)
    }
    
    func editHabit(userId: String, habitId: String, repeatHabit: [Int]?) async throws -> HabitDB? {
        let habit = try await getHabitDetail(userId: userId, habitId: habitId)
        try await manageSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: habitId, method: .delete, repeatHabit: habit?.repeatHabit ?? [])
        let data: [String: Any] = [
            HabitDB.CodingKeys.repeatHabit.rawValue: [3, 4]
        ]
        print("Trigger")
        try await userHabitDocument(userId: userId, habitId: habitId).updateData(data)
        try await manageSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: habitId, method: .generate, repeatHabit: [3, 4])
        return try await getHabitDetail(userId: userId, habitId: habitId)
    }
    
    func deleteHabit(userId: String, habitId: String) async throws {
        try await userHabitDocument(userId: userId, habitId: habitId).delete()
    }
}

extension UserManager: PomodoroUseCase {
    func createNewPomodoro(userId: String, pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, repeatPomodoro: [Int], reminderPomodoro: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .pomodoro)
        let pomodoro = PomodoroDB(id: id, pomodoroName: "Pomodoro 3", description: "Ini pomodoro malem", label: "Orange Label", session: 1, focusTime: 2, breakTime: 3, repeatPomodoro: [1, 2, 3], reminderPomodoro: "21:00", dateCreated: Date())
        try document.setData(from: pomodoro, merge: false)
        try await manageSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: id, type: .pomodoro, method: .generate, repeatHabit: [3, 4], frequencyCount: session)
    }
    
    func getAllPomodoroByDate(userId: String, date: Date) async throws -> [PomodoroDB]? {
        // Need change logic for integrate with apps
        return try await userPomodoroCollection(userId: userId).getAllDocuments(as: PomodoroDB.self)
    }
    
    func getPomodoroDetail(userId: String, pomodoroId: String) async throws -> PomodoroDB? {
        return try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).getDocument(as: PomodoroDB.self)
    }
    
    func editPomodoro(userId: String, pomodoroId: String) async throws -> PomodoroDB? {
        let data: [String: Any] = [
            : // need more context about the flow
        ]
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).updateData(data)
        return try await getPomodoroDetail(userId: userId, pomodoroId: pomodoroId)
    }
    
    func deletePomodoro(userId: String, pomodoroId: String) async throws {
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).delete()
    }
}

extension UserManager: StreakUseCase{
    
    func createStreak(userId: String, description: String) async throws {
        let streak = StreakDB(streaksCount: 1, description: description, isStreak: true, dateCreated: Date())
        guard let data = try? encoder.encode(streak) else { return }
        let dict: [String: Any] = [
            UserDB.CodingKeys.streak.rawValue: data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func updateCountStreak(userId: String) async throws -> UserDB? {
        return nil
    }
    
    func deleteStreak(userId: String) async throws {
        let data: [String: Any?] = [
            UserDB.CodingKeys.streak.rawValue: nil
        ]
        try await userDocument(userId: userId).updateData(data as [AnyHashable: Any])
    }
}
