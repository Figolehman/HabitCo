//
//  CreatePomodoroView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 26/03/24.
//

import SwiftUI

struct CreatePomodoroView: View {

    let notify = NotificationHandler()
    
    let habitNotificationId: String

    @State private var showLabelInformation = false
    @State private var showRepeatInformation = false
    @State private var showReminderInformation = false
    @State private var showSessionInformation = false
    @State private var showAutoSetInformation = false
    @State private var showFocusInformation = false
    @State private var showBreakInformation = false
    @State private var showLongBreakInformation = false

    @Binding var loading: (Bool, LoadingType, String)
    @Binding var showAlertView: Bool

    @State private var pomodoroName: String = ""
    @State private var description: String = ""
    @State private var selected: Color.FilterColors? = nil
    @State private var session: Int = 1
    
    @State private var isRepeatOn = false
    @State private var isReminderOn = false
    
    @State private var focusTime: Int = 0
    @State private var breakTime: Int = 0
    @State private var longBreakTime: Int = 0
    
    @State private var isRepeatFolded = true
    @State private var isReminderFolded = true
    @State private var isLabelFolded = true
    
    @State private var isFocusTimeFolded = true
    @State private var isBreakTimeFolded = true
    @State private var isLongBreakTimeFolded = true
    
    @State private var repeatDate: Set<RepeatDay> = []
    @State private var reminderTime: Date = Date()
    
    @State private var currentDefaultPomodoro: DefaultPomodoro?
    
    @ObservedObject var pomodoroVM: PomodoroViewModel
    
    @Environment(\.presentationMode) var presentationMode

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
                .padding(.top, .getResponsiveHeight(36))

                VStack (spacing: 24) {
                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Label")
                                InformationButton {
                                    showLabelInformation.toggle()
                                }
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
                    .if(showLabelInformation) { view in
                        view
                            .overlay(
                                Image(.labelInformation)
                                    .offset(x: 22, y: isLabelFolded ? -50 : -100)
                            )
                    }

                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Repeat")
                                InformationButton {
                                    showRepeatInformation.toggle()
                                }
                                Spacer()
                                AppButton(label: "\(isRepeatOn ? repeatDate.getRepeatLabel() : "No Repeat")", sizeType: .select) {
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
                    .if(showRepeatInformation) { view in
                        view
                            .overlay(
                                Image(.repeatInformation)
                                    .offset(x: isRepeatFolded ? 10 : 17, y: isRepeatFolded ? -50 : -98)
                            )
                    }

                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Reminder")
                                InformationButton {
                                    showReminderInformation.toggle()
                                }
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
                                            Color.getAppColor(.primary)
                                                .cornerRadius(13)
                                        )
                                        .environment(\.colorScheme, .dark)
                                        .environment(\.locale, .init(identifier: "en"))
                                }
                            }
                        }
                    }
                    .if(showReminderInformation) { view in
                        view
                            .overlay(
                                Image(.reminderInformation)
                                    .offset(x: isReminderFolded ? 12 : 20, y: isReminderFolded ? -50 : -185)
                            )
                    }

                    CardView {
                        HStack (spacing: 4) {
                            Text("Session")
                            InformationButton {
                                showSessionInformation.toggle()
                            }
                            Spacer()
                            LabeledStepper(frequency: $session )
                        }
                    }
                    .if(showSessionInformation) { view in
                        view
                            .overlay(
                                Image(.sessionInformation)
                                    .offset(x: 8, y: -50)
                            )
                    }

                    CardView {
                        VStack (alignment: .leading, spacing: 12){
                            HStack (spacing: 4) {
                                Text("Auto Set Pomodoro")
                                InformationButton{
                                    showAutoSetInformation.toggle()
                                }
                            }
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
                                        Color.getAppColor(.primary)
                                    )
                                    .cornerRadius(12)
                                    .elevate3()
                                }
                            }
                        }
                    }
                    .if(showAutoSetInformation) { view in
                        view
                            .overlay(
                                Image(.autoSetInformation)
                                    .offset(x: 64, y: -80)
                            )
                    }

                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Focus Time")
                                InformationButton {
                                    showFocusInformation.toggle()
                                }
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
                                    Color.getAppColor(.primary)
                                        .cornerRadius(13)
                                )
                                .environment(\.colorScheme, .dark)
                            }
                        }
                    }
                    .if(showFocusInformation) { view in
                        view
                            .overlay(
                                Image(.focusInformation)
                                    .offset(x: -2, y: isFocusTimeFolded ? -50 : -164)
                            )
                    }

                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Break Time")
                                InformationButton {
                                    showBreakInformation.toggle()
                                }
                                Spacer()
                                AppButton(label: "\(breakTime == 0 ? "Not Set" : "\(breakTime)")", sizeType: .select) {
                                    if isBreakTimeFolded {
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
                                    Color.getAppColor(.primary)
                                        .cornerRadius(13)
                                )
                                .environment(\.colorScheme, .dark)
                            }
                        }
                    }
                    .if(showBreakInformation) { view in
                        view
                            .overlay(
                                Image(.breakInformation)
                                    .offset(x: -5, y: isBreakTimeFolded ? -50 : -164)
                            )
                    }

                    CardView {
                        VStack (spacing: 12) {
                            HStack (spacing: 4) {
                                Text("Long Break Time")
                                InformationButton {
                                    showLongBreakInformation.toggle()
                                }
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
                                    Color.getAppColor(.primary)
                                        .cornerRadius(13)
                                )
                                .environment(\.colorScheme, .dark)
                            }
                        }
                    }
                    .if(showLongBreakInformation) { view in
                        view
                            .overlay(
                                Image(.longBreakInformation)
                                    .offset(x: -3, y: isLongBreakTimeFolded ? -50 : -164)
                            )
                    }
                }
                let repeatPomodoro: [Int] = repeatDate.map { $0.weekday }
                AppButton(label: "Save", sizeType: .submit, isDisabled: !isSavable()) {
                    if isSavable() {
                        loading.2 = "Saving..."
                        loading.1 = .loading
                        loading.0 = true   
                        pomodoroVM.createUserPomodoro(pomodoroName: pomodoroName, description: description, label: selected?.rawValue ?? "", session: session, focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime, repeatPomodoro: repeatPomodoro, reminderPomodoro: isReminderOn ? reminderTime : nil) {
                            loadingSuccess()
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .background (
            Color.neutral3
                .frame(width: ScreenSize.width, height: ScreenSize.height)
                .ignoresSafeArea()
        )
        .navigationTitle("Create Pomodoro Form")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton {
                    showAlertView = true
                }
            }
        }
    }
}

// MARK: -
private extension CreatePomodoroView {
    func isSavable() -> Bool {
        return isRepeatOn && focusTime != 0 && breakTime != 0 && longBreakTime != 0 && !repeatDate.isEmpty && !pomodoroName.isEmpty && selected != nil
    }

    func loadingSuccess() {
        loading.1 = .success
        loading.2 = "Saved"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loading.0 = false
            loading.1 = .loading
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationView {
        CreatePomodoroView(habitNotificationId: "0", loading: .constant((false, LoadingType.loading, "")), showAlertView: .constant(false),pomodoroVM: PomodoroViewModel())
    }
}
