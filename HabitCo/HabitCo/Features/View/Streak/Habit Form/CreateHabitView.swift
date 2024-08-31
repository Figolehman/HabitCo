//
//  CreateHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/03/24.
//

import SwiftUI

struct CreateHabitView: View {

    let habitNotificationId: String

    @State private var showLabelInformation = false
    @State private var showFrequencyInformation = false
    @State private var showRepeatInformation = false
    @State private var showReminderInformation = false

    @Binding var loading: (Bool, LoadingType, String)
    @Binding var showAlertView: Bool

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
                    .if(showLabelInformation) { view in
                        view
                            .overlay(
                                Image(.labelInformation)
                                    .offset(x: 22, y: isLabelFolded ? -50 : -100)
                            )
                    }

                    CardView {
                        HStack(spacing: 4) {
                            Text("Frequency")
                            InformationButton {
                                showFrequencyInformation.toggle()
                            }
                            Spacer()
                            LabeledStepper(frequency: $frequency )
                        }
                    }
                    .if(showFrequencyInformation) { view in
                        view
                            .overlay(
                                Image(.frequencyInformation)
                                    .offset(x: 8, y: -50)
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
                }
                let repeatDateInt: [Int] = repeatDate.map { $0.weekday }
                AppButton(label: "Save", sizeType: .submit, isDisabled: !isSavable()) {
                    guard isSavable() else { return }
                    loading.2 = "Saving..."
                    loading.0 = true
                    loading.1 = .loading
                    habitVM.createUserHabit(habitName: habitName, description: description, label: label?.rawValue ?? "", frequency: frequency, repeatHabit: repeatDateInt, reminderHabit: isReminderOn ? reminderTime : nil) {
                        loadingSuccess()
                    }
                    self.presentationMode.wrappedValue.dismiss()
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
        .navigationTitle("Create Habit Form")
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


private extension CreateHabitView {
    func isSavable() -> Bool {
        return isRepeatOn && !repeatDate.isEmpty && !habitName.isEmpty && label != nil
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
        CreateHabitView(habitNotificationId: "0", loading: .constant((false, .success, "")), showAlertView: .constant(false), habitVM: HabitViewModel())
    }
}
