//
//  CollectionReference+Extension.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import FirebaseFirestore

extension CollectionReference {
    func whereDateField(_ field: String, isEqualToDate date: Date) -> Query {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let startOfDay = calendar.date(from: components),
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            fatalError("Failed to create date range")
        }
        return whereField(field, isGreaterThanOrEqualTo: startOfDay).whereField(field, isLessThan: endOfDay)
    }
}
