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
    let habitName: String
    let fraction: Double
    let progress: Int
    
    init(habitType: HabitType, habitName: String, fraction: Double = 1, progress: Int = 2) {
        self.habitType = habitType
        self.habitName = habitName
        self.fraction = fraction
        self.progress = progress
    }
    
    var body: some View {
        HStack {
            Group {
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)
                    .padding(.trailing, 16)
                
                Text("\(habitName)")
                
                Spacer()
            }
            .onTapGesture {
                // view habit detail
            }
            
            Divider()
                .frame(width: 1, height: .getResponsiveHeight(62))
                .overlay (
                    Color.getAppColor(.neutral3)
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
                        .foregroundColor(.getAppColor(.primary))
                        .frame(width: progressSize, height: progressSize)
                    
                    Circle()
                        .stroke(Color.getAppColor(.primary2), lineWidth: 5)
                        .frame(width: progressSize, height: progressSize)
                    
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(fraction))
                        .stroke(Color.getAppColor(.neutral), lineWidth: 5)
                        .frame(width: progressSize, height: progressSize)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(progress)")
                        .foregroundColor(.getAppColor(.neutral3))
                }
                .padding(.horizontal, 6)
                .onTapGesture {
                    
                }
            }
            
            
        }
        .foregroundColor(.getAppColor(.neutral3))
        .padding(.horizontal, 12)
        .frame(width: .getResponsiveWidth(345), height: .getResponsiveHeight(80), alignment: .center)
        .background(Color.getAppColor(.primary))
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack {
        HabitItem(habitType: .type1, habitName: "test", fraction: 0.5)
        HabitItem(habitType: .type2, habitName: "test", fraction: 0.5)
    }
}
