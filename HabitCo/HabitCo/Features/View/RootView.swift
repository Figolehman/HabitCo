//
//  RootView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView = false
    @StateObject private var viewModel = UserViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
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
                            
                            
                            
                            if let habit = habitViewModel.habits {
                                ForEach(habit, id: \.id) { habit in
                                    Button {
                                        habitViewModel.getHabitDetail(habitId: habit.id ?? "No Value")
                                    } label: {
                                        Text("Habit name: \(habit.habitName ?? "")")
                                    }
                                }
                            }
                    
                            if let habit = habitViewModel.habit {
                                Text("Habit Id: \(habit.id ?? "")")
                                Text("Habit name: \(habit.habitName ?? "")")
                                Text("Habit Label: \(habit.label ?? "")")
                            }
                        }
                        
//                        Button {
//                            await viewModel.getAllJournal()
//                        } label: {
//                            Text("Get journal")
//                        }
                        
//                        Button {
//                            viewModel.getDetailJournal(from: Date())
//                        } label: {
//                            Text("Get Detail Journal By Date")
//                        }
//                        
                        Button {
                            habitViewModel.createUserHabit(habitName: "", description: "", label: "", frequency: 0, repeatHabit: [], reminderHabit: Date())
                        } label: {
                            Text("Create Habit")
                        }
                        
                        Button {
                            habitViewModel.deleteHabit(habitId: habitViewModel.habit?.id ?? "")
                        } label: {
                            Text("Delete Habit")
                        }
                        
                        Button {
                            if viewModel.user?.streak == nil {
                                viewModel.createStreak()
                            }
                        } label: {
                            Text("Create streak")
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
        .onAppear {
            //viewModel.getCurrentUserData()
            self.showSignInView = authUser.currentUser.profile == nil
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationView {
//                ContentView(showSignInView: $showSignInView)
            }
        })
    }
}

#Preview {
    RootView()
}
