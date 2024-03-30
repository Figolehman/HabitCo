//
//  JournalDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

// MARK: - Journal DB Section
struct JournalDB: Codable{
    let id: String?
    let habitId: [String]
    let pomodoroId: String?
    let date: Date?
    let dateName: String?
    
    enum CodingKeys: String, CodingKey{
        case id, date
        case habitId = "habit_id"
        case pomodoroId = "pomodoro_id"
        case dateName = "date_name"
    }
}

extension JournalDB {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.habitId = try container.decode([String].self, forKey: .habitId)
        self.pomodoroId = try container.decode(String.self, forKey: .pomodoroId)
        self.dateName = try container.decode(String.self, forKey: .dateName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.date, forKey: .date)
        try container.encodeIfPresent(self.habitId, forKey: .habitId)
        try container.encodeIfPresent(self.pomodoroId, forKey: .pomodoroId)
        try container.encodeIfPresent(self.dateName, forKey: .dateName)
    }
}
