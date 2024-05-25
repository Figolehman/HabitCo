//
//  WidgetViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 09/05/24.
//

import Foundation

@MainActor
public final class WidgetViewModel: ObservableObject {
    
    @Published private(set) var subJournals: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)]? = nil

    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
}

public extension WidgetViewModel {
    func getSubJournalToday() {
        Task {
            guard let userId = UserDefaultManager.userID else { return }
            guard let subJournals = try await userManager.getSubJournals(userId: userId, from: Date().formattedDate(to: .fullMonthName), label: nil, isAscending: true),
                  !subJournals.isEmpty
            else {
                self.subJournals = nil
                return
            }
            self.subJournals = try await fetchSubJournal(userId: userId, subJournals: subJournals)
        }
    }
}

private extension WidgetViewModel {
    func fetchSubJournal(userId: String, subJournals: [SubJournalDB]) async throws -> [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] {
        var localArray: [(subJournal: SubJournalDB, habit: HabitDB?, pomodoro: PomodoroDB?)] = []
        let range = 0..<4
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
