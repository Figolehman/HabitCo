//
//  Habit+PomodoroUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol HabitUseCase{
    func createNewHabit(userId: String, journalId: String /*,habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Date]?, reminderHabit: Date?, doneDate: [Date]?, dateCreated: Date? */)  async throws
    func getHabitDetail(userId: String, journalId: String, habitId: String) async throws -> Habit?
    func getAllHabitByDate(userId: String, journalId: String, date: Date) async throws -> [Habit]?
    func editHabit(userId: String, habitId: String) async throws
    func deleteHabit(userId: String,  journalId: String, habitId: String) async throws
}

protocol PomodoroUseCase{
    func createNewPomodoro(userId: String, journalId: String) async throws
    func getPomodoroByDate(userId: String, date: Date) async throws -> Pomodoro?
    func getAllPomodoroByDate(userId: String, journalId: String, date: Date) async throws -> [Pomodoro]?
    func editPomodoro(userId: String, habitId: String) async throws
    func deletePomodoro(userId: String, journalId: String, pomodoroId: String) async throws
}
