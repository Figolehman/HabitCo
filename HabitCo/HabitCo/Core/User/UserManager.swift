//
//  UserManager.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 15/03/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UserUseCase {
    func createNewUser(user: UserDB) async throws
    func getUserDB(userId: String) async throws -> UserDB
    func updateUserProfile(userId: String) async throws -> UserDB
}

@MainActor
final class UserManager {
    
    static let shared = UserManager()
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
}

// MARK: CRUD For Firestore
extension UserManager: UserUseCase{
    
    // Create new user to firestroe
    func createNewUser(user: UserDB) async throws{
        try userDocument(userId: user.id).setData(from: user, merge: false)
    }
    
    // Get user from firestroe
    func getUserDB(userId: String) async throws -> UserDB {
        try await userDocument(userId: userId).getDocument(as: UserDB.self)
    }
    
    // Update user profile template
    func updateUserProfile(userId: String /*Param: What value want to update*/) async throws -> UserDB {
        // Must be a dictionary
        let data: [String: Any] = [:
            //UserDB.CodingKeys.fullName.rawValue: "Ayung"
        ]
        try await userDocument(userId: userId).updateData(data)
        return try await getUserDB(userId: userId)
    }
    
}
