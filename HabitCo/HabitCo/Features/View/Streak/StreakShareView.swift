//
//  StreakShareView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/04/24.
//

import SwiftUI

struct StreakShareView: View {
    let streak: Int
    var body: some View {
        VStack (spacing: .getResponsiveHeight(72)) {
            Spacer()
            Image("shareTree-\(Int.random(in: 1...2))")
            
            VStack (spacing: .getResponsiveHeight(24)) {
                Text("\(streak) days streak!")
                
                Text("\(Prompt.shareStreakPrompt[Int.random(in: 0...1)])")
                    .multilineTextAlignment(.center)
            }
            
            Image("blobsJournal")
                .resizable()
                .ignoresSafeArea()
        }
    }
}

#Preview {
        Image(uiImage: StreakShareView(streak: 10).snapshot())
    
}
