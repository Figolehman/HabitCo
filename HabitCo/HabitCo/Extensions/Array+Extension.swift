//
//  Array+Extension.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 24/04/24.
//

import Foundation

extension Array<Int> {
    func contains(array: [Int]) -> Bool {
        for element in array {
            if !self.contains(element) {
                return false
            }
        }
        return true
    }
    
    func containsWeekendOnly() -> Bool {
        return self.contains(array: [1, 7]) && !self.contains(2) && !self.contains(3) && !self.contains(4) && !self.contains(5) && !self.contains(6)
    }
    
    func containsWeekdayOnly() -> Bool {
        return self.contains(array: [2, 3, 4, 5, 6, 7]) && !self.contains(7) && !self.contains(1)
    }
    
    func containsEveryday() -> Bool {
        return self.contains(array: [1, 2, 3, 4, 5, 6, 7])
    }
    
    func checkFirstInt() -> String {
          guard let firstInt = self.first else {
              return "Empty Array"
          }
          
          switch firstInt {
          case 1:
              return "Sunday"
          case 2:
              return "Monday"
          case 3:
              return "Tuesday"
          case 4:
              return "Wednesday"
          case 5:
              return "Thursday"
          case 6:
              return "Friday"
          case 7:
              return "Saturday"
          default:
              return "Unknown"
          }
      }
    
    func getRepeatLabel() -> String {
        return "\(self.isEmpty ? "No Repeat" : self.count == 1 ?  checkFirstInt() : self.containsEveryday() ? "Everyday" : self.containsWeekdayOnly() ? "Weekday" : self.containsWeekendOnly() ? "Weekend" : "Custom")"
    }
}
