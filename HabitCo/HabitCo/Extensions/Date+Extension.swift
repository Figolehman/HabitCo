//
//  File.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import Foundation
//import SwiftUI

extension Date {
    
    enum FormatType: String {
        case fullMonthName = "MMMM dd, yyyy"
    }
    
    static func getDatesInRange(of a: Date, to b: Date) -> [Date] {
        guard a < b else { return [] }
        
        var currentDate = a
        
        var result = [Date]()
        
        while currentDate < b {
            result.append(currentDate)
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    var getDayName: String {
        switch self.get(.weekday) {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return "N/A"
        }
    }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let afterLastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
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
        return Calendar.current.date(byAdding: .day, value: -(startOfMonthWeekday - 1), to: self.startOfMonth)!
    }
    
    var calendarDisplayDate: [Date] {
        var dates: [Date] = []
        
        for dayOffset in 0...self.numberOfDaysInMonth - 1 {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: self.startOfMonth)
            dates.append(newDay!)
        }

        return dates

    }
    
    var sundayBeforeToday: Date {
        let day = self.get(.weekday)
        return Calendar.current.date(byAdding: .day, value: -(day - 1), to: self)!
    }
    
    var weeklyDisplayDate: [Date] {
        let sundayThisWeek = self.sundayBeforeToday
        
        var days = [Date]()
        
        for dayOffset in 0..<7 {
            days.append(Calendar.current.date(byAdding: .day, value: dayOffset, to: sundayThisWeek)!)
        }
        
        return days
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func getFormattedTime() -> String {
        // Extract time from date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en")
        
        return dateFormatter.string(from: self)
    }
    
    func isSameDay(_ date: Date) -> Bool {
        let a = self.get(.day, .month, .year)
        let b = date.get(.day, .month, .year)
        return a == b
    }
    
    func dateToString(to format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df.string(from: self)
    }
    
    func formattedDate(to format: FormatType) -> Date {
        dateToString(to: format.rawValue).stringToDate(to: format.rawValue)
    }
    
    func getMonthAndYearString() -> String {
        let calendar = Calendar.current
        if let todayMonthYear = calendar.date(byAdding: .month, value: 0, to: self) {
            return DateFormatUtil().dateToString(date: todayMonthYear, to: "MMMM, yyyy")
        }
        return ""
    }
    
    func getMonthAndYearDate() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }
}
