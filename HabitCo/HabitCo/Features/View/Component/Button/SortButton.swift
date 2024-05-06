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
    
    var isAscending: Bool? {
        switch self {
        case .unsort:
            return nil
        case .ascending:
            return true
        case .descending:
            return false
        }
    }
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
        .foregroundColor(.getAppColor(.neutral3))
        .frame(height: 38)
        .padding(.horizontal, 12)
        .background(isDisabled ? Color.getAppColor(.primary3) : Color.getAppColor(.primary))
        .cornerRadius(12)
        .disabled(isDisabled)
    }
}

#Preview {
    SortButton(label: "Progress", isDisabled: .constant(false), imageType: .unsort) {}
}
