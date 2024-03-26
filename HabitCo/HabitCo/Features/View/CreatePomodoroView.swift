//
//  CreatePomodoroView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 26/03/24.
//

import SwiftUI

struct CreatePomodoroView: View {
    
    @State var selected: Color.FilterColors? = nil
    @State var session: Int = 1
    
    @State var isRepeatOn = false
    @State var isReminderOn = false
    
    @State var focusTime: Int = 0
    @State var breakTime: Int = 0
    @State var longBreakTime: Int = 0
    
    @State var isRepeatFolded = true
    @State var isReminderFolded = true
    @State var isLabelFolded = true
    
    @State var isFocusTimeFolded = true
    @State var isBreakTimeFolded = true
    @State var isLongBreakTimeFolded = true
    
    @State var repeatDate: [RepeatDay] = []
    @State var reminderTime: Date = Date()
    
    @State private var currentDefaultPomodoro: DefaultPomodoro?
    
    private enum DefaultPomodoro: CaseIterable {
        case type1, type2, type3
        
        var format: String {
            get {
                switch self {
                case .type1:
                    "25-5-30"
                case .type2:
                    "52-17-17"
                case .type3:
                    "90-20-20"
                }
            }
        }
        
        var pomodoroTime: (Int, Int, Int) {
            get {
                switch self {
                case .type1:
                    (25, 5, 30)
                case .type2:
                    (52, 17, 17)
                case .type3:
                    (90, 20, 20)
                }
            }
        }
    }
    
    
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
                                    .onTapGesture {
                                        withAnimation {
                                            isLabelFolded = false
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
                        VStack (spacing: 12) {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                AppButton(label: "No Repeat", sizeType: .select) {
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
                    
                    CardView {
                        HStack {
                            Text("Session")
                            Spacer()
                            LabeledStepper(frequency: $session )
                        }
                    }
                    
                    CardView {
                        VStack (alignment: .leading, spacing: 12){
                            Text("Auto Set Pomodoro")
                            HStack {
                                ForEach(DefaultPomodoro.allCases, id: \.self) { type in
                                    Button {
                                        currentDefaultPomodoro = type
                                        focusTime = type.pomodoroTime.0
                                        breakTime = type.pomodoroTime.1
                                        longBreakTime = type.pomodoroTime.2
                                    } label: {
                                        Text(type.format)
                                            .font(.system(size: 17))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .frame(height: 46)
                                    .background(
                                        currentDefaultPomodoro == type ?
                                        Color.getAppColor(.primary) :
                                        Color.getAppColor(.primary2)
                                    )
                                    .cornerRadius(12)
                                    .elevate3()
                                }
                            }
                        }
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Focus Time")
                                Spacer()
                                AppButton(label: "\(focusTime == 0 ? "Not Set" : "\(focusTime)")", sizeType: .select) {
                                    if isFocusTimeFolded {
                                        withAnimation {
                                            isFocusTimeFolded = false
                                            if focusTime == 0 {
                                                focusTime = 1
                                            }
                                        }
                                    } else {
                                        withAnimation {
                                            isFocusTimeFolded = true
                                        }
                                    }
                                }
                            }
                            if !isFocusTimeFolded {
                                Picker("", selection: $focusTime) {
                                    ForEach(1...180, id: \.self) { value in
                                        Text("\(value)")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .background(
                                    Color.getAppColor(.primary3)
                                        .cornerRadius(13)
                                )
                                .environment(\.colorScheme, .dark)
                            }
//
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
    CreatePomodoroView()
}
