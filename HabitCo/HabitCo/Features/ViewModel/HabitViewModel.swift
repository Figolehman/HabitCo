//
//  HabitViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import Foundation

@MainActor
final class HabitViewModel: ObservableObject {
    
    @Published private(set) var habits: [HabitDB]? = []
    @Published private(set) var habit: HabitDB? = nil
    @Published private(set) var progress: [Date: CGFloat]? = nil
    @Published private(set) var errorMessage: String? = nil
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension HabitViewModel {
    
    // Create user habit
    public func createUserHabit(habitName: String, description: String, label: String, frequency: Int, repeatHabit: [Int], reminderHabit: Date?) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            let timeString = reminderHabit?.dateToString(to: .hourAndMinute) ?? ""
            try await userManager.createNewHabit(userId: userId, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: timeString)
        }
    }
    
    // Get Progress Habit
    func getProgressHabit(habitId: String, date: Date) {
        Task {
            print("Date: \(date)")
            guard let userId = UserDefaultManager.userID else { return }
            self.progress = try await userManager.getProgressHabit(userId: userId, habitId: habitId, month: date.formattedDate(to: .fullMonthName))
        }
    }
    
    // Get Habit Detail
    public func getHabitDetail(habitId: String){
        Task{
            guard let userId = UserDefaultManager.userID,
                  let habits = self.habits
            else { return }
            for habit in habits {
                if habit.id == habitId {
                    if let habit = try? await userManager.getHabitDetail(userId: userId, habitId: habit.id ?? "") {
                        self.habit = habit
                    }
                }
            }
        }
    }
    
    // Edit Habit
    public func editHabit(habitId: String, habitName: String?, description: String?, label: String?, frequency: Int?, repeatHabit: [Int]?, reminderHabit: Date?) {
        Task{
            guard let userId = UserDefaultManager.userID else { return }
            let currentDate = Date().formattedDate(to: .fullMonthName)
            let reminder = reminderHabit?.dateToString(to: .hourAndMinute)
            self.habit = try await userManager.editHabit(userId: userId, habitId: habitId, habitName: habitName, description: description, label: label, frequency: frequency, repeatHabit: repeatHabit, reminderHabit: reminder)
            let editUndo = try await userManager.editSubJournal(userId: userId, from: Date().formattedDate(to: .fullMonthName), habitId: habitId, pomodoroId: nil, frequency: frequency ?? 0)
            
            let journal = try await userManager.getJournal(userId: userId, from: currentDate)
            let subJournal = try await userManager.getSubJournalByDate(userId: userId, date: currentDate, habitId: habitId, pomodoroId: nil)
            if editUndo {
                let isFirstStreak = try await userManager.checkIsFirstStreak(userId: userId)
                let isStartFrequencyIsZero = try await userManager.checkStartFrequencyIsZero(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournal?.id ?? "")
                if try await !userManager.checkCompletedSubJournal(userId: userId, from: currentDate),
                   try await !userManager.checkHasUndoStreak(userId: userId, from: currentDate)
                {
                    if !isFirstStreak,
                       !isStartFrequencyIsZero
                    {
                        try await userManager.updateHasUndoStreak(userId: userId, from: currentDate, isUndo: true)
                    } else {
                        try await userManager.deleteStreak(userId: userId)
                    }
                    try await userManager.updateTodayStreak(userId: userId, from: currentDate, isTodayStreak: false)
                }
            } else {
                let complete = try await userManager.checkSubJournalIsCompleted(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournal?.id ?? "")
                if complete,
                   currentDate.isSameDay(UserDefaultManager.lastEntryDate.formattedDate(to: .fullMonthName))
                {
                    if (try await userManager.getStreak(userId: userId) != nil) {
                        updateCountStreak(date: currentDate)
                        try await userManager.updateHasUndoStreak(userId: userId, from: currentDate)
                    } else {
                        try await userManager.createStreak(userId: userId)
                        try await userManager.updateTodayStreak(userId: userId, from: currentDate, isTodayStreak: true)
                        try await userManager.updateHasUndoStreak(userId: userId, from: currentDate)
                    }
                    try await userManager.updateSubJournalCompleted(userId: userId, journalId: journal?.id ?? "", subJournalId: subJournal?.id ?? "")
                }
            }
        }
    }
    
    // Delete Habit
    public func deleteHabit(habitId: String) {
        Task{
            guard let userId = UserDefaultManager.userID else { return }
            try await userManager.deleteHabit(userId: userId, habitId: habitId)
            let currentDate = Date().formattedDate(to: .fullMonthName)
            let hasSubJournalCompleteToday = try await userManager.checkHabitSubJournalIsCompleteByDate(userId: userId, habitId: habitId, date: currentDate)
            let isFirstStreak = try await userManager.checkIsFirstStreak(userId: userId)
            if try await !userManager.checkCompletedSubJournal(userId: userId, from: currentDate),
               try await !userManager.checkHasUndoStreak(userId: userId, from: currentDate) {
                if hasSubJournalCompleteToday,
                   isFirstStreak {
                    try await userManager.deleteStreak(userId: userId)
                } else {
                    try await userManager.updateCountStreak(userId: userId, undo: true)
                }
                try await userManager.updateTodayStreak(userId: userId, from: currentDate, isTodayStreak: false)
                if try await !userManager.checkHasSubJournalToday(userId: userId) {
                    try await userManager.updateHasSubJournal(userId: userId, from: currentDate, hasSubJournal: false)
                }
            }
        }
    }
}

private extension HabitViewModel {
    func updateCountStreak(date: Date) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            if try await !userManager.checkTodayStreak(userId: userId, from: date)
            {
                try await userManager.updateCountStreak(userId: userId)
                try await userManager.updateTodayStreak(userId: userId, from: date, isTodayStreak: true)
            }
        }
    }
}

