//
//  AuthenticationViewModel.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: NSObject, ObservableObject {
    
    @Published var didSignIn = false
    
    private var currentNonce: String?
    
    func signInApple() async throws {
        startSignInWithAppleFlow()
    }
    
    func startSignInWithAppleFlow() {
        guard let topVC = Utilities.shared.topViewController() else {
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

// MARK: - ASAuthroizationControllerDelegate
extension AuthenticationViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
//        guard
//            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
//            let nonce = currentNonce,
//            let appleIDToken = appleIDCredential.identityToken,
//            let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//            print("error")
//            return
//        }
//        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let tokens = AppleAuthModel(token: idTokenString, nonce: nonce)

            Task {
                do {
                    try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
                    didSignIn = true
                } catch {
                    
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
