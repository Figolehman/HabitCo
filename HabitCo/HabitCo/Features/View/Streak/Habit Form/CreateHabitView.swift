//
//  CreateHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

struct CreateHabitView: View {

    let notify = NotificationHandler()

    let habitNotificationId: String

    @State private var isLoading = false
    @State private var loadingStatus = LoadingType.loading
    @State private var loadingMessage = "Saving..."

    @State private var habitName: String = ""
    @State private var description: String = ""
    @State private var label: Color.FilterColors? = nil
    @State private var frequency: Int = 1
    
    @State private var isRepeatOn = false
    @State private var isReminderOn = false
    
    @State private var isRepeatFolded = true
    @State private var isReminderFolded = true
    @State private var isLabelFolded = true
    
    @State private var repeatDate: Set<RepeatDay> = []
    @State private var reminderTime: Date = Date()

    @ObservedObject var habitVM: HabitViewModel
    
    @Environment(\.presentationMode) var presentationMode

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
                                    .foregroundColor((label == nil) ? .getAppColor(.primary2) : Color(label!.rawValue))
                                    .onTapGesture {
                                        withAnimation {
                                            isLabelFolded.toggle()
                                        }
                                    }
                            }
                            if !isLabelFolded {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), content: {
                                    ForEach(Color.FilterColors.allCases, id: \.self) { filter in
                                        LabelButton(tag: filter, selection: $label, color: Color(filter.rawValue))
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
                                            Color.getAppColor(.primary)
                                                .cornerRadius(13)
                                        )
                                        .environment(\.colorScheme, .dark)
                                        .environment(\.locale, .init(identifier: "en"))
                                }
                            }
                        }
                    }
                }
                let repeatDateInt: [Int] = repeatDate.map { $0.weekday }
                AppButton(label: "Save", sizeType: .submit, isDisabled: !isSavable()) {
                    guard isSavable() else { return }
                    notify.sendNotification(date: reminderTime, weekdays: repeatDateInt, title: "\(habitName)", body: "Go finish it", withIdentifier: "\(habitNotificationId)")
                    isLoading = true
                    habitVM.createUserHabit(habitName: habitName, description: description, label: label?.rawValue ?? "", frequency: frequency, repeatHabit: repeatDateInt, reminderHabit: reminderTime) {
                        loadingSuccess()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.top, 4)
            }
        }
        .alertOverlay($isLoading, content: {
            LoadingView(loadingType: $loadingStatus, message: $loadingMessage)
        })
        .background (
            Color.neutral3
                .frame(width: ScreenSize.width, height: ScreenSize.height)
                .ignoresSafeArea()
        )
        .padding(.top, .getResponsiveHeight(36))
        .navigationTitle("Create Habit Form")
        .navigationBarTitleDisplayMode(.large)
    }
}


private extension CreateHabitView {
    func isSavable() -> Bool {
        return isRepeatOn && !repeatDate.isEmpty && !habitName.isEmpty && label != nil
    }

    func loadingSuccess() {
        loadingMessage = "Saved"
        loadingStatus = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationView {
        CreateHabitView(habitNotificationId: "0", habitVM: HabitViewModel())
    }
}
