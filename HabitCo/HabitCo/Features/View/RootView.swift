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
                                Text("Streak: \(user.streak?.id ?? "")")
                            }
                            
                            if let journals = viewModel.journals {
                                ForEach(journals, id: \.id) { journal in
                                    Text("Journal id: \(journal.id ?? "")")
                                }
                            }
                            
                            if let journal = viewModel.journal {
                                Text("Detail Journal: \(journal.id ?? "") \(journal.date ?? Date())")
                            }
                            
                            
                        }
                        
                        Button {
                            viewModel.createJournal()
                        } label: {
                            Text("Create journal")
                        }
                        
                        Button {
                            viewModel.getAllJournal()
                        } label: {
                            Text("Get journal")
                        }
                        
                        Button {
                            viewModel.getDetailJournal(from: Date())
                        } label: {
                            Text("Get Detail Journal By Date")
                        }
                        
//
//                        Button {
//                            viewModel.deleteHabit()
//                        } label: {
//                            Text("Delete habit")
//                        }
//                        
//                        Button {
//                            viewModel.getDetailJournal()
//                        } label: {
//                            Text("Get Detail Journal")
//                        }
                        
//                        Button {
//                            viewModel.getHabitDetail()
//                        } label: {
//                            Text("Get Habit Detail")
//                        }
                        
                        Button {
                            if viewModel.user?.streak == nil {
                                viewModel.createStreak()
                            }
                        } label: {
                            Text("Create streak")
                        }
//
//                        
//                        Button {
//                            viewModel.createHabit()
//                        } label: {
//                            Text("Create Habit")
//                        }
//
                        
                        
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
            viewModel.getCurrentUserData()
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
