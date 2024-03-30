//
//  SubJournal.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 28/03/24.
//

import Foundation

struct SubJournalDB: Codable {
    var id: String = UUID().uuidString
    let streaksCount: Int?
    let description: String?
    let isStreak: Bool?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case streaksCount = "streaks_count"
        case isStreak = "is_streak"
        case dateCreated = "date_created"
    }
}
