//
//  ContentView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @Environment(\.auth) var userAuth
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            Button(action: {
                Task{
                    do {
//                        try await authVM.signInApple()
                        let (userAuthInfo, _) = try await userAuth.signInApple()
                        if userAuthInfo != nil {
                            showSignInView = false
                        }
                    } catch {
                        print(error)
                    }
                }
                
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)

        }
        .padding()
    }
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
