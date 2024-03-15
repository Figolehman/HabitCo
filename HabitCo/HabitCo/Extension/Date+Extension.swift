//
//  File.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import Foundation

extension Date {
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        var afterLastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        // harus dikurangin 1 soalnya line atas ngasihnya start of day di hari pertama bulan berikutnya
        return Calendar.current.date(byAdding: .day, value: -1, to: afterLastDay)!
        
    }
    
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }
    
    var startOfNextMonth: Date {
        let dayInNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self)!
        return dayInNextMonth.startOfMonth
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: self.endOfMonth)
    }
    
    var sundayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: self.startOfMonth)
        let numberFromPreviousMonth = startOfMonthWeekday - 1
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: self.startOfMonth)!
    }
    
    var calendarDisplayDate: [Date] {
        var dates: [Date] = []
        
//        let saturdayBeforeStart = Calendar.current.date(byAdding: .day, value: 0, to: self.sundayBeforeStart)!
//        let dateOfSundayBeforeStart = saturdayBeforeStart.get(.day)
//        
//        for dayOffset in dateOfSundayBeforeStart...self.startOfPreviousMonth.numberOfDaysInMonth {
//            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: self.startOfPreviousMonth)
//            dates.append(newDay!)
//        }
        
        for dayOffset in 0...self.numberOfDaysInMonth - 1 {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: self.startOfMonth)
            dates.append(newDay!)
        }
//        for dayOffset in 0...self.startOfPreviousMonth.numberOfDaysInMonth - 1 {
//            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: self.startOfPreviousMonth)
//            dates.append(newDay!)
//        }
        return dates
//        return dates.filter{
//            $0 >= sundayBeforeStart && $0 <= endOfMonth
//        }.sorted(by: <)
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
