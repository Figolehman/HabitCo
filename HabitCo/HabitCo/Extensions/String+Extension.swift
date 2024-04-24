//
//  String+Extension.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 23/04/24.
//

import Foundation

extension String {
    func stringToDate(to format: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df.date(from: self) ?? Date()
    }
}
