//
//  JournalDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

// MARK: - Journal DB Section
struct Journal: Codable{
    let id: String?
    //let habitId: String?
    //let pomodoroId: String?
    let date: Date?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey{
        case id, date
        case dateCreated = "date_created"
        case habitId = "habit_id"
        case pomodoroId = "pomodoroId"
    }
}

extension Journal {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        //self.habitId = try container.decode(String.self, forKey: .habitId)
        //self.pomodoroId = try container.decode(String.self, forKey: .pomodoroId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.date, forKey: .date)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        //try container.encodeIfPresent(self.habitId, forKey: .habitId)
        //try container.encodeIfPresent(self.pomodoroId, forKey: .pomodoroId)
    }
}
