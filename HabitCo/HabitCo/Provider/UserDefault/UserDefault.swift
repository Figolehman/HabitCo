//
//  UserDefault.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation

final class UserDefaultManager {
    
    private enum Keys: String {
        case hasSplashScreen
    }
    
    
    static var hasSplashScreen: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSplashScreen.rawValue) }
        set (newValue) { UserDefaults.standard.setValue(newValue, forKey:  Keys.hasSplashScreen.rawValue)}
    }
    
}
