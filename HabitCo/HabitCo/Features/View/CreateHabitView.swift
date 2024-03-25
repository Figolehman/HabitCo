//
//  CreateHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

struct CreateHabitView: View {

    @State var selected: Color.FilterColors? = nil
    @State var frequency: Int = 0
    
    
    @State var isReminderOn = false
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 40) {
                VStack (spacing: 16) {
                    EditableCardView(cardType: .name)
                    EditableCardView(cardType: .description)
                }
                
                VStack (spacing: 24) {
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Label")
                                Spacer()
                                Rectangle()
                                    .cornerRadius(12)
                                    .frame(width: .getResponsiveWidth(124), height: .getResponsiveHeight(46))
                                    .foregroundColor((selected == nil) ? .getAppColor(.primary2) : Color(selected!.rawValue))
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), content: {
                                ForEach(Color.FilterColors.allCases, id: \.self) { filter in
                                    LabelButton(tag: filter, selection: $selected, color: Color(filter.rawValue))
                                }
                            })
                        }
                    }
                    
                    CardView {
                        HStack {
                            Text("Frequency")
                            Spacer()
                            LabeledStepper(frequency: $frequency )
                        }
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                AppButton(label: "No Reminder", sizeType: .select) {
                                    
                                }
                            }
                            Toggle("Don't set reminder", isOn: $isReminderOn)
                                .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
                        }
                        
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Reminder")
                                Spacer()
                                AppButton(label: "No Reminder", sizeType: .select) {
                                    
                                }
                            }
                            Toggle("Don't set reminder", isOn: $isReminderOn)
                                .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
                        }
                        
                    }
                }
                
                AppButton(label: "Save", sizeType: .submit) {
                    // Save Action Here
                }
                .padding(.top, 4)
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
