//
//  FilterView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 03/04/24.
//

import SwiftUI

struct FilterView: View {
    @State var selectedFilter: Set<Color.FilterColors> = []
    
    @Binding var date: Date
    
    @ObservedObject var userVM: UserViewModel
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 6)
        
        VStack(spacing: .getResponsiveHeight(80)){
            LazyVGrid(columns: columns, alignment: .center, spacing: .getResponsiveWidth(12)){
                ForEach(Color.FilterColors.allCases, id: \.self) { filter in
                    LabelButton(tag: filter, selection: $selectedFilter, color: Color(filter.rawValue))
                        
                }
            }.padding(.horizontal, 24)
            
            AppButton(label: "Save", sizeType: .submit, action: {
                userVM.filterJournal(date: date, label: "")
            })
        }
    }
}

#Preview {
    FilterView(date: .constant(Date()), userVM: UserViewModel())
}
