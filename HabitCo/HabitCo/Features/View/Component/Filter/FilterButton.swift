//
//  SortButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI


struct FilterButton: View {
    @Binding var isDisabled: Bool
    var action: () -> ()
    
    var body: some View {
        Button("Filter", systemImage: "slider.horizontal.3") {
            action()
        }
        .foregroundColor(Color.black)
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    FilterButton(isDisabled: .constant(true)) {}
}
