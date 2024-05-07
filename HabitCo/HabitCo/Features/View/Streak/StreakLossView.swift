//
//  StreakLossView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 01/04/24.
//

import SwiftUI

struct StreakLossView: View {
    
    let streakCount: Int
    
    @Binding var isShown: Bool
    
    var body: some View {
        VStack (alignment: .center, spacing: .getResponsiveHeight(72)){
            Image("lossTree")
            
            VStack (spacing: .getResponsiveHeight(24)) {
                Text("Congratulations on your X days streak!")
                    .multilineTextAlignment(.center)
                    .font(.body.weight(.semibold))
                
                Text("\(Prompt.lossStreakPrompt[0])")
                    .multilineTextAlignment(.center)
                    
                AppButton(label: "Close", sizeType: .share) {
                    withAnimation {
                        isShown = false
                    }
                }
                .padding(.top, .getResponsiveHeight(24))
                
            }
        }
        .padding(.horizontal, .getResponsiveWidth(24))
        .padding(.vertical, .getResponsiveHeight(48))
        .frame(width: .getResponsiveWidth(353))
        .background(
            Color.getAppColor(.neutral3)
        )
        .cornerRadius(24)
    }
}

#Preview {
    EmptyView()
        .alertOverlay(.constant(true)) {
            StreakLossView(streakCount: 3, isShown: .constant(true))
        }
}
