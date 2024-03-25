//
//  HabitCoApp.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import Firebase

@main
struct HabitCoApp: App {
    
    @StateObject private var appRootManager = AppRootManager()
    @Environment(\.auth) var authUser
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            switch appRootManager.currentRoot {
            case .splashView:
                UserDefaultManager.hasSplashScreen ? AnyView(OnboardingView()) : AnyView(SplashScreenView())
            case .onBoardingView:
                OnboardingView()
                    .transition(.slide)
            case .journalView:
                JournalView()
                    .transition(.slide)
            }
        }
        .environment(\.appRootManager, appRootManager)
    }
}
