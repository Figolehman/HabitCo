//
//  RootView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView = false
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.auth) var authUser
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationView {
                    VStack{
                        List{
                            if let user = viewModel.user {
                                Text("UserId: \(user.id)")
                                Text("DisplayName: \(user.fullName ?? "")")
                            }
                        }
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
        }
        .task {
            do {
                try await viewModel.getCurrentUserData()
            } catch {
                print("NO DATA")
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
