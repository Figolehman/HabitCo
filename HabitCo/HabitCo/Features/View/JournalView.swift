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

    @State private var undoArg: (String, Date)?

    @State private var isLoading = false
    @State private var loadingStatus = LoadingType.loading
    @State private var loadingMessage = "Signing Out..."

    @State private var navigateTo: Navigator? = Navigator.none
//    @State private var habitNavigationArg: HabitDB?
//    @State private var pomodoroNavigationArg: PomodoroDB?
    @State private var focusNavigationArg: (PomodoroDB?, SubJournalDB?, Date)?

    @State private var sortType = SortImage.unsort
    @State private var isEmpty = true

    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var pomodoroViewModel = PomodoroViewModel()

    @State private var appliedFilter = [Color.FilterColors]()
    @State private var selectedFilter = [Color.FilterColors]()

    @State private var selectedDate = Date()
    @State private var showSettings = false
    @State private var showCreateHabit = false
    @State private var isDataLoaded = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false
    @State private var showFilter = false
    @State private var showSignOutAlert = false
    @State private var showUndoAlert = false

    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager

    var body: some View {
        NavigationView {

            VStack(spacing: 48) {

                HStack (spacing: 8) {
                    Image(systemName: "flame")
                        .font(.caption)
                    Text("\(userViewModel.streakCount) Day Streak!")
                        .font(.caption)

                    Spacer()
                    // MARK: - navigation links
                    NavigationLink(destination: CreateHabitView(habitNotificationId: userViewModel.habitNotificationId ?? "", habitVM: habitViewModel), tag: .createHabit, selection: $navigateTo) {
                        EmptyView()
                    }
                    NavigationLink(destination: CreatePomodoroView(habitNotificationId: userViewModel.habitNotificationId ?? "", pomodoroVM: pomodoroViewModel), tag: .createPomodoro, selection: $navigateTo) {
                        EmptyView()
                    }
                    NavigationLink(destination: HabitDetailView(habitVM: habitViewModel), tag: .habitDetail, selection: $navigateTo) {
                        EmptyView()
                    }
                  NavigationLink(destination: PomodoroDetailView(pomodoroVM: pomodoroViewModel), tag: .pomodoroDetail, selection: $navigateTo) {
                        EmptyView()
                    }
                    if focusNavigationArg != nil {
                        NavigationLink(destination: FocusView(pomodoro: focusNavigationArg!.0, subJournal: focusNavigationArg!.1, date: focusNavigationArg!.2), tag: .focus, selection: $navigateTo) {
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Group {
                    ScrollableCalendarView(hasHabit: userViewModel.hasHabit ?? [], selectedDate: $selectedDate)

                    VStack (spacing: 24) {
                        HStack (spacing: 16) {
                            FilterButton(isDisabled: $isEmpty) {
                                withAnimation {
                                    showFilter = true
                                }
                            }

                            SortButton(label: "Progress", isDisabled: $isEmpty, imageType: $sortType) {
                                sortJournal()
                            }

                            Spacer()

                            Button {
                                showCreateHabit = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.getAppColor(.primary))
                            }
                        }
//
                        if !appliedFilter.isEmpty {
                            ScrollView(.horizontal) {
                                HStack(spacing: .getResponsiveWidth(8)) {
                                    ForEach(appliedFilter, id: \.self) { filter in
                                        FilterLabelView(filter: filter)
                                    }
                                }
                            }
                            .frame(height: .getResponsiveHeight(38))
                        }

                        ScrollView {
                            if let _ = userViewModel.subJournals {
                                VStack (spacing: .getResponsiveHeight(24)) {
                                    ForEach(userViewModel.subJournals ?? [], id: \.subJournal.id) { item in
                                        if item.subJournal.subJournalType == .habit {
                                            HabitItem(habitType: .pomodoro, habitName: item.habit?.habitName ?? "NO NAME", label: item.habit?.label ?? "", fraction: item.subJournal.fraction ?? 0.0, progress: item.subJournal.startFrequency ?? 0) {
                                                habitViewModel.setHabit(habit: item.habit!)
                                                navigateTo = .habitDetail
                                            } action: {
                                                userViewModel.updateCountSubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                            } undoAction: {
                                                showUndoAlert = true
                                                undoArg = (item.subJournal.id ?? "", selectedDate)
                                            }
                                        } else {
                                            HabitItem(habitType: .regular, habitName: item.pomodoro?.pomodoroName ?? "NO NAME", label: item.pomodoro?.label ?? "", progress: item.subJournal.startFrequency ?? 0) {
                                                pomodoroViewModel.setPomodoro(pomodoro: item.pomodoro!)
                                                navigateTo = .pomodoroDetail
                                            } action: {
                                                focusNavigationArg = (item.pomodoro, item.subJournal, selectedDate)
                                                navigateTo = .focus
                                            } undoAction: {
                                                showUndoAlert = true
                                                undoArg = (item.subJournal.id ?? "", selectedDate)
                                            }
                                        }
                                    }
                                }
                                .onAppear {
                                    isEmpty = false
                                }
                            } else {
                                VStack (spacing: .getResponsiveHeight(16)) {
                                    Image(systemName: "leaf")
                                        .font(.largeTitle)
                                    Text("There’s no habit recorded yet.")
                                }
                                .foregroundColor(.getAppColor(.neutral))
                                .frame(width: .getResponsiveWidth(365), height: .getResponsiveHeight(210))
                                .onAppear {
                                    isEmpty = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 8)
            .background(
                ZStack {
                    Color.getAppColor(.neutral3)
                        .ignoresSafeArea()

                    Image("blobsJournal")
                        .frame(width: .getResponsiveWidth(558.86658), height: .getResponsiveHeight(509.7464))
                        .offset(y: .getResponsiveHeight(-530))
                }
            )
            .onAppear {
                let customNavigation = UINavigationBarAppearance()
                customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
                customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]

                UINavigationBar.appearance().standardAppearance = customNavigation
                do {
                    try userViewModel.getCurrentUserData { }
                } catch {
                    print("No Authenticated User")
                }
                userViewModelInitiation()
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
        .accentColor(.getAppColor(.primary))
        .navigationViewStyle(.stack)
        .customSheet($showSettings, sheetType: .settings, content: {
            SettingsView(username: userViewModel.user?.fullName ?? "Full Name", userEmail: "Apple ID", initial: userViewModel.generateInitial(), showAlert: $showSignOutAlert, showPrivacyPolicy: $showPrivacyPolicy, showTermsAndConditions: $showTermsAndConditions)
        })
        .customSheet($showPrivacyPolicy, sheetType: .rules, content: {
            PrivacyPolicyView()
        })
        .customSheet($showTermsAndConditions, sheetType: .rules, content: {
            TermsAndConditionsView()
        })
        .alertOverlay($showUndoAlert, content: {
            CustomAlertView(title: "Are you sure you want to Undo your progress?", message: "Every step forward matters. Are you sure you want to go back?", dismiss: "Cancel", destruct: "Undo") {
                showUndoAlert = false
            } destructAction: {
                guard let undoArg else { return }
                userViewModel.undoCountSubJournal(subJournalId: undoArg.0, from: undoArg.1)
                self.undoArg = nil
                showUndoAlert = false
            }

        })
        .alertOverlay($showSignOutAlert, content: {
            CustomAlertView(title: "Are you sure you want to Sign Out?", message: "Signing out means that you will need to sign in again when you open the apps.", dismiss: "Cancel", destruct: "Sign Out", dismissAction: {
                showSignOutAlert = false
            }, destructAction: {
                do {
                    showSignOutAlert = false
                    isLoading = true
                    try auth.signOut()
                    loadingSuccess()
                } catch {
                    print(error)
                }
            })
        })
        .customSheet($showFilter, sheetType: .filters, content: {
            FilterView(selectedFilter: $selectedFilter, appliedFilter: $appliedFilter, date: $selectedDate, userVM: userViewModel)
                .onDisappear {
                    if selectedFilter != appliedFilter {
                        selectedFilter = appliedFilter
                    }
                }
        })
        .alertOverlay($userViewModel.isStreakJustAdded, content: {
            StreakGainView(isShown: $userViewModel.isStreakJustAdded, streakCount: userViewModel.streakCount)
        })
        .alertOverlay($userViewModel.isStreakJustDeleted, content: {
            StreakLossView(streakCount: userViewModel.streakCount, isShown: $userViewModel.isStreakJustDeleted)
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
        .alertOverlay($isLoading, content: {
            LoadingView(loadingType: $loadingStatus, message: $loadingMessage)
        })
        .onChange(of: selectedDate) { newValue in
            userViewModel.getSubJournals(from: newValue)
        }
    }


}

private extension JournalView {

    func sortJournal() {
        switch sortType {
        case .unsort:
            userViewModel.filterSubJournalsByProgress(from: selectedDate, isAscending: nil)
        case .ascending:
            userViewModel.filterSubJournalsByProgress(from: selectedDate, isAscending: true)
        case .descending:
            userViewModel.filterSubJournalsByProgress(from: selectedDate, isAscending: false)
        }
    }

    func loadingSuccess() {
        loadingMessage = "Signed Out"
        loadingStatus = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            appRootManager.currentRoot = .onBoardingView
        }
    }

    func userViewModelInitiation() {
        userViewModel.generateJournalEntries()
        userViewModel.checkIsStreak()
        userViewModel.getSubJournals(from: selectedDate)
        userViewModel.getSubFutureJournals()
        userViewModel.getHabitNotificationId()
        userViewModel.checkFutureJournalThatHasSubJournal()
    }
}
