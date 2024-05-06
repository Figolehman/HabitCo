//
//  EditHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 28/03/24.
//

import SwiftUI

struct EditHabitView: View {
    
    @State private var selected: Color.FilterColors?
    @State private var frequency: Int
    
    @State private var isRepeatOn = true
    @State private var isReminderOn = false
    
    @State private var isRepeatFolded = false
    @State private var isReminderFolded = true
    @State private var isLabelFolded = false

    @State private var repeatDate: Set<RepeatDay>
    @State private var reminderTime: Date = Date()
    
    var habit: HabitDB

    @State var habitName: String
    @State var description: String

    init(habit: HabitDB) {
        self.habit = habit
        _repeatDate = State(initialValue: [])
        _habitName = State(initialValue: habit.habitName!)
        _description = State(initialValue: habit.description!)

        for color in Color.FilterColors.allCases {
            if habit.label == color.rawValue {
                _selected = State(initialValue: color)
            }
        }

        _frequency = State(initialValue: habit.frequency!)
        _isReminderOn = State(initialValue: habit.reminderHabit != nil)
        _isReminderFolded = State(initialValue: isReminderOn)

        if let reminderHabit = habit.reminderHabit {
            _reminderTime = State(initialValue: reminderHabit.stringToDate(to: .hourAndMinute))
        }
    }

    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 40) {
                VStack (spacing: 16) {
                    EditableCardView(cardType: .name, text: $habitName)
                    EditableCardView(cardType: .description, text: $description)
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
                                    .foregroundColor(Color(selected!.rawValue))
                                    .onTapGesture {
                                        withAnimation {
                                            isLabelFolded.toggle()
                                        }
                                    }
                            }
                            if !isLabelFolded {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), content: {
                                    ForEach(Color.FilterColors.allCases, id: \.self) { filter in
                                        LabelButton(tag: filter, selection: $selected, color: Color(filter.rawValue))
                                    }
                                })
                            }
                        }
                    }
                    
                    CardView {
                        HStack {
                            Text("Frequency")
                            Spacer()
                            LabeledStepper(frequency: $frequency )
                        }
                    }
//
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                AppButton(label: "\(repeatDate.getRepeatLabel())", sizeType: .select) {
                                    if isRepeatFolded {
                                        withAnimation {
                                            isRepeatFolded = false
                                            isRepeatOn = true
                                        }
                                    } else {
                                        withAnimation {
                                            isRepeatFolded = true
                                        }
                                    }
                                    
                                }
                            }
                            if !isRepeatFolded {
                                Toggle("Set repeat", isOn: $isRepeatOn.animation())
                                    .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
                                if isRepeatOn {
                                    HStack {
                                        ForEach(RepeatDay.allCases, id: \.self) { day in
                                            RepeatButton(repeatDays: $repeatDate, day: day)
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Reminder")
                                Spacer()
                                AppButton(label: "\(isReminderOn ? reminderTime.getFormattedTime() : "No Reminder")", sizeType: .select) {
                                    if isReminderFolded{
                                        withAnimation {
                                            isReminderFolded = false
                                            isReminderOn = true
                                        }
                                    } else {
                                        withAnimation {
                                            isReminderFolded = true
                                        }
                                    }
                                }
                            }
                            if !isReminderFolded {
                                Toggle("Set reminder", isOn: $isReminderOn.animation())
                                    .toggleStyle(SwitchToggleStyle(tint: .getAppColor(.primary)))
                                
                                if isReminderOn {
                                    DatePicker("", selection: $reminderTime, displayedComponents: [.hourAndMinute])
                                        .datePickerStyle(.wheel)
                                        .background(
                                            Color.getAppColor(.primary3)
                                                .cornerRadius(13)
                                        )
                                        .environment(\.colorScheme, .dark)
                                        .environment(\.locale, .init(identifier: "en"))
                                }
                            }
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
        .onAppear {
            for habitDay in habit.repeatHabit! {
               for day in RepeatDay.allCases {
                   if day.weekday == habitDay {
                       repeatDate.insert(day)
                       print(day)
                   }
               }
            }
        }
    }
}

