//
//  Card.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

struct CardView<Content: View>: View {
    let color: Color
    var content: () -> Content
    
    init(color: Color = .white, content: @escaping () -> Content) {
        self.color = color
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(16)
            .frame(width: 345, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    EditableCardView(cardType: .description)
}
