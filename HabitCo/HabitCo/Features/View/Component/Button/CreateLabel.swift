//
//  CreateButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

enum CreateType {
    case habit
    case pomodoro
    
    var systemImage: String {
        get {
            switch self {
            case .habit:
                "leaf"
            case .pomodoro:
                "timer"
            }
        }
    }
    
    var label: String {
        get {
            switch self {
            case .habit:
                "Create New Habit"
            case .pomodoro:
                "Create New Pomodoro Habit"
            }
        }
    }
}

struct CreateLabel: View {
    let type: CreateType
    
    var body: some View {
        HStack (spacing: 12) {
            Image(systemName: type.systemImage)
            Text(type.label)
            Spacer()
        }
        .foregroundColor(.getAppColor(.neutral3))
        .padding(.horizontal, 12)
        .frame(width: .getResponsiveWidth(345), height: .getResponsiveHeight(80))
        .background(Color.getAppColor(.primary))
        .cornerRadius(12)
    }
}

#Preview {
    CreateLabel(type: .pomodoro)
}
