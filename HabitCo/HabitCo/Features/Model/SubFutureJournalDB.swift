//
//  SubFutureJournal.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 12/04/24.
//

import Foundation

struct SubFutureJournalDB: Codable {
    let id: String?
    let habitPomodoroId: String?
    let subJournalType: SubJournalType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case habitPomodoroId = "habit_pomodoro_id"
        case subJournalType = "sub_journal_type"
    }
}

extension SubFutureJournalDB {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.habitPomodoroId = try container.decodeIfPresent(String.self, forKey: .habitPomodoroId)
        self.subJournalType = try container.decodeIfPresent(SubJournalType.self, forKey: .subJournalType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.habitPomodoroId, forKey: .habitPomodoroId)
        try container.encodeIfPresent(self.subJournalType, forKey: .subJournalType)
    }
}
