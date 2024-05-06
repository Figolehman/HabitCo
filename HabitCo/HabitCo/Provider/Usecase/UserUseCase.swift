//
//  UserUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol UserUseCase {
    func addUser(user: UserDB) async throws
    func getUserDB(userId: String) async throws -> UserDB
}

protocol JournalUseCase {
    func generateJournal(userId: String, date: Date) async throws
    func getAllJournal(userId: String) async throws -> [JournalDB]?
    func getJournal(userId: String, from date: Date) async throws -> JournalDB?
}

protocol SubJournalUseCase {
    func generateSubJournal(userId: String, journalId: String, type: SubJournalType, habitPomodoroId: String, label: String, frequencyCount: Int) async throws
}

protocol FutureJournalUseCase {
    func generateFutureJournal(userId: String, dateName: String) async throws
    func getFutureJournal(userId: String, from date: Date) async throws -> FutureJournalDB?
}

protocol SubFutureJournalUseCase {
    func generateSubFutureJournal(userId: String, futureJournalId: String, subJournalType: SubJournalType, habitPomodoroId: String) async throws
    func deleteSubFutureJournal(userId: String, futureJournalId: String, subFutureJournalId: String) async throws
}

protocol StreakUseCase {
    func createStreak(userId: String, description: String) async throws
    func deleteStreak(userId: String) async throws
    func updateCountStreak(userId: String, undo: Bool) async throws
}
