//
//  FirebaseAuthProvider.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthProvider: AuthProvider {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let currentUser = Auth.auth().currentUser {
            return UserAuthInfo(user: currentUser)
        } else {
            return nil
        }
    }
    
    // Will be used to listen to any authStateChanges as long as the app runs
    @MainActor
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            Auth.auth().addStateDidChangeListener { auth, currentUser in
                
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    //print(user)
                    continuation.yield(user)
                } else {
                    print("User Logged Out")
                    continuation.yield(nil)
                }
            }
        }
    }
    
    @MainActor
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        
        // Sign in to Apple account
        for try await appleResponse in helper.startSignInWithAppleFlow() {
            
            // Convert Apple Auth to Firebase credential
            let credential = OAuthProvider.credential(
                withProviderID: AuthProviderOption.apple.rawValue,
                idToken: appleResponse.token,
                rawNonce: appleResponse.nonce
            )
            
            // Sign in to Firebase
            let authDataResult = try await signIn(credential: credential)

            var firebaseUser = authDataResult.user
            
            // Determines if this is the first time this user is being authenticated
            let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
            
            if isNewUser {
                // Update Firebase user profile with info from Apple account
                if let updatedUser = try await updateUserProfile(
                    displayName: appleResponse.displayName,
                    firstName: appleResponse.firstName,
                    lastName: appleResponse.lastName,
                    photoUrl: nil
                ) {
                    firebaseUser = updatedUser
                }
            }
            
            // Convert to generic type
            let user = UserAuthInfo(user: firebaseUser)
            return (user, isNewUser)
        }
        
        // Should never occur - only would occur if startSignInWithAppleFlow() completed without yielding a result (success or error)
        throw AuthError.noResponse
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.delete()
    }
    
    // MARK: PRIVATE
    
    
    private func signIn(credential: AuthCredential) async throws -> AuthDataResult {
        try await Auth.auth().signIn(with: credential)
    }
    
    private func updateUserProfile(displayName: String?, firstName: String?, lastName: String?, photoUrl: URL?) async throws -> User? {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        
        var didMakeChanges: Bool = false
        if let displayName {
            request?.displayName = displayName
            didMakeChanges = true
        }
        
        if let firstName {
            UserDefaults.auth.firstName = firstName
        }
        
        if let lastName {
            UserDefaults.auth.lastName = lastName
        }
        
        if let photoUrl {
            request?.photoURL = photoUrl
            didMakeChanges = true
        }
        
        if didMakeChanges {
            try await request?.commitChanges()
        }
        
        return Auth.auth().currentUser
    }
    
    
    private enum AuthError: LocalizedError {
        case noResponse
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .noResponse:
                return "Bad response."
            case .userNotFound:
                return "Current user not found."
            }
        }
    }

}

extension UserDefaults {
    
    static let auth = UserDefaults(suiteName: "auth_defaults")!
    
    func reset() {
        firstName = nil
        lastName = nil
    }
    
    var firstName: String? {
        get {
            self.value(forKey: "first_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "first_name")
        }
    }
    
    var lastName: String? {
        get {
            self.value(forKey: "last_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "last_name")
        }
    }
}

