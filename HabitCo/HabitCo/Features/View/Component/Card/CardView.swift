//
//  Card.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

struct CardView<Content: View>: View {
    let height: CGFloat
    let color: Color?
    var content: () -> Content
    
    init(height: CGFloat = .nan, color: Color = .getAppColor(.neutral3), content: @escaping () -> Content) {
        self.height = height
        self.color = color
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(16)
            .if(height.isNaN, transform: { content in
                content.frame(width: 345, alignment: .leading)
            })
            .if(!height.isNaN, transform: { content in
                content.frame(width: 345, height: height, alignment: .leading)
            })
            .background(color)
            .cornerRadius(12)
            .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    CardView {
        HStack{
            Text("SADASD")
            Spacer()
            Text("SADASD")
        }
    }
}
