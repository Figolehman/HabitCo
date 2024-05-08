//
//  Habit+PomodoroUseCase.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation

protocol HabitUseCase{
    func createNewHabit(userId: String, habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: String) async throws
    func getHabitDetail(userId: String, habitId: String) async throws -> HabitDB?
    func editHabit(userId: String, habitId: String, habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Int]?, reminderHabit: String?) async throws -> HabitDB?
    func deleteHabit(userId: String, habitId: String) async throws
}

protocol PomodoroUseCase{
    func createNewPomodoro(userId: String, pomodoroName: String, description: String, label: String, session: Int, focusTime: Int, breakTime: Int, longBreakTime: Int, repeatPomodoro: [Int], reminderPomodoro: String) async throws
    func getPomodoroDetail(userId: String, pomodoroId: String) async throws -> PomodoroDB?
    func editPomodoro(userId: String, pomodoroId: String, pomodoroName: String?, description: String?, label: String?, session: Int?, focusTime: Int?, breakTime: Int?, repeatPomodoro: [Int]?, longBreakTime: Int?, reminderPomodoro: String?) async throws -> PomodoroDB?
    func deletePomodoro(userId: String, pomodoroId: String) async throws
}
