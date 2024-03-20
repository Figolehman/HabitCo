//
//  FilterLabel.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

struct FilterLabel: View {
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            
            Circle()
                .foregroundColor(color)
                .frame(width: 22, height: 22)
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(
            Color.gray.opacity(0.7)
        )
        .cornerRadius(12)
        
    }
}

#Preview {
    FilterLabel(label: "Name", color: .green)
}
