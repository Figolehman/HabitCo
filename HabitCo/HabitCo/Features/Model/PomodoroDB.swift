//
//  PomodoroDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 12/04/24.
//

import Foundation

struct PomodoroDB: Codable {
    var id: String = UUID().uuidString
    let pomodoroName: String?
    let description: String?
    let label: String?
    let session: Int?
    let focusTime: Int?
    let breakTime: Int?
    let longBreakTime: Int?
    let repeatPomodoro: [Int]?
    let reminderPomodoro: String?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, description, label, session
        case pomodoroName = "pomodoro_name"
        case focusTime = "focus_time"
        case breakTime = "break_time"
        case longBreakTime = "long_break_time"
        case repeatPomodoro = "repeat_pomodoro"
        case reminderPomodoro = "reminder_pomodoro"
        case dateCreated = "date_created"
    }
}

extension PomodoroDB {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.session = try container.decodeIfPresent(Int.self, forKey: .session)
        self.pomodoroName = try container.decodeIfPresent(String.self, forKey: .pomodoroName)
        self.focusTime = try container.decodeIfPresent(Int.self, forKey: .focusTime)
        self.breakTime = try container.decodeIfPresent(Int.self, forKey: .breakTime)
        self.longBreakTime = try container.decodeIfPresent(Int.self, forKey: .longBreakTime)
        self.repeatPomodoro = try container.decodeIfPresent([Int].self, forKey: .repeatPomodoro)
        self.reminderPomodoro = try container.decodeIfPresent(String.self, forKey: .reminderPomodoro)
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
        try container.encodeIfPresent(self.longBreakTime, forKey: .longBreakTime)
        try container.encodeIfPresent(self.repeatPomodoro, forKey: .repeatPomodoro)
        try container.encodeIfPresent(self.reminderPomodoro, forKey: .reminderPomodoro)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
