//
//  LabelButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import SwiftUI

struct LabelButton: View {
    @State var isSelected: Bool
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            action()
        }, label: {
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
            } else {
                Color.clear
            }
        })
        .frame(width: 40, height: 40)
        .background(
            ZStack{
                Circle()
                    .foregroundColor(.purple.opacity(0.5))
                
                if isSelected {
                    Circle()
                        .stroke(lineWidth: 2)
                }
            }
        )
    }
}

#Preview {
    LabelButton(isSelected: false){
        
    }
}
