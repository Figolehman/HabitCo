//
//  SplashScreenView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var showSplashScreen: Bool = false
    
    var body: some View {
        ZStack{
            if self.showSplashScreen {
                OnboardingView()
            } else {
                VStack (spacing: 24) {
                    
                    Image(systemName: "square.dashed")
                        .font(.system(size: 110))
                        .foregroundColor(.getAppColor(.primary))
                    
                    Text("HabitCo")
                        .font(.largeTitle)
                        .foregroundColor(.getAppColor(.neutral))
                    
                }
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.showSplashScreen = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
