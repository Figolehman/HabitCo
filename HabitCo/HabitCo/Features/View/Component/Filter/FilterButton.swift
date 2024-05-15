//
//  SortButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI


struct FilterButton: View {
    @Binding var isDisabled: Bool
    var action: () -> () = {}
    
    var body: some View {
        Button("Filter", systemImage: "slider.horizontal.3") {
            action()
        }
        .foregroundColor(.getAppColor(.neutral3))
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(isDisabled ? Color.getAppColor(.primary3) : Color.getAppColor(.primary))
        .cornerRadius(12)
        .disabled(isDisabled)
    }
}

#Preview {
    FilterButton(isDisabled: .constant(true)) {}
}
