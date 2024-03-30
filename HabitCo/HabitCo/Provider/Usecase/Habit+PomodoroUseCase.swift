//
//  Habit+PomodoroUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol HabitUseCase{
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String, dateCreated: Date) async throws
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB?
    func getAllHabitByDate(userId: String, date: Date) async throws -> [HabitDB]?
    func editHabit(userId: String, habitId: String) async throws -> HabitDB?
    func deleteHabit(userId: String, habitId: String) async throws
}

protocol PomodoroUseCase{
    func createNewPomodoro(userId: String) async throws
    func getAllPomodoroByDate(userId: String, date: Date) async throws -> [PomodoroDB]?
    func getPomodoroDetail(userId: String, pomodoroId: String) async throws -> PomodoroDB?
    func editPomodoro(userId: String, pomodoroId: String) async throws -> PomodoroDB?
    func deletePomodoro(userId: String, pomodoroId: String) async throws
}
