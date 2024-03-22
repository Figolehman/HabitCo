//
//  File.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import Foundation
import SwiftUI


// MARK: - View Modifier Utility
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Elevation Effect View Modifier
extension View {
    func elevate1() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 6, x: 0, y: 2)
    }
    
    func elevate2() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 16, x: 0, y: 4)
    }
    
    func elevate3() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 24, x: 0, y: 10)
    }
}

#Preview {
    AppButton(label: "Submit", sizeType: .submit) {
        
    }
    .elevate3()
}
