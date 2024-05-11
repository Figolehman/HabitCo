//
//  FilterLabelView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 31/05/24.
//

import SwiftUI

struct FilterLabelView: View {
    let filter: Color.FilterColors

    var body: some View {
        HStack(spacing: .getResponsiveWidth(12)) {
            Text("\(filter.rawValue.capitalized)")
                .foregroundColor(.white)

            Circle()
                .frame(width: .getResponsiveWidth(22), height: .getResponsiveHeight(22))
                .foregroundColor(Color(filter.rawValue))
        }
        .padding(.horizontal, .getResponsiveWidth(12))
        .frame(height: .getResponsiveHeight(38))
        .background(
            Color.getAppColor(.primary)
                .cornerRadius(12)
        )
    }
}

#Preview {
    FilterLabelView(filter: .cornflower)
}
