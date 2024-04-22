//
//  DateFormatter.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import Foundation


final class DateFormatUtil{
    static let shared = DateFormatUtil()
    
    enum FormatType: String {
        case fullMonthName = "MMMM dd, yyyy"
    }
    
    public func formattedDate(date: Date, to format: FormatType) -> Date {
        let string = dateToString(date: date, to: format.rawValue)
        return stringToDate(dateString: string, to: format.rawValue)
    }
    
    public func dateToString(date: Date, to format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df.string(from: date)
    }
    
    public func stringToDate(dateString: String, to format: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df.date(from: dateString) ?? Date()
    }
    
    
}
