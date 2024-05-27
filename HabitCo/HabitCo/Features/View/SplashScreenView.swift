//
//  SplashScreenView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        VStack (spacing: 24) {
            
            Color.clear
                .frame(width: .getResponsiveWidth(110), height: .getResponsiveHeight(220))
                .overlay (
                    Image("logo")
                        .offset(y: .getResponsiveHeight(220 - 167))
                        .clipped()
                )
            
            Text("HabitCo")
                .font(.largeTitle)
                .foregroundColor(.getAppColor(.neutral))
            
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if UserDefaultManager.isLogin {
                    appRootManager.currentRoot = .journalView
                    do {
                        try userViewModel.getCurrentUserData {
                            do {
                                try userViewModel.getAllJournal()
                            } catch {
                                print("No Journal")
                            }
                        }
                    } catch {
                        print("No Authenticated User")
                    }
                } else {
                    appRootManager.currentRoot = .onBoardingView
                }
            }
        }
    }
}

