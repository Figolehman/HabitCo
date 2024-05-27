//
//  JournalView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import SwiftUI
import WidgetKit

private enum Navigator {
    case createHabit, createPomodoro, habitDetail, pomodoroDetail, focus
    case none
}

struct JournalView: View {

    @State private var navigateTo: Navigator? = Navigator.none

    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var pomodoroViewModel = PomodoroViewModel()
    
    @State var selectedDate = Date()
    @State var showSettings = false
    @State var showCreateHabit = false
    @State private var isDataLoaded = false
    @State var showStreak = false
    @State var showPrivacyPolicy = false
    @State var showTermsAndConditions = false
    @State var showFilter = false
    @State var showAlert = false
    
    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager

    var body: some View {
        NavigationView{

            VStack(spacing: 48) {

                HStack (spacing: 8) {
                    Image(systemName: "flame")
                        .font(.caption)
                    Text("\(userViewModel.streakCount) Day Streak!")
                        .font(.caption)

                    Spacer()
                    // MARK: - navigation links
                    NavigationLink(destination: CreateHabitView(habitVM: habitViewModel), tag: .createHabit, selection: $navigateTo) {
                        EmptyView()
                    }
                    NavigationLink(destination: CreatePomodoroView(pomodoroVM: pomodoroViewModel), tag: .createPomodoro, selection: $navigateTo) {
                        EmptyView()
                    }
                }
                .padding(.horizontal, 16)

                Group {
                    ScrollableCalendarView(hasHabit: [], selectedDate: $selectedDate)

                    VStack (spacing: 24) {
                        HStack (spacing: 16) {
                            FilterButton(isDisabled: .constant(false)) {
                                withAnimation {
                                    showFilter = true
                                }
                            }
                            
                            SortButton(label: "Progress", isDisabled: .constant(false), imageType: .unsort) {
                                //userViewModel.filterSubJournalsByProgress(from: selectedDate, isAscending: SortImage.)
                            }
                            
                            Spacer()
                            
                            Button {
                                showCreateHabit = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.getAppColor(.primary))
                            }
                        }

                        ScrollView {
                            if let _ = userViewModel.subJournals {
                                VStack (spacing: .getResponsiveHeight(24)) {
                                    ForEach(userViewModel.subJournals ?? [], id: \.subJournal.id) { item in
                                        ZStack {
                                            NavigationLink(destination: HabitDetailView(habit: item.habit), tag: .habitDetail, selection: $navigateTo) {
                                                EmptyView()
                                            }
                                            NavigationLink(destination: FocusView(), tag: .focus, selection: $navigateTo) {
                                                EmptyView()
                                            }
                                            if item.subJournal.subJournalType == .habit {
                                                HabitItem(habitType: .pomodoro, habitName: item.habit?.habitName ?? "NO NAME", label: item.habit?.label ?? "", fraction: item.subJournal.fraction ?? 0.0, progress: item.subJournal.startFrequency ?? 0) {
                                                    navigateTo = .habitDetail
                                                } action: {
                                                    userViewModel.updateCountSubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                                } undoAction: {
                                                    userViewModel.undoCountSubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                                }
                                            } else {
                                                HabitItem(habitType: .regular, habitName: item.pomodoro?.pomodoroName ?? "NO NAME", label: item.pomodoro?.label ?? "", progress: item.subJournal.startFrequency ?? 0) {
                                                    navigateTo = .focus
                                                } action: {
                                                    // action
                                                } undoAction: {
                                                    userViewModel.undoCountSubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
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
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 8)
            .background(
                Image("blobsJournal")
                    .frame(width: .getResponsiveWidth(558.86658), height: .getResponsiveHeight(509.7464))
                    .offset(y: .getResponsiveHeight(-530))
            )
            .onAppear {
                let customNavigation = UINavigationBarAppearance()
                customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
                customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]

                UINavigationBar.appearance().standardAppearance = customNavigation
                do {
                    try userViewModel.getCurrentUserData {
                        //UserDefaultManager.lastEntryDate = Date().formattedDate(to: .fullMonthName)
                    }
                } catch {
                    print("No Authenticated User")
                }
                do {
                    try userViewModel.getAllJournal()
                    userViewModel.generateJournalEntries()
                    userViewModel.checkIsStreak()
                    userViewModel.getSubJournals(from: selectedDate)
                    userViewModel.getStreak()
                } catch {
                    print("No Journal")
                }
            }
            .toolbar {

                HStack {
                    Text(selectedDate.getMonthAndYearString())
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
            }
        }
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
                Button {
                    navigateTo = .createHabit
                    showCreateHabit.toggle()
                } label: {
                    CreateLabel(type: .habit)
                }

                Button {
                    navigateTo = .createPomodoro
                    showCreateHabit.toggle()
                } label: {
                    CreateLabel(type: .pomodoro)
                }
            }
        })
         .onChange(of: selectedDate) { newValue in
             userViewModel.getSubJournals(from: newValue)
         }
    }
}
