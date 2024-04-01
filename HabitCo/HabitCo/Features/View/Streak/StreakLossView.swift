//
//  StreakLossView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 01/04/24.
//

import SwiftUI

struct StreakLossView: View {
    @Binding var isShown: Bool
    
    var body: some View {
        VStack (alignment: .center, spacing: .getResponsiveHeight(72)){
            Image(systemName: "square.dashed")
            
            VStack (spacing: .getResponsiveHeight(24)) {
                Text("Congratulations on your X days streak!")
                    .multilineTextAlignment(.center)
                    .font(.body.weight(.semibold))
                
                Text("Your persistence and determination are truly inspiring. You're one step closer to achieving your goals. Don't forget to share your achievement with your friends!")
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
    JournalView()
        .alertOverlay(.constant(true)) {
            StreakLossView(isShown: .constant(true))
        }
}
