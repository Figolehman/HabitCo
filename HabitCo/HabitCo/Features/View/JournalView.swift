//
//  JournalView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import SwiftUI

struct JournalView: View {
    
    @State var showSheet = false
    @State var showCreateHabit = false
    @State var showStreak = false
    @State var showPrivacyPolicy = false
    @State var showTermsAndConditions = false
    @State var showFilter = false
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 48) {
                
                ScrollableCalendarView(hasHabit: [])
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
                        Text("March, 2024")
                            .foregroundColor(.getAppColor(.neutral))
                            .font(.largeTitle.weight(.bold))
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showSheet = true
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
        .customSheet($showSheet, sheetType: .settings, content: {
            SettingsView(username: "Full Name", userEmail: "FullName@habitmail.com", initial: "FL", showAlert: $showAlert, showPrivacyPolicy: $showPrivacyPolicy, showTermsAndConditions: $showTermsAndConditions)
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
            }, destructAction: {})
        })
        .customSheet($showFilter, sheetType: .filters, content: {
            FilterView()
        })
        .alertOverlay($showStreak, content: {
            StreakGainView(isShown: $showStreak)
        })
        .alertOverlay($showCreateHabit, closeOnTap: true, content: {
            VStack (spacing: 24) {
                CreateButton(type: .habit) {
                    
                }
                CreateButton(type: .pomodoro) {
                    
                }
            }
        })
        .onAppear {
            let customNavigation = UINavigationBarAppearance()
            customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            
            UINavigationBar.appearance().standardAppearance = customNavigation
        }
    }
}

#Preview {
    JournalView()
}
