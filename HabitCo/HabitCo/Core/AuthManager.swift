//
//  AuthenticationManager.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import Foundation

public struct AuthInfo {
    public let profile: UserAuthInfo?
    
    public var userId: String? {
        profile?.uid
    }
    
    public var isSignedIn: Bool {
        profile != nil
    }
}

public enum Configuration {
    case mock, firebase
    
    var provider: AuthProvider {
        switch self {
        case .firebase:
            return FirebaseAuthProvider()
        case .mock:
            return MockAuthProvider()
        }
    }
}

@MainActor
public final class AuthManager {
    
    private let provider: AuthProvider
    
    @Published public private(set) var currentUser: AuthInfo
    private var task: Task<Void, Never>? = nil
    
    public init(configuration: Configuration) {
        self.provider = configuration.provider
        self.currentUser = AuthInfo(profile: provider.getAuthenticatedUser())
        self.streamSignInChangesIfNeeded()
    }
    
    public func getUserId() throws -> String {
        guard let id = currentUser.userId else {
            // If there is no userId, user should not be signed in.
            // Sign out anyway, in case there's an edge case?
            defer {
                try? signOut()
            }
            
            throw AuthManagerError.noUserId
        }
        
        return id
    }
    
    enum AuthManagerError: Error {
        case noUserId
    }
    
    private func streamSignInChangesIfNeeded() {
        // Only stream changes if a user is signed in
        // To listen to the changes of auth state (logged in, logged out)
        guard currentUser.isSignedIn else { return }
        
        self.task = Task {
            for await user in provider.authenticationDidChangeStream() {
                currentUser = AuthInfo(profile: user)
            }
        }
    }
    
    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try await provider.authenticateUser_Apple()
        currentUser = AuthInfo(profile: value.user)
        
        // Save user to firestore
        let user = UserDB(user: currentUser.profile ?? UserAuthInfo(uid: currentUser.userId ?? "NO ID"))
        try await UserManager.shared.createNewUser(user: user)

        defer {
            streamSignInChangesIfNeeded()
        }
        
        return value
    }
    
    public func signOut() throws {
        try provider.signOut()
        clearLocalData()
    }
    
    public func deleteAuthentication() async throws {
        try await provider.deleteAccount()
        clearLocalData()
    }
    
    private func clearLocalData() {
        task?.cancel()
        task = nil
        UserDefaults.auth.reset()
        currentUser = AuthInfo(profile: nil)
    }
}
