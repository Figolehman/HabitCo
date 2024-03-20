//
//  Habit+PomodoroUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol HabitUseCase{
    func createNewHabit(userId: String /*,habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Date]?, reminderHabit: Date?, doneDate: [Date]?, dateCreated: Date? */)  async throws
    func getHabitDetail(userId: String, habitId: String) async throws -> Habit?
    func getAllHabitByDate(userId: String, date: Date) async throws -> [Habit]?
    func editHabit(userId: String, habitId: String) async throws -> Habit?
    func deleteHabit(userId: String, habitId: String) async throws
}

protocol PomodoroUseCase{
    func createNewPomodoro(userId: String) async throws
    func getAllPomodoroByDate(userId: String, date: Date) async throws -> [Pomodoro]?
    func getAllPomodoro(userId: String, date: Date) async throws -> [Pomodoro]?
    func getPomodoroDetail(userId: String, habitId: String) async throws -> Pomodoro?
    func editPomodoro(userId: String, pomodoroId: String) async throws -> Pomodoro?
    func deletePomodoro(userId: String, pomodoroId: String) async throws
}
