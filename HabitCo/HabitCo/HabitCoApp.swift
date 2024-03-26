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
                SplashScreenView()
                    .environmentObject(appRootManager)
            case .onBoardingView:
                OnboardingView()
                    .environmentObject(appRootManager)
            case .journalView:
                JournalView()
                    .environmentObject(appRootManager)
            }
        }
    }
}
