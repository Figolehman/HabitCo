//
//  AppRootManagerEnvironmentKey.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation
import SwiftUI

struct AppRootManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppRootManager = AppRootManager()
}

extension EnvironmentValues {
    var appRootManager: AppRootManager {
        get { self[AppRootManagerEnvironmentKey.self] }
        set { self[AppRootManagerEnvironmentKey.self] = newValue }
    }
}
