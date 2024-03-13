//
//  RootView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView = false
    @Environment(\.auth) var authUser
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationView {
                    Button("Logout"){
                        do{
                            try authUser.signOut()
                            self.showSignInView = authUser.currentUser.profile == nil
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        .onAppear {
            self.showSignInView = authUser.currentUser.profile == nil
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationView {
                ContentView(showSignInView: $showSignInView)
            }
        })
    }
}

#Preview {
    RootView()
}
