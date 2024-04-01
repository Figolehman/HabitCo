//
//  SplashScreenView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct SplashScreenView: View {
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
    }
}

#Preview {
    SplashScreenView()
}
