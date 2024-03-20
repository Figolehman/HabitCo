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
}

@MainActor
final class UserManager {
    
    static let shared = UserManager()
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private let encoder: Firestore.Encoder = {
        return Firestore.Encoder()
    }()
    
    private let decoder: Firestore.Decoder = {
        return Firestore.Decoder()
    }()
}

// MARK: - For private func
extension UserManager{
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userJournalCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("journals")
    }
    
    private func userJournalDocument(userId: String, journalId: String) -> DocumentReference{
        userJournalCollection(userId: userId).document(journalId)
    }
    
    // HabitDB Collection
    private func userHabitCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("habits")
    }
    
    private func userHabitDocument(userId: String, habitId: String) -> DocumentReference {
        userHabitCollection(userId: userId).document(habitId)
    }
    
    // Pomodoro Collection
    private func userPomodoroCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("pomodoro")
    }
    
    private func userPomodoroDocument(userId: String, pomodoroId: String) -> DocumentReference {
        userPomodoroCollection(userId: userId).document(pomodoroId)
    }
    
    private func generateDocumentID(userId: String, type: JournalType?) -> (DocumentReference, String){
        switch type {
        case .habit:
            let habitDocument = userHabitCollection(userId: userId).document()
            return (habitDocument, habitDocument.documentID)
        case .pomodoro:
            let pomodoroDocument = userPomodoroCollection(userId: userId).document()
            return (pomodoroDocument, pomodoroDocument.documentID)
        case .none:
            let journalDocument =  userJournalCollection(userId: userId).document()
            return (journalDocument, journalDocument.documentID)
        }
    }
}

// MARK: CRUD For Firestore
extension UserManager: UserUseCase{
    
    // Create new user to firestroe
    func createNewUser(user: UserDB) async throws{
        try userDocument(userId: user.id).setData(from: user, merge: false)
    }
    
    // Get user from firestroe
    func getUserDB(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
    }
    
    // Update user profile template
    func updateUserProfile(userId: String /*Param: What value want to update*/) async throws -> UserDB {
        // Must be a dictionary
        let data: [String: Any] = [
            UserDB.CodingKeys.fullName.rawValue: "Ayung"
        ]
        try await userDocument(userId: userId).updateData(data)
        return try await getUserDB(userId: userId)
    }
}

// MARK: - For Journal Use Case
extension UserManager: JournalUseCase {
    func createJournal(userId: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: nil)
        let journal = Journal(id: id, date: Date(), dateCreated: Date())
        try document.setData(from: journal, merge: false)
    }
    
    // Use for calendar
    func getAllJournal(userId: String) async throws -> [Journal]? {
        try await userJournalCollection(userId: userId).getAllDocuments(as: Journal.self)
    }
    
    func getDetailJournal(userId: String, from date: Date) async throws -> Journal? {
        let snapshot = try await userJournalCollection(userId: userId).whereField(Journal.CodingKeys.date.rawValue, isDateInToday: date).getDocuments()
        if let document = snapshot.documents.first {
            let journal = try document.data(as: Journal.self)
            return journal
        } else {
            return nil
        }
    }
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    
    func createNewHabit(userId: String /*habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Date]?, reminderHabit: Date?, doneDate: [Date]? = nil, dateCreated: Date?*/) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .habit)
        let habit = Habit(id: id, habitName: "Lari siang", description: "Aku mau lari pagi sebanyak 6x", label: "Blue Label", frequency: 2, repeatHabit: [Date(), Date() - 1], reminderHabit: Date(), doneDate: [Date(), Date() - 1], dateCreated: Date())
        try document.setData(from: habit, merge: false)
    }
    
    func getAllHabitByDate(userId: String, date: Date) async throws -> [Habit]?{
        try await userHabitCollection(userId: userId)
            .whereField(Habit.CodingKeys.reminderHabit.rawValue, isDateInToday: Date())
            .getAllDocuments(as: Habit.self)
    }
    
    func getAllHabit(userId: String) async throws -> [Habit]?{
        try await userHabitCollection(userId: userId)
            .getAllDocuments(as: Habit.self)
    }
    
    func getHabitDetail(userId: String, habitId: String) async throws -> Habit? {
        return try await userHabitDocument(userId: userId, habitId: habitId).getDocument(as: Habit.self)
    }
    
    func editHabit(userId: String, habitId: String) async throws -> Habit?{
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
    
    func getAllPomodoro(userId: String, date: Date) async throws -> [Pomodoro]? {
        try await userPomodoroCollection(userId: userId)
            .whereField(Habit.CodingKeys.repeatHabit.rawValue, isEqualTo: date)
            .getAllDocuments(as: Pomodoro.self)
    }
    
    func createNewPomodoro(userId: String) async throws {
        let (document, id) = generateDocumentID(userId: userId, type: .pomodoro)
        let pomodoro = Pomodoro(id: id, pomodoroName: "Pomodoro 1", description: "Ini pomodoro pagi", label: "Red Label", session: 1, focusTime: 2, breakTime: 3, repeatPomodoro: [Date()], reminderPomodoro: Date(), doneDate: [Date()], dateCreated: Date())
        try document.setData(from: pomodoro, merge: false)
    }
    
    func getAllPomodoroByDate(userId: String, date: Date) async throws -> [Pomodoro]? {
        // Need change logic for integrate with apps
        return try await userPomodoroCollection(userId: userId)
            .whereField(Pomodoro.CodingKeys.reminderPomodoro.rawValue, isDateInToday: Date())
            .getAllDocuments(as: Pomodoro.self)
    }
    
    func getPomodoroDetail(userId: String, habitId: String) async throws -> Pomodoro? {
        return try await userPomodoroDocument(userId: userId, pomodoroId: habitId).getDocument(as: Pomodoro.self)
    }
    
    func editPomodoro(userId: String, pomodoroId: String) async throws -> Pomodoro? {
        let data: [String: Any] = [
            : // need more context about the flow
        ]
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).updateData(data)
        return try await getPomodoroDetail(userId: userId, habitId: pomodoroId)
    }
    
    func deletePomodoro(userId: String, pomodoroId: String) async throws {
        try await userPomodoroDocument(userId: userId, pomodoroId: pomodoroId).delete()
    }
}

extension UserManager: StreakUseCase{
    
    func createStreak(userId: String, description: String) async throws {
        let streak = Streak(streaksCount: 1, description: description, isStreak: true, dateCreated: Date())
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
