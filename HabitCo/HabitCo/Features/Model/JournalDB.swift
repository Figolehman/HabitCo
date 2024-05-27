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
    let date: Date?
    let dateName: String?
    let undoStreak: Bool?
    let todayStreak: Bool?
    let hasSubJournal: Bool?
    
    enum CodingKeys: String, CodingKey{
        case id, date
        case dateName = "date_name"
        case undoStreak = "undo_streak"
        case hasSubJournal = "has_sub_journal"
        case todayStreak = "today_streak"
    }
}

extension JournalDB {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.dateName = try container.decode(String.self, forKey: .dateName)
        self.undoStreak = try container.decode(Bool.self, forKey: .undoStreak)
        self.todayStreak = try container.decode(Bool.self, forKey: .todayStreak)
        self.hasSubJournal = try container.decode(Bool.self, forKey: .hasSubJournal)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.date, forKey: .date)
        try container.encodeIfPresent(self.dateName, forKey: .dateName)
        try container.encodeIfPresent(self.undoStreak, forKey: .undoStreak)
        try container.encodeIfPresent(self.todayStreak, forKey: .todayStreak)
        try container.encodeIfPresent(self.hasSubJournal, forKey: .hasSubJournal)
    }
}
