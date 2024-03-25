//
//  AppRootManager.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/03/24.
//

import Foundation

final class AppRootManager: ObservableObject{
    
    @Published var currentRoot: AppRoot = .splashView
    
    enum AppRoot {
        case splashView
        case onBoardingView
        case journalView
    }
}
