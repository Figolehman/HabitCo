//
//  RepeatButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

enum RepeatDay: String, CaseIterable {
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
    
    var weekday: Int {
        get {
            switch self {
            case .sunday:
                1
            case .monday:
                2
            case .tuesday:
                3
            case .wednesday:
                4
            case .thursday:
                5
            case .friday:
                6
            case .saturday:
                7
            }
        }
    }
}

struct RepeatButton: View {
    @Binding var isSelected: Bool
    let day: RepeatDay
    let action: () -> ()
    
    init(repeatDays: Binding<Set<RepeatDay>>, day: RepeatDay, action: @escaping () -> Void = {}) {
        self._isSelected = Binding(
            get: { repeatDays.wrappedValue.contains(day) },
            set: { value in
                if value {
                    repeatDays.wrappedValue.insert(day)
                } else {
                    repeatDays.wrappedValue.remove(day)
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

// MARK: - Extension for RepeatDay
extension Set<RepeatDay> {
    func contains(set: Set<RepeatDay>) -> Bool {
        for thing in set {
            if !self.contains(thing) {
                return false
            }
        }
        return true
    }
    
    func containsWeekendOnly() -> Bool {
        return self.contains(set: [.saturday, .sunday]) && !self.contains(.monday) && !self.contains(.tuesday) && !self.contains(.wednesday) && !self.contains(.thursday) && !self.contains(.friday)
    }
    
    func containsWeekdayOnly() -> Bool {
        return self.contains(set: [.monday, .tuesday, .wednesday, .thursday, .friday]) && !self.contains(.saturday) && !self.contains(.sunday)
    }
    
    func containsEveryday() -> Bool {
        return self.contains(set: Set(RepeatDay.allCases))
    }
    
    func getRepeatLabel() -> String {
        return "\(self.isEmpty ? "No Repeat" : self.count == 1 ?  self.first!.rawValue.capitalized : self.containsEveryday() ? "Everyday" : self.containsWeekdayOnly() ? "Weekday" : self.containsWeekendOnly() ? "Weekend" : "Custom")"
    }
}

