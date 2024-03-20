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
    let streak: Streak?
    
    enum CodingKeys: String, CodingKey{
        case id, email, streak
        case fullName = "full_name"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
    }
    
    init(
        id: String,
        fullName: String?,
        email: String?,
        photoUrl: String?,
        dateCreated: Date?,
        streak: Streak? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.streak = streak
    }
}

extension UserDB{
    init(user: UserAuthInfo){
        self.id = user.uid
        self.fullName = user.displayName
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.dateCreated = Date()
        self.streak = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.streak = try container.decodeIfPresent(Streak.self, forKey: .streak)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.streak, forKey: .streak)
        try container.encodeIfPresent(self.fullName, forKey: .fullName)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
