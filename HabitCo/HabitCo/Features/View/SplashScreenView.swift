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
            
            Image(systemName: "square.dashed")
                .font(.system(size: 110))
                .foregroundColor(.getAppColor(.primary))
            
            Text("HabitCo")
                .font(.largeTitle)
                .foregroundColor(.getAppColor(.neutral))
            
        }
    }
}

#Preview {
    SplashScreenView()
}
