//
//  DateFormatter.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import Foundation

final class DateFormatUtil{
    static let shared = DateFormatUtil()
    
    public func dateToString(date: Date, to format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        
        let string = df.string(from: date)
        return string
    }
    
}
