//
//  JournalView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import SwiftUI

struct JournalView: View {
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var pomodoroViewModel = PomodoroViewModel()
    @State var selectedDate = Date()
    @State var showSheet = false
    @State var showCreateHabit = false
    @State private var isDataLoaded = false
    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 48) {
                
                ScrollableCalendarView(hasHabit: [], selectedDate: $selectedDate)
                    .padding(.top, .getResponsiveHeight(60))
                
                VStack (spacing: 24) {
                    HStack (spacing: 16) {
                        FilterButton(isDisabled: .constant(true)) {
                        }
                        
                        SortButton(label: "Progress", isDisabled: .constant(true), imageType: .unsort) {
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            //showCreateHabit = true
                            habitViewModel.createUserHabit(habitName: "", description: "", label: "", frequency: 1, repeatHabit: [], reminderHabit: Date())
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.getAppColor(.primary))
                        }
                    }
                    
                    //                    VStack (spacing: .getResponsiveHeight(16)) {
                    //                        Image(systemName: "leaf")
                    //                            .font(.largeTitle)
                    //                        Text("There’s no habit recorded yet.")
                    //                    }
                    //                    .foregroundColor(.getAppColor(.neutral))
                    //                    .frame(width: .getResponsiveWidth(365), height: .getResponsiveHeight(210))
                    
//                    Button {
//                        habitViewModel.editHabit(habitId: "")
//                    } label: {
//                        Text("Update Habit")
//                    }
                    
                     Button {
                         userViewModel.createStreak()
                    } label: {
                        Text("Create streak")
                    }
                    
                    
//                    Button {
//                        userViewModel.getDetailJournal(from: Date())
//                    } label: {
//                        Text("Get Detail Journal")
//                    }
//                    
                    Button {
                        pomodoroViewModel.createUserPomodoro(pomodoroName: "", description: "", label: "", session: 0, focusTime: 0, breakTime: 0, repeatPomodoro: [], reminderPomodoro: Date())
                    } label: {
                        Text("add pomodoro")
                    }
                    
                    ScrollView {
                        VStack (spacing: .getResponsiveHeight(24)) {
                            ForEach(userViewModel.subJournals ?? [], id: \.subJournal.id) { item in
                                if item.subJournal.subJournalType == .habit {
                                    Button {
                                        userViewModel.updateCountStreak()
                                    } label: {
                                        HabitItem(habitType: .type2, habitName: item.habit?.habitName ?? "NO NAME")
                                    }
                                } else {
                                    Button {
                                        userViewModel.updateFreqeunceSubJournal(subJournalId: item.subJournal.id ?? "", from: Date())
                                    } label: {
                                        HabitItem(habitType: .type1, habitName: item.pomodoro?.pomodoroName ?? "NO NAME")
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .toolbar {
                VStack {
                    HStack {
                        Text(userViewModel.getMonthAndYear(date: selectedDate))
                            .foregroundColor(.getAppColor(.neutral))
                            .font(.largeTitle.weight(.bold))
                        
                        Spacer()
                        
                        Button {
                            //showSheet = true
                            do {
                                try auth.signOut()
                                appRootManager.currentRoot = .onBoardingView
                            } catch {
                                print(error)
                            }
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.getAppColor(.primary))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(width: ScreenSize.width)
                    
                    HStack {
                        Image(systemName: "flame")
                            .font(.caption)
                        Text("1 Day Streak!")
                            .font(.caption)
                        
                        Spacer()
                    }
                }
                .padding(.top, 25)
            }
            .background(
                Image("blobsJournal")
                    .frame(width: .getResponsiveWidth(558.86658), height: .getResponsiveHeight(509.7464))
                    .offset(y: .getResponsiveHeight(-530))
            )
        }
        .alertOverlay($showCreateHabit, closeOnTap: true, content: {
            VStack (spacing: 24) {
                CreateButton(type: .habit) {
                    
                }
                CreateButton(type: .pomodoro) {
                    
                }
            }
        })
        .sheet(isPresented: $showSheet, content: {
            
        })
        .onAppear {
            let customNavigation = UINavigationBarAppearance()
            customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            
            userViewModel.generateJournalEntries()
            userViewModel.getDetailJournal(from: Date())
//            userViewModel.generateJournalEntries {
//                userViewModel.addListenerForSubJournals(from: Date())
//            }
//            userViewModel.addListenerForSubJournals(from: Date())

             UserDefaultManager.lastEntryDate = DateFormatUtil.shared.formattedDate(date: Date(), to: .fullMonthName)
            
            UINavigationBar.appearance().standardAppearance = customNavigation
            do {
                try userViewModel.getCurrentUserData { [self] in
                    do {
                        try userViewModel.getAllJournal()
                    } catch {
                        print("No Journal")
                    }
                }
            } catch {
                print("No Authenticated User")
            }
        }
    }
}

#Preview {
    JournalView()
}
