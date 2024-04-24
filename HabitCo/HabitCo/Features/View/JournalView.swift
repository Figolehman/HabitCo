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
    @State var showSettings = false
    @State var showCreateHabit = false
    @State private var isDataLoaded = false
    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager
    @State var showStreak = false
    @State var showPrivacyPolicy = false
    @State var showTermsAndConditions = false
    @State var showFilter = false
    @State var showAlert = false
    
    var body: some View {
        VStack(spacing: 48) {
            
            ScrollableCalendarView(hasHabit: [], selectedDate: $selectedDate)
                .padding(.top, .getResponsiveHeight(60))
            
            VStack (spacing: 24) {
                HStack (spacing: 16) {
                    FilterButton(isDisabled: .constant(false)) {
                        withAnimation {
                            showFilter = true
                        }
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
                
                Button {
                    pomodoroViewModel.createUserPomodoro(pomodoroName: "", description: "", label: "", session: 0, focusTime: 0, breakTime: 0, repeatPomodoro: [], reminderPomodoro: Date())
                } label: {
                    Text("add pomodoro")
                }
                
                ScrollView {
                    if let _ = userViewModel.subJournals
                    {
                        VStack (spacing: .getResponsiveHeight(24)) {
                            ForEach(userViewModel.subJournals ?? [], id: \.subJournal.id) { item in
                                if item.subJournal.subJournalType == .habit {
                                    NavigationLink {
                                        HabitDetailView(habit: item.habit)
                                    } label: {
                                        HabitItem(habitType: .type2, habitName: item.habit?.habitName ?? "NO NAME", fraction: userViewModel.fraction, progress: item.subJournal.startFrequency ?? 0)
                                    }
                                } else {
                                    Button {
                                        userViewModel.updateFreqeuncySubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                    } label: {
                                        HabitItem(habitType: .type1, habitName: item.pomodoro?.pomodoroName ?? "NO NAME", fraction: userViewModel.fraction, progress: item.subJournal.startFrequency ?? 0)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        VStack (spacing: .getResponsiveHeight(16)) {
                            Image(systemName: "leaf")
                                .font(.largeTitle)
                            Text("There’s no habit recorded yet.")
                        }
                        .foregroundColor(.getAppColor(.neutral))
                        .frame(width: .getResponsiveWidth(365), height: .getResponsiveHeight(210))
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
                        withAnimation {
                            showSettings = true
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
        .customSheet($showSettings, sheetType: .settings, content: {
            SettingsView(username: userViewModel.user?.fullName ?? "Full Name", userEmail: "Apple ID", initial: userViewModel.generateInitial(), showAlert: $showAlert, showPrivacyPolicy: $showPrivacyPolicy, showTermsAndConditions: $showTermsAndConditions)
        })
        .customSheet($showPrivacyPolicy, sheetType: .rules, content: {
            PrivacyPolicyView()
        })
        .customSheet($showTermsAndConditions, sheetType: .rules, content: {
            TermsAndConditionsView()
        })
        .alertOverlay($showAlert, content: {
            CustomAlertView(title: "Are you sure you want to Sign Out?", message: "Signing out means that you will need to sign in again when you open the apps.", dismiss: "Cancel", destruct: "Sign Out", dismissAction: {
                showAlert = false
            }, destructAction: {
                do {
                    try auth.signOut()
                    appRootManager.currentRoot = .onBoardingView
                } catch {
                    print(error)
                }
            })
        })
        .customSheet($showFilter, sheetType: .filters, content: {
            FilterView(date: $selectedDate, userVM: userViewModel)
        })
        .alertOverlay($showStreak, content: {
            StreakGainView(isShown: $showStreak)
        })
        .alertOverlay($showCreateHabit, closeOnTap: true, content: {
            VStack (spacing: 24) {
                NavigationLink {
                    CreateHabitView(habitVM: habitViewModel)
                } label: {
                    CreateLabel(type: .habit)
                }
                
                NavigationLink {
                    CreatePomodoroView(pomodoroVM: pomodoroViewModel)
                } label: {
                    CreateLabel(type: .pomodoro)
                }
            }
        })
        .onAppear {
            let customNavigation = UINavigationBarAppearance()
            customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            UINavigationBar.appearance().standardAppearance = customNavigation
            UserDefaultManager.lastEntryDate = DateFormatUtil.shared.formattedDate(date: Date(), to: .fullMonthName)
            userViewModel.generateJournalEntries()
            userViewModel.getSubJournals(from: selectedDate)
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
        .onChange(of: selectedDate) { newValue in
            userViewModel.getSubJournals(from: newValue)
        }
    }
}
