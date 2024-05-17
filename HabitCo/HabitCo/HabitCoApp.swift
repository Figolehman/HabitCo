//
//  HabitCoApp.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import WidgetKit

@main
struct HabitCoApp: App {
    let notify = NotificationHandler()

    var widgetManager: WidgetManager {
        WidgetManager()
    }

    @StateObject private var appRootManager = AppRootManager()
    @AppStorage("hasOpened") var hasOpened = false
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
        
        if UserDefaults.standard.bool(forKey: "hasOpened") == false {
            do {
                try Auth.auth().signOut()
            } catch {
                debugPrint(error.localizedDescription)
            }
            notify.askPermission()
        }
    }
        
    var body: some Scene {
        WindowGroup {
            switch appRootManager.currentRoot {
            case .splashView:
                SplashScreenView()
                    .environmentObject(appRootManager)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                        widgetManager.getSubJournalToday(){
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
            case .onBoardingView:
                OnboardingView()
                    .environmentObject(appRootManager)
            case .journalView:
                if hasOpened {
                    JournalView()
                        .environmentObject(appRootManager)
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                            widgetManager.getSubJournalToday(){
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                } else {
                    TutorialView() {
                        notify.removeAllNotification()
                        notify.askPermission()
                        let currentDate = Date()
                        let date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: currentDate)!
                        let date2 = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: currentDate)!
                        notify.sendNotification(timeInterval: 10, title: "ASdAS", body: "dsdsd")
                        notify.sendNotification(date: date, weekdays: [1,3,5,7], title: Prompt.appName, body: "What you do today can improve all your tomorrows. Start your day with HabitCo!", withIdentifier: "Default1")
                        notify.sendNotification(date: date, weekdays: [2,4,6], title: Prompt.appName, body: "The secret of getting ahead is getting started. Kickstart your day by making strides in your habit!", withIdentifier: "Default2")
                        notify.sendNotification(date: date2, weekdays: [1,2,3,4,5,6,7], title: Prompt.appName, body: "The day is almost over, let’s complete your habit to keep your habit streaks!", withIdentifier: "Default3")
                        hasOpened = true
                    }
                }
            }
        }
    }
}
