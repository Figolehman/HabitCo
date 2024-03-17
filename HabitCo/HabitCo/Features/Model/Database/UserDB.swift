//
//  UserDB.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 15/03/24.
//

import Foundation

struct UserDB: Codable{
    let id: String
    let fullName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey{
        case id, email
        case fullName = "full_name"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.fullName, forKey: .fullName)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}

extension UserDB{
    
    init(user: UserAuthInfo){
        self.id = user.uid
        self.fullName = user.displayName
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.dateCreated = Date()
    }
    
}
