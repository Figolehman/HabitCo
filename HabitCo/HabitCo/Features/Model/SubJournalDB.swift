//
//  SubJournal.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 28/03/24.
//

import Foundation

struct SubJournalDB: Codable {
    let id: String?
    let habitPomodoroId: String?
    let frequencyCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case habitPomodoroId = "habit_pomodoro_id"
        case frequencyCount = "frequency_count"
    }
}

extension SubJournalDB {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.habitPomodoroId = try container.decodeIfPresent(String.self, forKey: .habitPomodoroId)
        self.frequencyCount = try container.decodeIfPresent(Int.self, forKey: .frequencyCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.habitPomodoroId, forKey: .habitPomodoroId)
        try container.encodeIfPresent(self.frequencyCount, forKey: .frequencyCount)
    }
}
   
