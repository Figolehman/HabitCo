//
//  HabitItem.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import SwiftUI

enum HabitType {
    case type1
    case type2
}

struct HabitItem: View {
    let progressSize: CGFloat = 50
    
    let habitType: HabitType
    let fraction: Double
    let progress: Int
    
    init(habitType: HabitType, fraction: Double = 1, progress: Int = 2) {
        self.habitType = habitType
        self.fraction = fraction
        self.progress = progress
    }
    
    var body: some View {
        HStack {
            Image(systemName: "square.dashed")
                .padding(.trailing, 16)
            
            Text("Habit Name")
            
            Spacer()
            
            Divider()
                .frame(height: 62, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(
                    Color.black
                )
            
            
            switch habitType {
            case .type1:
                VStack {
                    Image(systemName: "timer")
                        .font(.title3)
                        .padding(2)
                
                    Text("\(progress) Session")
                        .font(.caption2)
                }
                .padding(6)
            case .type2:
                ZStack {
                    
                    Circle()
                        .foregroundColor(.black)
                        .frame(width: progressSize, height: progressSize)
                    
                    Circle()
                        .stroke(Color(UIColor.systemGray2), lineWidth: 8)
                        .frame(width: progressSize, height: progressSize)
                    
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(fraction))
                        .stroke(Color(UIColor.systemGray), lineWidth: 8)
                        .frame(width: progressSize, height: progressSize)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(progress)")
                        .foregroundColor(.white)
                }
                .padding(.leading, 12)
            }
            
            
        }
        .padding(.horizontal, 12)
        .frame(width: 345, height: 80, alignment: .center)
        .background(Color(red: 0.78, green: 0.78, blue: 0.8))
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HabitItem(habitType: .type1)
}
