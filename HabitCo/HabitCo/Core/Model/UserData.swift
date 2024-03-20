//
//  UserData.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 13/03/24.
//

import Foundation

struct UserData: Codable{
    let id: String?
    let email: String?
    let photoURL: String?
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey{
        case id, email
        case photoURL = "photo_url"
        case dateCreated = "date_created"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoURL, forKey: .photoURL)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
}

extension UserData{
//    init(auth: AuthDataResultModel){
//        self.id = auth.uid
//        self.email = auth.email
//        self.photoUrl = auth.photoURL
//        self.dateCreated = Date()
//    }
}
