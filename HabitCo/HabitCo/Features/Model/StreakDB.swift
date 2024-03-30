//
//  StreakDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

struct StreakDB: Codable {
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

extension StreakDB {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.streaksCount = try container.decodeIfPresent(Int.self, forKey: .streaksCount)
        self.isStreak = try container.decodeIfPresent(Bool.self, forKey: .isStreak)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.streaksCount, forKey: .streaksCount)
        try container.encodeIfPresent(self.isStreak, forKey: .isStreak)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
