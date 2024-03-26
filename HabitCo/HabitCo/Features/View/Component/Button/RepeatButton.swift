//
//  RepeatButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

enum RepeatDay: CaseIterable {
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
    @Binding var isSelected: Bool
    let day: RepeatDay
    let action: () -> ()
    
    init(repeatDays: Binding<[RepeatDay]>, day: RepeatDay, action: @escaping () -> Void = {}) {
        self._isSelected = Binding(
            get: { repeatDays.wrappedValue.contains(day) },
            set: { value in
                if value {
                    repeatDays.wrappedValue.append(day)
                } else {
                    repeatDays.wrappedValue.remove(at: repeatDays.wrappedValue.firstIndex(of: day)!)
                }
            })
        self.day = day
        self.action = action
    }
    
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
        .background(isSelected ? Color.getAppColor(.primary) : Color.getAppColor(.primary2))
        .clipShape(Circle())
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

//#Preview {
//    RepeatButton(isSelected: false, day: .sunday) {
//        
//    }
//}
