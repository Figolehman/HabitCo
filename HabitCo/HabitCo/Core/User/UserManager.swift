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
    
    private func userHabitCollection(userId: String, journalId: String) -> CollectionReference {
        userJournalDocument(userId: userId, journalId: journalId).collection("habits")
    }
    
    private func userHabitDocument(userId: String, journalId: String, habitId: String) -> DocumentReference {
         userHabitCollection(userId: userId, journalId: journalId).document(habitId)
    }
    
    private func userPomodoroCollection(userId: String, journalId: String) -> CollectionReference {
        userJournalDocument(userId: userId, journalId: journalId).collection("pomodoro")
    }
    
    private func userPomodoroDocument(userId: String, journalId: String, pomodoroId: String) -> DocumentReference {
         userPomodoroCollection(userId: userId, journalId: journalId).document(pomodoroId)
    }
    
    private func generateJournalID(userId: String) -> (DocumentReference, String) {
        let document =  userDocument(userId: userId).collection("journals").document()
        return (document, document.documentID)
    }
    
    private func generateHabitOrPomodoroID(userId: String, journalId: String, type: JournalType) -> (DocumentReference, String){
        let document = userJournalDocument(userId: userId, journalId: journalId)
        switch type {
        case .habit:
            let habitDocument = document.collection("habits").document()
            return (habitDocument, habitDocument.documentID)
        case .pomodoro:
            let pomodoroDocument = document.collection("pomodoros").document()
            return (pomodoroDocument, pomodoroDocument.documentID)
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
        let (document, id) = generateJournalID(userId: userId)
        let journal = Journal(id: id, date: Date(), dateCreated: Date())
        try document.setData(from: journal, merge: false)
    }
    
    func getAllJournal(userId: String) async throws -> [Journal]? {
        try await userJournalCollection(userId: userId).getAllDocuments(as: Journal.self)
    }
    
    func getDetailJournal(UserId: String, from date: Date) async throws -> Journal? {
        return nil // -> Need more flow
    }
}

// MARK: - For Habit Use Case
extension UserManager: HabitUseCase {
    func createNewHabit(userId: String, journalId: String /*habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Date]?, reminderHabit: Date?, doneDate: [Date]? = nil, dateCreated: Date?*/) async throws {
        let (document, id) = generateHabitOrPomodoroID(userId: userId, journalId: journalId, type: .habit)
        let habit = Habit(id: id, habitName: "Lari pagi", description: "Aku mau lari pagi sebanyak 6x", label: "Blue Label", frequency: 2, repeatHabit: [Date(), Date() - 1], reminderHabit: Date(), doneDate: [Date(), Date() - 1], dateCreated: Date())
        try document.setData(from: habit, merge: false)
    }
    
    func getHabitDetail(userId: String, date: Date) async throws -> Habit? {
        return try await userHabitCollection(userId: userId, journalId: "4VsrPbqTPAewSpHHvrjO").document("ccr6nHkisWJhlJo3YLTb").getDocument(as: Habit.self)
    }
    
    func editHabit(userId: String, habitId: String) async throws {
        //
    }
    
    func deleteHabit(userId: String, journalId: String, habitId: String) async throws {
        try await userHabitDocument(userId: userId, journalId: "4VsrPbqTPAewSpHHvrjO", habitId: "ccr6nHkisWJhlJo3YLTb").delete()
    }
}

extension UserManager: PomodoroUseCase {
    func createNewPomodoro(userId: String, journalId: String) async throws {
        let (document, id) = generateHabitOrPomodoroID(userId: userId, journalId: journalId, type: .pomodoro)
        let pomodoro = Pomodoro(id: id, pomodoroName: "Pomodoro 1", description: "Ini pomodoro pagi", label: "Red Label", session: 1, focusTime: 2, breakTime: 3, repeatPomodoro: [Date()], reminderPomodoro: Date(), doneDate: [Date()], dateCreated: Date())
        try document.setData(from: pomodoro, merge: false)
    }
    
    func getPonmodoroByDate(userId: String, date: Date) async throws -> Pomodoro? {
        // Need query this is for test
        return try await userHabitCollection(userId: userId, journalId: "4VsrPbqTPAewSpHHvrjO")
            .document("F6ZF58rFsHDo2RCgbo8B") /*Replace this value with pomodoroId*/
            .getDocument(as: Pomodoro.self)
    }
    
    func editPomodoro(userId: String, habitId: String) async throws {
        //
    }
    
    func deletePomodoro(userId: String, journalId: String, pomodoroId: String) async throws {
        try await userPomodoroDocument(userId: userId, journalId: journalId, pomodoroId: pomodoroId).delete()
    }
}

extension UserManager: StreakUseCase{
    
    func createStreak(userId: String) async throws {
        let streak = Streak(streaksCount: 1, description: "", isStreak: true, dateCreated: Date())
        guard let data = try? encoder.encode(streak) else { return }
        let dict: [String: Any] = [
            UserDB.CodingKeys.streak.rawValue: data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func getStreak(userId: String) async throws -> Streak? {
        return nil
    }
    
    func updateCountStreak(userId: String) async throws -> UserDB? {
        return nil
    }
    
    func deleteStreak(userId: String) async throws {
        ///  If isStreak == nil, execute the bottom of this code
        /*
        let streak = Streak(streaksCount: 1, description: "", isStreak: true, dateCreated: Date())
        let data: [String: Any?] = [
            UserDB.CodingKeys.streak.rawValue: nil
        ]
        try await userDocument(userId: userId).updateData(data)
         */
    }
}
