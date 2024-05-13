//
//  StreakShareView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/04/24.
//

import SwiftUI

struct StreakShareView: View {
    let streak: Int
    let x: Int?
    let y: Int?
    let index = Date().get(.day) % 2

    init(streak: Int, x: Int? = nil, y: Int? = nil) {
        self.streak = streak
        self.x = x
        self.y = y
    }
    
    var body: some View {
        VStack (spacing: .getResponsiveHeight(72)) {
            Spacer()
            
            Image("shareTree-\(index + 1)")
            VStack (spacing: .getResponsiveHeight(24)) {
                Text("\(streak) days streak!")
                
                Text("\(Prompt.shareStreakPrompt(streak: streak, x: x, y: y))")
                    .multilineTextAlignment(.center)
            }
            
            
            Spacer()
        }
        .background(
            VStack {
                Spacer()
                Image("blobsStreak")
//                    .resizable()
//                    .ignoresSafeArea()
            }
                .ignoresSafeArea()
        )
    }
}

#Preview {
        Image(uiImage: StreakShareView(streak: 10).snapshot())
}
#Preview {
    StreakShareView(streak: 10)
}
