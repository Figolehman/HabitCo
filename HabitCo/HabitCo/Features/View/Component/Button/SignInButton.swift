//
//  SignInButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI
import AuthenticationServices

struct SignInButton: View {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            SignInWithAppleButtonViewRepresentable(type: type, style: style)
        }
        .frame(width: AppButtonSize.submit.width, height: AppButtonSize.submit.height)
        
    }
}

#Preview {
    SignInButton(type: .continue, style: .black, action: {})
}
