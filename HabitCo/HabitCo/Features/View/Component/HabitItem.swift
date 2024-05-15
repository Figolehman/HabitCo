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
    let label: String
    let isComplete: Bool
    
    let navigate: () -> Void
    let action: () -> Void
    let undoAction: () -> Void
    
    @Binding var isShownSlided: Bool

    init(isShownSlided: Binding<Bool> = .constant(false), habitType: HabitType, habitName: String, isComplete: Bool = true, label: String, fraction: Double = 0.0, progress: Int = 2, navigate: @escaping () -> Void = {}, action: @escaping () -> Void = {}, undoAction: @escaping () -> Void = {}) {
        self._isShownSlided = isShownSlided
        self.habitType = habitType
        self.habitName = habitName
        self.label = label
        self.fraction = fraction
        self.progress = progress
        self.isComplete = isComplete
        self.navigate = navigate
        self.action = action
        self.undoAction = undoAction
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack (spacing: .getResponsiveWidth(4)) {
                Button {
                    navigate()
                } label: {
                    HStack (spacing: 16){
                        Rectangle()
                            .foregroundColor(Color(label))
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        
                        Text("\(habitName)")
                            .foregroundColor(isComplete ? .getAppColor(.primary2) : .getAppColor(.neutral3))
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(width: .getResponsiveWidth(265), height: .getResponsiveHeight(80))
                    .background(
                        Color.getAppColor(.primary)
                    )
                }
                                
                    Button {
                        action()
                    } label: {
                        Group {
                            switch habitType {
                            case .pomodoro:
                                VStack {
                                    Image(systemName: "timer")
                                        .font(.title3)
                                        .padding(2)
                                
                                    Text("\(progress) Session")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                            case .regular:
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
                                        .foregroundColor(isComplete ? .getAppColor(.primary2) : .getAppColor(.neutral3))
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                        .foregroundColor(isComplete ? .getAppColor(.primary2) : .getAppColor(.neutral3))
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
                undoAction()
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
        .offset(x: isShownSlided ? -133 + .getResponsiveWidth(66) : offset + .getResponsiveWidth(66))
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
            HabitItem(habitType: .regular, habitName: "test", label: "blossom", fraction: 1)
            HabitItem(habitType: .pomodoro, habitName: "test", label: "blossom", fraction: 1)
        }
    }
}
