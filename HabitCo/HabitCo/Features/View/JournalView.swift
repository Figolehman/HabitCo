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
    @State var showSheet = false
    @State var showCreateHabit = false
    @State private var isDataLoaded = false
    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 48) {
                
                ScrollableCalendarView(hasHabit: [])
                    .padding(.top, .getResponsiveHeight(60))
                
                VStack (spacing: 24) {
                    HStack (spacing: 16) {
                        FilterButton(isDisabled: .constant(true)) {
                            
                        }
                        
                        SortButton(label: "Progress", isDisabled: .constant(true), imageType: .unsort) {
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            showCreateHabit = true
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
                    
                    ScrollView {
                        VStack (spacing: .getResponsiveHeight(24)) {
                            HabitItem(habitType: .type1)
                            
                            HabitItem(habitType: .type2)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .toolbar {
                VStack {
                    HStack {
                        Text(userViewModel.getMonthAndYear(date: Date()))
                            .foregroundColor(.getAppColor(.neutral))
                            .font(.largeTitle.weight(.bold))
                        
                        Spacer()
                        
                        Button {
                            //showSheet = true
                            //userViewModel.getJournalByDate()
                            habitViewModel.createUserHabit(habitName: "", description: "", label: "", frequency: 1, repeatHabit: [], reminderHabit: Date())
//                                                        do {
//                                                            try auth.signOut()
//                                                            appRootManager.currentRoot = .onBoardingView
//                                                        } catch {
//                                                            print(error)
//                                                        }
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
