//
//  RepeatButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

enum RepeatDay {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var initial: String {
        get {
            switch self {
            case .monday:
                return "M"
            case .tuesday:
                return "T"
            case .wednesday:
                return "W"
            case .thursday:
                return "T"
            case .friday:
                return "F"
            default:
                return "S"
            }
        }
    }
}

struct RepeatButton: View {
    var color: Color
    var day: RepeatDay
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(day.initial)
                .font(.body)
                .foregroundColor(.white)
        })
        .frame(width: 40, height: 40)
        .background(color)
        .clipShape(Circle())
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    RepeatButton(color: .appColor, day: .sunday) {
        
    }
}
