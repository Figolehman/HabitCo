//
//  JournalView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import SwiftUI

private enum Navigator {
    case createHabit, createPomodoro, habitDetail, pomodoroDetail, focus
    case none
}

struct JournalView: View {

    let backAlert = BackButtonActionAlert.shared

    @State private var undoArg: (String, Date)?

    @State private var loading = (false, LoadingType.loading, "")

    @State private var navigateTo: Navigator? = Navigator.none
    @State private var focusNavigationArg: (PomodoroDB?, SubJournalDB?, Date)?

    @State private var sortType = SortImage.unsort

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
    @State private var showJournalView = true

    @State private var showBackAlert = false
    @State private var showNavigationLink = true

    @Environment(\.auth) var auth
    @EnvironmentObject var appRootManager: AppRootManager
    
    var showPopUpGainStreak: Binding<Bool> {
        Binding {
            userViewModel.popUpGainStreak && showJournalView
        } set: { value in
            userViewModel.popUpGainStreak = value
        }
    }

    
    var body: some View {
        NavigationView {

            VStack(spacing: 48) {

                HStack (spacing: 8) {
                    Image(systemName: "flame")
                        .font(.caption)
                    Text("\(userViewModel.streakCount) Day Streak!")
                        .font(.caption)
                        .foregroundColor(.getAppColor(.neutral))

                    Spacer()
                    // MARK: - navigation links
                    if showNavigationLink {
                        NavigationLink(destination: CreateHabitView(habitNotificationId: userViewModel.habitNotificationId ?? "", loading: $loading, showAlertView: $showBackAlert, habitVM: habitViewModel), tag: .createHabit, selection: $navigateTo) {
                            EmptyView()
                        }
                        NavigationLink(destination: CreatePomodoroView(habitNotificationId: userViewModel.habitNotificationId ?? "", loading: $loading,  showAlertView: $showBackAlert, pomodoroVM: pomodoroViewModel), tag: .createPomodoro, selection: $navigateTo) {
                            EmptyView()
                        }
                        NavigationLink(destination: HabitDetailView(loading: $loading, showBackAlert: $showBackAlert, habitVM: habitViewModel, userVM: userViewModel), tag: .habitDetail, selection: $navigateTo) {
                            EmptyView()
                        }
                        NavigationLink(destination: PomodoroDetailView(loading: $loading, showBackAlert: $showBackAlert, pomodoroVM: pomodoroViewModel, userVM: userViewModel), tag: .pomodoroDetail, selection: $navigateTo) {
                            EmptyView()
                        }
                    }
                    if focusNavigationArg != nil {
                        NavigationLink(destination: FocusView(pomodoro: focusNavigationArg!.0, subJournal: focusNavigationArg!.1, date: focusNavigationArg!.2, loading: $loading, showBackAlert: $showBackAlert, userViewModel: userViewModel), tag: .focus, selection: $navigateTo) {
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Group {
                    ScrollableCalendarView(hasHabit: userViewModel.hasHabit ?? [], selectedDate: $selectedDate)

                    VStack (spacing: 24) {
                        HStack (spacing: 16) {
                            FilterButton(isDisabled: $userViewModel.hasSubJournal) {
                                withAnimation {
                                    showFilter = true
                                }
                            }

                            SortButton(label: "Progress", isDisabled: $userViewModel.hasSubJournal, imageType: $sortType) {
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

                        if !appliedFilter.isEmpty {
                            ScrollView(.horizontal) {
                                HStack(spacing: .getResponsiveWidth(8)) {
                                    ForEach(appliedFilter, id: \.self) { filter in
                                        Button {
                                            if let index = appliedFilter.firstIndex(of: filter) {
                                                appliedFilter.remove(at: index)
                                                selectedFilter = appliedFilter
                                            }
                                            let selectedLabel = selectedFilter.map { $0.rawValue }
                                            userViewModel.filterSubJournalsByLabels(date: selectedDate, labels: selectedLabel)
                                        } label: {
                                            FilterLabelView(filter: filter)
                                        }
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
                                            HabitItem(habitType: .regular, habitName: item.habit?.habitName ?? "NO NAME", isComplete: item.subJournal.isCompleted ?? true, label: item.habit?.label ?? "", fraction: item.subJournal.fraction ?? 0.0, progress: item.subJournal.startFrequency ?? 0) {
                                                habitViewModel.setHabit(habit: item.habit!)
                                                navigateTo = .habitDetail
                                            } action: {
                                                userViewModel.updateCountSubJournal(subJournalId: item.subJournal.id ?? "", from: selectedDate)
                                            } undoAction: {
                                                showUndoAlert = true
                                                undoArg = (item.subJournal.id ?? "", selectedDate)
                                            }
                                        } else {
                                            HabitItem(habitType: .pomodoro, habitName: item.pomodoro?.pomodoroName ?? "NO NAME", isComplete: item.subJournal.isCompleted ?? true, label: item.pomodoro?.label ?? "", progress: item.subJournal.startFrequency ?? 0) {
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
                            } else {
                                VStack (spacing: .getResponsiveHeight(16)) {
                                    Image(systemName: "leaf")
                                        .font(.largeTitle)
                                    Text(userViewModel.hasSubJournal ? "There’s no habit recorded yet." : "There's no habit with this label")
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
                    debugPrint("No Authenticated User")
                }
                userViewModelInitiation()

                backAlert.backAction = {
                    withAnimation {
                        showBackAlert = false
                        showNavigationLink = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showNavigationLink = true
                    }
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
            .onAppear {
                showJournalView = true
            }
            .onDisappear {
                showJournalView = false
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
                showSignOutAlert = false
                loading.2 = "Logging out..."
                loading.0 = true
                loading.1 = .loading
                do {
                    try auth.signOut()
                    loadingSuccess()
                } catch {
                    debugPrint(error)
                }
            })
        })
        .customSheet($showFilter, sheetType: .filters, onLeftButtonTapped: { selectedFilter = appliedFilter }, onRightButtonTapped: { selectedFilter = [] }, content: {
            FilterView(selectedFilter: $selectedFilter, appliedFilter: $appliedFilter, showFilter: $showFilter, date: $selectedDate, userVM: userViewModel) {
                showFilter = false
            }
        })
        .alertOverlay(showPopUpGainStreak, content: {
            StreakGainView(isShown: showPopUpGainStreak, userVM: userViewModel, streakCount: userViewModel.streakCount)
        })
        .alertOverlay($userViewModel.popUpLossStreak, content: {
            StreakLossView(isShown: $userViewModel.popUpLossStreak, userVM: userViewModel, streakCount: userViewModel.streakCount)
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
        .alertOverlay($loading.0, content: {
            LoadingView(loadingType: $loading.1, message: $loading.2)
        })
        .alertOverlay($showBackAlert, content: {
            CustomAlertView(title: "Are you sure you want to Cancel this habit?", message: "You will lose all the changes you make.", dismiss: "Cancel", destruct: "Yes") {
                showBackAlert = false
            } destructAction: {
                backAlert.backAction()
            }

        })
        .onChange(of: selectedDate) { newValue in
            userViewModel.getSubJournals(from: newValue)
            userViewModel.checkSubJournal(date: newValue)
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
        loading.2 = "Signed Out"
        loading.1 = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loading.0 = false
            loading.1 = .loading
            appRootManager.currentRoot = .onBoardingView
        }
    }

    func userViewModelInitiation() {
        userViewModel.generateJournalEntries()
        userViewModel.checkIsStreak()
        userViewModel.getSubJournals(from: selectedDate)
        userViewModel.getSubFutureJournals()
        userViewModel.checkFutureJournalThatHasSubJournal()
        userViewModel.checkSubJournal(date: selectedDate.formattedDate(to: .fullMonthName))
    }
}
