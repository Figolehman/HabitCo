//
//  SplashScreenView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
    var body: some View {
        ZStack{
            VStack (spacing: 24) {
                
                Image(systemName: "square.dashed")
                    .font(.system(size: 110))
                    .foregroundColor(.getAppColor(.primary))
                
                Text("HabitCo")
                    .font(.largeTitle)
                    .foregroundColor(.getAppColor(.neutral))
                
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if UserDefaultManager.isLogin {
                    appRootManager.currentRoot = .journalView
                } else {
                    appRootManager.currentRoot = .onBoardingView
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
