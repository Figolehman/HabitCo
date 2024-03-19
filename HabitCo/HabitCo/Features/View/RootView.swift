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
                            
                            if let journals = viewModel.journals {
                                Text(journals[0].id ?? "No id")
                            } else {
                                Text("sdfdsfsdfsdfsdfsdfsd")
                            }
                            
                            if let habit = viewModel.habit {
                                Text("Habit: \(habit.habitName ?? "")")
                            }
                            
                        }
                        
                        Button {
                            viewModel.deleteHabit()
                        } label: {
                            Text("Delete habit")
                        }
                        
                        Button {
                            viewModel.getHabitDetail()
                        } label: {
                            Text("Get Habit Detail")
                        }
                        
                        Button {
                            if viewModel.user?.streak == nil {
                                viewModel.createStreak()
                            }
                        } label: {
                            Text("Create streak")
                        }
                        
                        Button {
                            viewModel.createJournal()
                        } label: {
                            Text("Create journal")
                        }
                        
                        Button {
                            viewModel.createHabit()
                        } label: {
                            Text("Create Habit")
                        }
                        
                        Button {
                            viewModel.getAllJournal()
                        } label: {
                            Text("get journal")
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
