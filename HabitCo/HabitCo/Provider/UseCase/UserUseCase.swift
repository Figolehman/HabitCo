//
//  UserUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol UserUseCase {
    func createNewUser(user: UserDB) async throws
    func getUserDB(userId: String) async throws -> UserDB
    func updateUserProfile(userId: String) async throws -> UserDB
}

protocol JournalUseCase{
    func createJournal(userId: String) async throws
    func getAllJournal(userId: String) async throws -> [Journal]?
    func getDetailJournal(UserId: String, from date: Date) async throws -> Journal?
}

protocol StreakUseCase{
    func createStreak(userId: String) async throws
    func getStreak(userId: String) async throws -> Streak?
    func deleteStreak(userId: String) async throws
    func updateCountStreak(userId: String) async throws -> UserDB?
}
