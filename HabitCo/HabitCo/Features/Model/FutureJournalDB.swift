//
//  FutureJournalDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 09/04/24.
//

import Foundation

enum DateName: String, CaseIterable {
    case SUN
    case MON
    case TUE
    case WED
    case THU
    case FRI
    case SAT
}

struct FutureJournalDB: Codable {
    
    let id: String?
    let dateName: String?
    
    enum CodingKeys: String, CodingKey{
        case id
        case dateName = "date_name"
    }
}

extension FutureJournalDB {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.dateName = try container.decodeIfPresent(String.self, forKey: .dateName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.dateName, forKey: .dateName)
    }
}

