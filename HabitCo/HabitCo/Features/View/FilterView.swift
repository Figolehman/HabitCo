//
//  FilterView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 03/04/24.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedFilter: [Color.FilterColors]
    @Binding var appliedFilter: [Color.FilterColors]

    @Binding var date: Date
    
    @ObservedObject var userVM: UserViewModel

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 6)
        
        VStack(spacing: .getResponsiveHeight(80)){
            LazyVGrid(columns: columns, alignment: .center, spacing: .getResponsiveWidth(12)){
                ForEach(Color.FilterColors.allCases, id: \.self) { filter in
                    LabelButton(tag: filter, selection: $selectedFilter, color: Color(filter.rawValue))
                }
            }.padding(.horizontal, 24)
            
            let selectedLabel = selectedFilter.map { $0.rawValue }
            AppButton(label: "Save", sizeType: .submit, action: {
                appliedFilter = selectedFilter
                userVM.filterSubJournalsByLabels(date: date, labels: selectedLabel)
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    FilterView(selectedFilter: .constant([]), appliedFilter: .constant([]), date: .constant(Date()), userVM: UserViewModel())
}
