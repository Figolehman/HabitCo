//
//  HabitItem.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import SwiftUI

struct HabitItem: View {
    var body: some View {
        HStack {
            Image(systemName: "square.dashed")
                .padding(.trailing, 16)
            
            Text("Habit Name")
            
            Spacer()
            
            Divider()
                .frame(height: 70, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            VStack {
                Image(systemName: "timer")
                    .font(.title3)
                    .padding(2)
            
                Text("5 Session")
                    .font(.caption2)
            }
            .padding(6)
            
        }
        .padding(.horizontal, 12)
        .frame(width: 345, height: 80, alignment: .center)
        .background(Color(red: 0.78, green: 0.78, blue: 0.8))
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HabitItem()
}
