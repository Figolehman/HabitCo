//
//  EditPomodoroView.swift
//  HabitCo
//
//  Created by Geraldy Kumara on 25/05/24.
//

import SwiftUI

struct EditPomodoroView: View {
    
    var pomodoro: PomodoroDB
    
    @State private var pomodoroName: String = ""
    @State private var description: String = ""
    @State private var selected: Color.FilterColors? = nil
    @State private var session: Int = 1
    
    @State private var isRepeatOn = true
    @State private var isReminderOn = false
    
    @State private var focusTime: Int = 0
    @State private var breakTime: Int = 0
    @State private var longBreakTime: Int = 0
    
    @State private var isRepeatFolded = false
    @State private var isReminderFolded = true
    @State private var isLabelFolded = true
    
    @State private var isFocusTimeFolded = true
    @State private var isBreakTimeFolded = true
    @State private var isLongBreakTimeFolded = true
    
    @State private var repeatDate: Set<RepeatDay> = []
    @State private var reminderTime: Date = Date()
    
    @State var showAlert = false
    
    @State private var currentDefaultPomodoro: DefaultPomodoro?
    
    @StateObject var pomodoroVM = PomodoroViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    init(pomodoro: PomodoroDB) {
        self.pomodoro = pomodoro
        _repeatDate = State(initialValue: [])
        _pomodoroName = State(initialValue: pomodoro.pomodoroName!)
        _description = State(initialValue: pomodoro.description!)
        _focusTime = State(initialValue: pomodoro.focusTime!)
        _breakTime = State(initialValue: pomodoro.breakTime!)
        _longBreakTime = State(initialValue: pomodoro.longBreakTime!)

        for color in Color.FilterColors.allCases {
            if pomodoro.label == color.rawValue {
                _selected = State(initialValue: color)
            }
        }

        _session = State(initialValue: pomodoro.session!)
        _isReminderOn = State(initialValue: pomodoro.reminderPomodoro != nil)
        _isReminderFolded = State(initialValue: isReminderOn)

        if let reminderHabit = pomodoro.reminderPomodoro {
            _reminderTime = State(initialValue: reminderHabit.stringToDate(to: .hourAndMinute))
        }
    }

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
                    EditableCardView(cardType: .name, text: $pomodoroName)
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
                                    .foregroundColor((selected == nil) ? .getAppColor(.primary2) : Color(selected!.rawValue))
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
                        }
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Break Time")
                                Spacer()
                                AppButton(label: "\(breakTime == 0 ? "Not Set" : "\(breakTime)")", sizeType: .select) {
                                    if isFocusTimeFolded {
                                        withAnimation {
                                            isBreakTimeFolded = false
                                            if breakTime == 0 {
                                                breakTime = 1
                                            }
                                        }
                                    } else {
                                        withAnimation {
                                            isBreakTimeFolded = true
                                        }
                                    }
                                }
                            }
                            if !isBreakTimeFolded {
                                Picker("", selection: $breakTime) {
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
                        }
                    }
                    
                    CardView {
                        VStack (spacing: 12) {
                            HStack {
                                Text("Long Break Time")
                                Spacer()
                                AppButton(label: "\(focusTime == 0 ? "Not Set" : "\(longBreakTime)")", sizeType: .select) {
                                    if isLongBreakTimeFolded {
                                        withAnimation {
                                            isLongBreakTimeFolded = false
                                            if longBreakTime == 0 {
                                                longBreakTime = 1
                                            }
                                        }
                                    } else {
                                        withAnimation {
                                            isLongBreakTimeFolded = true
                                        }
                                    }
                                }
                            }
                            if !isLongBreakTimeFolded {
                                Picker("", selection: $longBreakTime) {
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
                        }
                    }
                }
                let repeatPomodoro: [Int] = repeatDate.map { $0.weekday }
                AppButton(label: "Save", sizeType: .submit) {
                    pomodoroVM.editPomodoro(pomodoroId: pomodoro.id, pomodoroName: pomodoroName, description: description, label: selected?.rawValue, session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderHabit: reminderTime)
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding(.top, 4)
            }
        }
        .alertOverlay($showAlert, content: {
            CustomAlertView(title: "Are you sure you want to Delete this pomodoro?", message: "Any progress and data linked to this will be lost permanently, and you wont be able to recover it", dismiss: "Cancel", destruct: "Delete", dismissAction: {
                showAlert = false
            }, destructAction: {
                pomodoroVM.deletePomodoro(pomodoroId: pomodoro.id)
                self.presentationMode.wrappedValue.dismiss()
            })
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            for pomodoroDay in pomodoro.repeatPomodoro! {
               for day in RepeatDay.allCases {
                   if day.weekday == pomodoroDay {
                       repeatDate.insert(day)
                   }
               }
            }
        }
        .navigationTitle("Edit Pomodoro Form")
        .navigationBarTitleDisplayMode(.large)
    }
    
    
}

