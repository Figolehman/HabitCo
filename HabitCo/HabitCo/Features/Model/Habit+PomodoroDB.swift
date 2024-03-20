//
//  Habit+PomodoroDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 21/03/24.
//

import Foundation

// MARK: Habit Database Section
struct Habit: Codable{
    var id: String?
    let habitName: String?
    let description: String?
    let label: String?
    let frequency: Int?
    let repeatHabit: [Date]?
    let reminderHabit: Date?
    let doneDate: [Date]?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, description, label, frequency
        case habitName = "habit_name"
        case repeatHabit = "repeat_habit"
        case reminderHabit = "reminder_habit"
        case doneDate = "done_date"
        case dateCreated = "date_created"
    }
}

extension Habit{
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.frequency = try container.decodeIfPresent(Int.self, forKey: .frequency)
        self.habitName = try container.decodeIfPresent(String.self, forKey: .habitName)
        self.repeatHabit = try container.decodeIfPresent([Date].self, forKey: .repeatHabit)
        self.reminderHabit = try container.decodeIfPresent(Date.self, forKey: .reminderHabit)
        self.doneDate = try container.decodeIfPresent([Date].self, forKey: .doneDate)
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
        try container.encodeIfPresent(self.doneDate, forKey: .doneDate)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}

// MARK: - Pomodoro DB Section
struct Pomodoro: Codable {
    var id: String = UUID().uuidString
    let pomodoroName: String?
    let description: String?
    let label: String?
    let session: Int?
    let focusTime: Int?
    let breakTime: Int?
    let repeatPomodoro: [Date]?
    let reminderPomodoro: Date?
    let doneDate: [Date]?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, description, label, session
        case pomodoroName = "pomodoro_name"
        case focusTime = "focus_time"
        case breakTime = "break_time"
        case repeatPomodoro = "repeat_pomodoro"
        case reminderPomodoro = "reminder_pomodoro"
        case doneDate = "done_date"
        case dateCreated = "date_created"
    }
}

extension Pomodoro {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.session = try container.decodeIfPresent(Int.self, forKey: .session)
        self.pomodoroName = try container.decodeIfPresent(String.self, forKey: .pomodoroName)
        self.focusTime = try container.decodeIfPresent(Int.self, forKey: .focusTime)
        self.breakTime = try container.decodeIfPresent(Int.self, forKey: .breakTime)
        self.repeatPomodoro = try container.decodeIfPresent([Date].self, forKey: .repeatPomodoro)
        self.reminderPomodoro = try container.decodeIfPresent(Date.self, forKey: .reminderPomodoro)
        self.doneDate = try container.decodeIfPresent([Date].self, forKey: .doneDate)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.label, forKey: .label)
        try container.encodeIfPresent(self.session, forKey: .session)
        try container.encodeIfPresent(self.pomodoroName, forKey: .pomodoroName)
        try container.encodeIfPresent(self.focusTime, forKey: .focusTime)
        try container.encodeIfPresent(self.breakTime, forKey: .breakTime)
        try container.encodeIfPresent(self.repeatPomodoro, forKey: .repeatPomodoro)
        try container.encodeIfPresent(self.reminderPomodoro, forKey: .reminderPomodoro)
        try container.encodeIfPresent(self.doneDate, forKey: .doneDate)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
