//
//  HabitCoApp.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct HabitCoApp: App {
    
    @StateObject private var appRootManager = AppRootManager()
    @Environment(\.auth) var authUser
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings(sizeBytes: 500 * 1024 * 1024 as NSNumber))
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 500 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
        if let indexManager = Firestore.firestore().persistentCacheIndexManager {
            indexManager.enableIndexAutoCreation()
        }
//        UserDefaults.standard.set(false, forKey: "hasOpened")
        if UserDefaults.standard.bool(forKey: "hasOpened") == false {
            do {
                try Auth.auth().signOut()
                UserDefaultManager.hasTodayStreak = false
            } catch {
                debugPrint(error.localizedDescription)
            }
            let notify = NotificationHandler()
            notify.removeAllNotification()
            notify.askPermission()
            var dateComponent = Date().get(.hour, .minute)
            dateComponent.hour = 7
            dateComponent.minute = 0
            
            let date = Calendar.current.date(from: dateComponent)!
            
            notify.sendNotification(date: date, weekdays: [1,3,5,7], title: Prompt.appName, body: "What you do today can improve all your tomorrows. Start your day with HabitCo!", withIdentifier: "Default1")
            notify.sendNotification(date: date, weekdays: [2,4,6], title: Prompt.appName, body: "The secret of getting ahead is getting started. Kickstart your day by making strides in your habit!", withIdentifier: "Default2")
            UserDefaults.standard.set(true, forKey: "hasOpened")
        }
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
