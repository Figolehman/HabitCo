//
//  UIApplication.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/05/24.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
