//
//  LabeledStepper.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

struct LabeledStepper: View {
    @Binding var frequency: Int
    var body: some View {
        HStack {
            Button {
                if frequency > 1 {
                    frequency = frequency - 1
                }
            } label: {
                Image(systemName: "minus")
            }
            Spacer()
            Divider()
                .frame(height: 20)
                .overlay (
                    Color.getAppColor(.neutral3)
                )
            Spacer()
            Text("\(frequency)")
            Spacer()
            Divider()
                .frame(height: 20)
                .overlay (
                    Color.getAppColor(.neutral3)
                )
            Spacer()
            Button {
                frequency = frequency + 1
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(12)
        .frame(width: .getResponsiveWidth(141), height: .getResponsiveHeight(38))
        .foregroundColor(.getAppColor(.neutral3))
        .background(
            Color.getAppColor(.primary)
        )
        .cornerRadius(12)
    }
}

#Preview {
    LabeledStepper(frequency: .constant(0))
}
