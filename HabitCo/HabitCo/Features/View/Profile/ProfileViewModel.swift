//
//  ProfileViewModel.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 17/03/24.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published private(set) var user: UserDB? = nil
    
    private let firebaseProvider: FirebaseAuthProvider
    private let userManager: UserManager
    
    init() {
        firebaseProvider = FirebaseAuthProvider()
        userManager = UserManager.shared
    }
    
}

extension ProfileViewModel{
    func getCurrentUserData() async throws {
        let userAuthInfo = firebaseProvider.getAuthenticatedUser()
        self.user = try await userManager.getUserDB(userId: userAuthInfo?.uid ?? "")
    }
    
    func updateName() async throws {
        guard let user = self.user else { return }
        self.user = try await userManager.updateUserProfile(userId: user.id)
    }
}
