//
//  CollectionReference+Extension.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 20/03/24.
//

import FirebaseFirestore

extension CollectionReference {
    func whereField(_ field: String, isDateInToday value: Date) -> Query {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: value)
        guard
            let start = Calendar.current.date(from: components),
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        else {
            fatalError("ERROR from CollectionReference+extension")
        }
        return whereField(field, isGreaterThan: start).whereField(field, isLessThan: end)
    }
}
