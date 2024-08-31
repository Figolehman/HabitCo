//
//  InformationButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 31/08/24.
//

import SwiftUI

struct InformationButton: View {
    let action: () -> Void

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "info.circle")
                .renderingMode(.template)
                .foregroundColor(.black)
                .font(.system(size: 11))
        }
    }
}

#Preview {
    InformationButton()
}
