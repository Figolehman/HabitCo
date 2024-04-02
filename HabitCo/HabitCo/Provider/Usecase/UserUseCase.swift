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

protocol JournalUseCase{
    func generateJournal(userId: String, date: Date) async throws
    func getAllJournal(userId: String) async throws -> [JournalDB]?
    func getDetailJournal(userId: String, from date: Date) async throws -> JournalDB?
}

protocol StreakUseCase{
    func createStreak(userId: String, description: String) async throws
    func deleteStreak(userId: String) async throws
    func updateCountStreak(userId: String) async throws -> UserDB?
}
