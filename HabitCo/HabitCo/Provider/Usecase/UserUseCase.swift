//
//  UserUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol UserUseCase {
    func createUser(user: UserDB) async throws
    func getUserData(userId: String) async throws -> UserDB
}

protocol JournalUseCase {
    func createJournal(userId: String, date: Date) async throws
    func getAllJournal(userId: String) async throws -> [JournalDB]?
    func getJournal(userId: String, from date: Date) async throws -> JournalDB?
}

protocol SubJournalUseCase {
    func createSubJournal(userId: String, journalId: String, type: SubJournalType, habitPomodoroId: String, label: String, frequencyCount: Int) async throws
}

protocol FutureJournalUseCase {
    func createFutureJournal(userId: String, dateName: String) async throws
    func getFutureJournalByDate(userId: String, _ date: Date) async throws -> FutureJournalDB?
}

protocol SubFutureJournalUseCase {
    func createSubFutureJournal(userId: String, futureJournalId: String, subJournalType: SubJournalType, habitPomodoroId: String) async throws
    func deleteSubFutureJournal(userId: String, futureJournalId: String, subFutureJournalId: String) async throws
}

protocol StreakUseCase {
    func createStreak(userId: String) async throws
    func deleteStreak(userId: String) async throws
    func updateCountStreak(userId: String, undo: Bool) async throws
}
