//
//  WidgetViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 09/05/24.
//

import Foundation
import SwiftUI
import WidgetKit

public final class WidgetManager {

    let key = "WidgetData"

    var subJournals: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] = []
    var userDefault = UserDefaults(suiteName: "group.HabitCo")!
    var widgetSubJournals: [String] = []

    let firebaseProvider: FirebaseAuthProvider
    let userManager: UserManager
    
    public init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
}

public extension WidgetManager {
    func getSubJournalToday(completion: @escaping () -> Void) {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard let subJournals = try await userManager.getSubJournals(userId: userId, from: Date().formattedDate(to: .fullMonthName), label: nil, isAscending: false),
                  !subJournals.isEmpty
            else {
                self.userDefault.set([], forKey: key)
                return
            }
            self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
            self.widgetSubJournals = self.subJournals.compactMap {
                let object = TaskModel(taskTitle: (($0.pomodoro == nil) ? $0.habit?.habitName : $0.pomodoro?.pomodoroName) ?? "", filterColor: $0.subJournal.label ?? "", taskCount: $0.subJournal.startFrequency ?? 0, totalTask: $0.subJournal.frequencyCount ?? 1)
                if let data = try? JSONEncoder().encode(object) {
                    return String(data: data, encoding: .utf8) ?? nil
                } else {
                    return nil
                }
            }
            self.userDefault.set(self.widgetSubJournals, forKey: key)
            completion()
        }
    }
}

private extension WidgetManager {
    func fetchSubJournal(userId: String, subJournals: [SubJournalDB]) async throws -> [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] {
        var localArray: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] = []
        let range = 0..<(subJournals.count < 4 ? subJournals.count : 4)
        let limitSubJournals = Array(subJournals[range])
        for subJournal in limitSubJournals {
            if subJournal.subJournalType == .habit {
                if let habitPomodoroId = try await userManager.getHabitDetail(userId: userId, habitId: subJournal.habitPomodoroId ?? "") {
                    localArray.append((subJournal, habitPomodoroId, nil))
                }
            } else {
                let habitPomodoroId = try await userManager.getPomodoroDetail(userId: userId, pomodoroId: subJournal.habitPomodoroId ?? "")
                localArray.append((subJournal, nil, habitPomodoroId))
            }
        }
        return localArray
    }
}
