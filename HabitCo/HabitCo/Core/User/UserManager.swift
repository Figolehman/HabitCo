//
//  UserManager.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 15/03/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum JournalType: String{
    case habit = "habits"
    case pomodoro = "pomodoros"
    case subJournal = "sub_journals"
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
    
    // SubJournalCollection
    func userSubJournalCollection(userId: String, journalId: String) -> CollectionReference {
        userJournalDocument(userId: userId, journalId: journalId).collection("sub_journals")
    }
    
    func userSubJournalDocument(userId: String, journalId: String, subJournalId: String) -> DocumentReference{
        userSubJournalCollection(userId: userId, journalId: journalId).document(subJournalId)
    }
    
    func generateDocumentID(userId: String, journalId: String? = nil, type: JournalType?) -> (DocumentReference, String){
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
        case .none:
            let journalDocument =  userJournalCollection(userId: userId).document()
            return (journalDocument, journalDocument.documentID)
        }
    }
    
    func getJournalDocumentByDateName(userId: String, dayName: String) async throws -> QuerySnapshot {
        return try await userJournalCollection(userId: userId)
            .whereField(JournalDB.CodingKeys.dateName.rawValue, isEqualTo:  dayName)
            .getDocuments()
    }
    
    func addJournalForOneMonth(userId: String, reminderDay: [Int]) async throws {
        let calendar = Calendar.current
        let currentDate = Date()
        let startDate = calendar.startOfDay(for: currentDate)
        if let endDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            for day in reminderDay {
                print(day)
                calendar.enumerateDates(startingAfter: startDate, matching: DateComponents(weekday: day), matchingPolicy: .nextTime) { date, _, stop in
                    guard let date, date < endDate else {
                        stop = true
                        return
                    }
                    Task {
                        do {
                            try await generateJournal(userId: userId, date: date)
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func addSubJournalBasedOnRepeatDay(userId: String, habitPomodoroId: String, reminderDay: [Int], frequencyCount: Int) async throws {
        let calendar = Calendar.current
        let currentDate = Date()
        let startDate = calendar.startOfDay(for: currentDate)
        if let endDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            for day in reminderDay {
                var dateDate = Date()
                calendar.enumerateDates(startingAfter: startDate, matching: DateComponents(weekday: day), matchingPolicy: .nextTime) { date, _, stop in
                    guard let date, date < endDate else {
                        stop = true
                        return
                    }
                    dateDate = date
                }
                Task {
                    do {
                        let journalQueryDocument = try await getJournalDocumentByDateName(userId: userId, dayName: dateDate.getDayName)
                        for document in journalQueryDocument.documents {
                            try await generateSubJournal(userId: userId, journalId: document.documentID, habitPomodoroId: habitPomodoroId, frequencyCount: frequencyCount)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }

}

// MARK: CRUD For Firestore
extension UserManager: UserUseCase{
    
    func addUser(user: UserDB) async throws{
        let document = try await userDocument(userId: user.id).getDocument()
        if document.exists {
            let data: [String: Any] = [ UserDB.CodingKeys.lastSignIn.rawValue: Date()]
            try await userDocument(userId: user.id).updateData(data)
        } else {
            try userDocument(userId: user.id).setData(from: user, merge: true)
        }
        try await addJournalForOneMonth(userId: user.id, reminderDay: dayInteger)
    }
    
    func getUserDB(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
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
        let journals = try await userJournalCollection(userId: userId).getAllDocuments(as: JournalDB.self)
        return journals
    }
    
    func getDetailJournal(userId: String, from date: Date) async throws -> JournalDB? {
        let snapshot = try await userJournalCollection(userId: userId).whereField(JournalDB.CodingKeys.date.rawValue, isDateInToday: date).limit(to: 1).getDocuments()
        if let document = snapshot.documents.first {
            let journal = try document.data(as: JournalDB.self)
            return journal
        } else {
            return nil
        }
    }
    
}

extension UserManager {
    func generateSubJournal(userId: String, journalId: String, habitPomodoroId: String, frequencyCount: Int) async throws {
        let (document, id) = generateDocumentID(userId: userId, journalId: journalId, type: .subJournal)
        let subJournal = SubJournalDB(id: id, habitPomodoroId: habitPomodoroId, frequencyCount: frequencyCount)
        try document.setData(from: subJournal, merge: false)
        print("Generate")
    }
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String, dateCreated: Date) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .habit)
        let habit = HabitDB(id: id, habitName: "Baca kamus", description: "Baca buku supaya pintar", label: "Blue Label", frequency: 2, repeatHabit: [1, 2, 6], reminderHabit: "12:00", dateCreated: Date())
        try document.setData(from: habit, merge: false)
        try await addSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: id, reminderDay: [3, 4], frequencyCount: frequency)
    }
    
    func getAllHabitByDate(userId: String, date: Date) async throws -> [HabitDB]?{
        try await userHabitCollection(userId: userId)
            .whereField(HabitDB.CodingKeys.reminderHabit.rawValue, isDateInToday: Date())
            .getAllDocuments(as: HabitDB.self)
    }
    
    func getAllHabit(userId: String) async throws -> [HabitDB]?{
        try await userHabitCollection(userId: userId)
            .getAllDocuments(as: HabitDB.self)
    }
    
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB? {
        return try await userHabitDocument(userId: userId, habitId: habitId).getDocument(as: HabitDB.self)
    }
    
    func editHabit(userId: String, habitId: String) async throws -> HabitDB?{
        let data: [String: Any] = [
            : // need more context about the flow
        ]
        try await userHabitDocument(userId: userId, habitId: habitId).updateData(data)
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
        try await addSubJournalBasedOnRepeatDay(userId: userId, habitPomodoroId: id, reminderDay: [3, 4], frequencyCount: session)
    }
    
    func getAllPomodoroByDate(userId: String, date: Date) async throws -> [PomodoroDB]? {
        // Need change logic for integrate with apps
        return try await userPomodoroCollection(userId: userId)
            .whereField(PomodoroDB.CodingKeys.reminderPomodoro.rawValue, isDateInToday: Date())
            .getAllDocuments(as: PomodoroDB.self)
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
