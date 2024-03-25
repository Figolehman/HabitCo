//
//  CreateHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

struct CreateHabitView: View {
    var body: some View {
        Group {
            VStack (spacing: 16) {
                EditableCardView(cardType: .name)
                EditableCardView(cardType: .description)
            }
        }
        .navigationTitle("Create Habit Form")
    }
}

#Preview {
    NavigationView {
        CreateHabitView()
    }
}
