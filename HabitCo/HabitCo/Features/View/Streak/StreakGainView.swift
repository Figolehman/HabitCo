//
//  StreakGainView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 30/03/24.
//

import SwiftUI

struct StreakGainView: View {
    @Binding var isShown: Bool
    
    var body: some View {
        VStack (alignment: .center, spacing: .getResponsiveHeight(72)){
            Image("gainTree-\(Int.random(in: 1...2))")
            
            VStack (spacing: .getResponsiveHeight(24)) {
                Text("Congratulations on your X days streak!")
                    .multilineTextAlignment(.center)
                    .font(.body.weight(.semibold))
                
                Text("\(Prompt.gainStreakPrompt[Int.random(in: 0...1)])")
                    .multilineTextAlignment(.center)
                    
                VStack (spacing: .getResponsiveHeight(16)) {
                    AppButton(label: "Share", sizeType: .share) {
                        
                    }
                    AppButton(label: "Close", sizeType: .share) {
                        withAnimation {
                            isShown = false
                        }
                    }
                }
                .padding(.top, .getResponsiveHeight(12))
                
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
//
#Preview {
    EmptyView()
        .alertOverlay(.constant(true)) {
            StreakGainView(isShown: .constant(true))
        }
}
