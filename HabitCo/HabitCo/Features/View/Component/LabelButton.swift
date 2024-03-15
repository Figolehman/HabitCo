//
//  LabelButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import SwiftUI

struct LabelButton: View {
    var withMark: Bool
    
    var body: some View {
        Button(action: {
            
        }, label: {
            if withMark {
                Image(systemName: "square.dashed")
                    .foregroundColor(.black)
            }
        })
        .frame(width: 40, height: 40)
        .background(
            ZStack{
                Circle()
                    .foregroundColor(.purple.opacity(0.5))
                
                if withMark {
                    Circle()
                        .stroke(lineWidth: 2)
                }
            }
        )
    }
}

#Preview {
    LabelButton(withMark: true)
}
