//
//  SettingButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import SwiftUI

struct SettingButton: View {
    let label: String
    let action: () -> ()
    let icon: String
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .padding(.trailing, 16)
                Text(label)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.getAppColor(.neutral3))
        }
        .padding(.horizontal, 12)
        .frame(width: 345, height: 54, alignment: .center)
        .background(Color.getAppColor(.primary))
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    SettingButton(label: "HELLO", action: {}, icon: "square.dashed")
}
