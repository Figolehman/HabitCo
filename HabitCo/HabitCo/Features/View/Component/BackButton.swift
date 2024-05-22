//
//  BackButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/05/24.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text("Back")
            }
            .padding(0)
            .foregroundColor(.getAppColor(.primary))
        }
    }
}

#Preview {
    BackButton() {}
}
