//
//  Habit+PomodoroDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 21/03/24.
//

import Foundation

struct HabitDB: Codable{
    var id: String?
    var habitName: String?
    var description: String?
    var label: String?
    var frequency: Int?
    var repeatHabit: [Int]?
    var reminderHabit: String?
    var dateCreated: Date?

    enum CodingKeys: String, CodingKey {
        case id, description, label, frequency
        case habitName = "habit_name"
        case repeatHabit = "repeat_habit"
        case reminderHabit = "reminder_habit"
        case dateCreated = "date_created"
    }
}

extension HabitDB{
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.frequency = try container.decodeIfPresent(Int.self, forKey: .frequency)
        self.habitName = try container.decodeIfPresent(String.self, forKey: .habitName)
        self.repeatHabit = try container.decodeIfPresent([Int].self, forKey: .repeatHabit)
        self.reminderHabit = try container.decodeIfPresent(String.self, forKey: .reminderHabit)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.label, forKey: .label)
        try container.encodeIfPresent(self.frequency, forKey: .frequency)
        try container.encodeIfPresent(self.habitName, forKey: .habitName)
        try container.encodeIfPresent(self.repeatHabit, forKey: .repeatHabit)
        try container.encodeIfPresent(self.reminderHabit, forKey: .reminderHabit)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
