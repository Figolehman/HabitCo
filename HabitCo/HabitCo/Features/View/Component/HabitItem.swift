//
//  HabitItem.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import SwiftUI

enum HabitType {
    case regular
    case pomodoro
}

struct HabitItem: View {
    @State private var offset: CGFloat = 0
    @State private var firstOffset: CGFloat = 0
    
    let progressSize: CGFloat = 50
    let habitType: HabitType
    let habitName: String
    let fraction: Double
    let progress: Int
    
    let navigate: () -> Void
    let action: () -> Void
    
    init(habitType: HabitType, habitName: String, fraction: Double = 1, progress: Int = 2, navigate: @escaping () -> Void = {}, action: @escaping () -> Void = {}) {
        self.habitType = habitType
        self.habitName = habitName
        self.fraction = fraction
        self.progress = progress
        self.navigate = navigate
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack (spacing: .getResponsiveWidth(4)) {
                Button {
                    navigate()
                } label: {
                    HStack (spacing: 16){
                        Rectangle()
                            .foregroundColor(.yellow)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        
                        Text("\(habitName)")
                            .foregroundColor(Color.getAppColor(.neutral3))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(width: .getResponsiveWidth(265), height: .getResponsiveHeight(80))
                    .background(
                        Color.getAppColor(.primary)
                    )
                }
                
    //            .cornerRadius(12)
                
                    Button {
                        action()
                    } label: {
                        Group {
                            switch habitType {
                            case .regular:
                                VStack {
                                    Image(systemName: "timer")
                                        .font(.title3)
                                        .padding(2)
                                
                                    Text("\(progress) Session")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                            case .pomodoro:
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
                                .padding(.horizontal, 12)
                            }
                        }
                        .foregroundColor(.getAppColor(.neutral3))
                        .frame(width: .getResponsiveWidth(76), height: .getResponsiveHeight(80))
                        .background(
                            Color.getAppColor(.primary)
                        )

                    }
                
            }
            .mask(
                Rectangle()
                    .cornerRadius(12)
            )
            
            
            Button {
                
            } label: {
                Text("Undo")
                    .foregroundColor(Color.getAppColor(.neutral3))
                    .frame(width: .getResponsiveWidth(116), height: .getResponsiveHeight(80))
                    .background(
                        Color.getAppColor(.secondary)
                    )
                    .cornerRadius(12)
            }
        }
        .offset(x: offset + .getResponsiveWidth(66))
        .mask(
            Rectangle()
                .frame(width: .getResponsiveWidth(345), height: .getResponsiveHeight(80))
        )
        .highPriorityGesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.width
                    self.offset = min(0, self.firstOffset + translation)
//                    self.offset = translation
                }
                .onEnded { value in
                    if self.offset <= .getResponsiveWidth(-70) {
                        self.offset = -133
                    } else {
                        self.offset = 0
                    }
                    self.firstOffset = self.offset
                }
        )
    }
}

#Preview {
    NavigationView {
        VStack {
            HabitItem(habitType: .regular, habitName: "test", fraction: 0.5)
            HabitItem(habitType: .pomodoro, habitName: "test", fraction: 0.5)
        }
    }
}
