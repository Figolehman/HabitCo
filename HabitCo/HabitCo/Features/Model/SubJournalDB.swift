//
//  SubJournal.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 28/03/24.
//

import Foundation

enum SubJournalType: String, Codable {
    case habit
    case pomodoro
}

struct SubJournalDB: Codable {
    let id: String?
    let habitPomodoroId: String?
    let subJournalType: SubJournalType?
    let label: String?
    let frequencyCount: Int?
    let startFrequency: Int?
    let fraction: Double?
    let isCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, label, fraction
        case habitPomodoroId = "habit_pomodoro_id"
        case subJournalType = "sub_journal_type"
        case frequencyCount = "frequency_count"
        case startFrequency = "start_frequency"
        case isCompleted = "is_completed"
    }
}

extension SubJournalDB {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.habitPomodoroId = try container.decodeIfPresent(String.self, forKey: .habitPomodoroId)
        self.subJournalType = try container.decodeIfPresent(SubJournalType.self, forKey: .subJournalType)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.frequencyCount = try container.decodeIfPresent(Int.self, forKey: .frequencyCount)
        self.startFrequency = try container.decodeIfPresent(Int.self, forKey: .startFrequency)
        self.fraction = try container.decodeIfPresent(Double.self, forKey: .fraction)
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.habitPomodoroId, forKey: .habitPomodoroId)
        try container.encodeIfPresent(self.subJournalType, forKey: .subJournalType)
        try container.encodeIfPresent(self.label, forKey: .label)
        try container.encodeIfPresent(self.frequencyCount, forKey: .frequencyCount)
        try container.encodeIfPresent(self.startFrequency, forKey: .startFrequency)
        try container.encodeIfPresent(self.fraction, forKey: .fraction)
        try container.encodeIfPresent(self.isCompleted, forKey: .isCompleted)
    }
}
   
