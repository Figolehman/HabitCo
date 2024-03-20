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
    @State var isSelected: Bool
    let day: RepeatDay
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            action()
        }, label: {
            Text(day.initial)
                .font(.body)
                .foregroundColor(.white)
        })
        .frame(width: 40, height: 40)
        .background(isSelected ? Color.black : Color.yellow)
        .clipShape(Circle())
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    RepeatButton(isSelected: false, day: .sunday) {
        
    }
}
