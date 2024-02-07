//
//  ContentView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @StateObject var authVM = AuthenticationViewModel()
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
                        try await authVM.signInApple()
                    } catch {
                        print(error)
                    }
                }
                
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)
            .onChange(of: authVM.didSignIn, perform: { value in
                if value {
                    showSignInView = false
                }
            })
        }
        .padding()
    }
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
