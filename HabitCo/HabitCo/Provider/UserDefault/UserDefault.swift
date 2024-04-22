//
//  UserDefault.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation

final class UserDefaultManager {
    
    private enum Keys: String {
        case isLogin
        case isJournalCreated
        case lastEntryDate
        case userID
    }

    static var isLogin: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isLogin.rawValue) }
        set (newValue) { UserDefaults.standard.setValue(newValue, forKey:  Keys.isLogin.rawValue)}
    }
    
    static var lastEntryDate: Date {
        get { UserDefaults.standard.object(forKey: Keys.lastEntryDate.rawValue) as? Date ?? Date() }
        set (newValue) { UserDefaults.standard.setValue(newValue, forKey:  Keys.lastEntryDate.rawValue)}
    }
    
    static var userID: String? {
        get { UserDefaults.standard.string(forKey: Keys.userID.rawValue) }
        set (newValue) { UserDefaults.standard.setValue(newValue, forKey:  Keys.userID.rawValue)}
    }
    
}
