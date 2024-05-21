//
//  Date+String.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 19/05/24.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
