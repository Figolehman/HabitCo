//
//  AuthManagerEnvironmentKey.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import Foundation
import SwiftUI

public struct AuthManagerEnvironmentKey: EnvironmentKey {
    @MainActor
    public static let defaultValue: AuthManager = AuthManager(configuration: .firebase)
}

public extension EnvironmentValues {
    var auth: AuthManager {
        get { self[AuthManagerEnvironmentKey.self] }
        set { self[AuthManagerEnvironmentKey.self] = newValue }
    }
}
