//
//  SortButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

enum SortImage: String {
    case unsort = "arrow.up.arrow.down"
    case ascending = "arrow.down"
    case descending = "arrow.up"
}

struct SortButton: View {
    var label: String
    @Binding var isDisabled: Bool
    var imageType: SortImage
    var action: () -> ()
    
    var imageName: String {
        get {
            imageType.rawValue
        }
    }
    
    var body: some View {
        Button(label, systemImage: imageType.rawValue) {
            action()
        }
        .font(.body)
        .foregroundColor(Color.black)
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SortButton(label: "Progress", isDisabled: .constant(true), imageType: .unsort) {}
}
