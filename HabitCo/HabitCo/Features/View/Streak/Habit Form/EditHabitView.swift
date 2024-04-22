////
////  EditHabitView.swift
////  HabitCo
////
////  Created by Figo Alessandro Lehman on 28/03/24.
////
//
//import SwiftUI
//
//struct EditHabitView: View {
//    
//    @State private var selected: Color.FilterColors? = nil
//    @State private var frequency: Int = 1
//    
//    @State private var isRepeatOn = false
//    @State private var isReminderOn = false
//    
//    @State private var isRepeatFolded = true
//    @State private var isReminderFolded = true
//    @State private var isLabelFolded = true
//    
//    @State private var repeatDate: Set<RepeatDay> = []
//    @State private var reminderTime: Date = Date()
//    
//    @State var habit: Habit
//    
//    var body: some View {
//        ScrollView (showsIndicators: false) {
//            VStack (spacing: 40) {
//                VStack (spacing: 16) {
//                    EditableCardView(cardType: .name)
//                    EditableCardView(cardType: .description)
//                }
//                
//                VStack (spacing: 24) {
//                    CardView {
//                        VStack (spacing: 12) {
//                            HStack {
//                                Text("Label")
//                                Spacer()
//                                Rectangle()
//                                    .cornerRadius(12)
//                                    .frame(width: .getResponsiveWidth(124), height: .getResponsiveHeight(46))
//                                    .foregroundColor((selected == nil) ? .getAppColor(.primary2) : Color(selected!.rawValue))
//                                    .onTapGesture {
//                                        withAnimation {
//                                            isLabelFolded.toggle()
//                                        }
//                                    }
//                            }
//                            if !isLabelFolded {
//                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), content: {
//                                    ForEach(Color.FilterColors.allCases, id: \.self) { filter in
//                                        LabelButton(tag: filter, selection: $selected, color: Color(filter.rawValue))
//                                    }
//                                })
//                            }
//                        }
//                    }
//                    
//                    CardView {
//                        HStack {
//                            Text("Frequency")
//                            Spacer()
//                            LabeledStepper(frequency: $frequency )
//                        }
//                    }
////
//                    CardView {
//                        VStack (spacing: 12) {
//                            HStack {
//                                Text("Repeat")
//                                Spacer()
//                                AppButton(label: "\(repeatDate.getRepeatLabel())", sizeType: .select) {
//                                    if isRepeatFolded {
//                                        withAnimation {
//                                            isRepeatFolded = false
//                                            isRepeatOn = true
//                                        }
//                                    } else {
//                                        withAnimation {
//                                            isRepeatFolded = true
//                                        }
//                                    }
//                                    
//                                }
//                            }
//                            if !isRepeatFolded {
//                                Toggle("Set repeat", isOn: $isRepeatOn.animation())
//                                    .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
//                                if isRepeatOn {
//                                    HStack {
//                                        ForEach(RepeatDay.allCases, id: \.self) { day in
//                                            RepeatButton(repeatDays: $repeatDate, day: day)
//                                        }
//                                    }
//                                }
//                            }
//                            
//                        }
//                        
//                    }
//                    
//                    CardView {
//                        VStack (spacing: 12) {
//                            HStack {
//                                Text("Reminder")
//                                Spacer()
//                                AppButton(label: "\(isReminderOn ? reminderTime.getFormattedTime() : "No Reminder")", sizeType: .select) {
//                                    if isReminderFolded{
//                                        withAnimation {
//                                            isReminderFolded = false
//                                            isReminderOn = true
//                                        }
//                                    } else {
//                                        withAnimation {
//                                            isReminderFolded = true
//                                        }
//                                    }
//                                }
//                            }
//                            if !isReminderFolded {
//                                Toggle("Set reminder", isOn: $isReminderOn.animation())
//                                    .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
//                                
//                                if isReminderOn {
//                                    DatePicker("", selection: $reminderTime, displayedComponents: [.hourAndMinute])
//                                        .datePickerStyle(.wheel)
//                                        .background(
//                                            Color.getAppColor(.primary3)
//                                                .cornerRadius(13)
//                                        )
//                                        .environment(\.colorScheme, .dark)
//                                        .environment(\.locale, .init(identifier: "en"))
//                                }
//                            }
//                        }
//                        
//                    }
//                }
//                
//                AppButton(label: "Save", sizeType: .submit) {
//                    // Save Action Here
//                    
//                }
//                .padding(.top, 4)
//            }
//        }
//        .navigationTitle("Create Habit Form")
//    }
//}
//
//#Preview {
//    EditHabitView()
//}
