//
//  Query+extension.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 19/03/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func getAllDocuments<T: Decodable>(as type: T.Type) async throws -> [T]{
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map{
            try $0.data(as: T.self)
        }
    }
}
