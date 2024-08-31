//
//  EditHabitView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 28/03/24.
//

import SwiftUI

struct EditHabitView: View {

    let habit: HabitDB

    @State private var showLabelInformation = false
    @State private var showFrequencyInformation = false
    @State private var showRepeatInformation = false
    @State private var showReminderInformation = false

    @Binding var loading: (Bool, LoadingType, String)

    @State private var selected: Color.FilterColors?
    @State private var frequency: Int

    @State private var isRepeatOn = true
    @State private var isReminderOn = false

    @State private var isRepeatFolded = false
    @State private var isReminderFolded = false
    @State private var isLabelFolded = false

    @State var showAlert = false
    @Binding var showBackAlert: Bool

    @State private var repeatDate: Set<RepeatDay> = []
    @State private var reminderTime: Date = Date()


    @State var habitName: String
    @State var description: String

    let onDelete: () -> Void

    @ObservedObject private var habitVM: HabitViewModel

    @Environment(\.presentationMode) var presentationMode

    init(habitVM: HabitViewModel, loading: Binding<(Bool, LoadingType, String)>, showBackAlert: Binding<Bool>, onDelete: @escaping () -> Void = {}) {
        self._showBackAlert = showBackAlert
        self.onDelete = onDelete
        self._loading = loading
        self.habit = habitVM.habit!
        self.habitVM = habitVM
        _habitName = State(initialValue: habit.habitName!)
        _description = State(initialValue: habit.description!)

        for color in Color.FilterColors.allCases {
            if habit.label == color.rawValue {
                _selected = State(initialValue: color)
            }
        }

        _frequency = State(initialValue: habit.frequency!)
        _isReminderOn = State(initialValue: habit.reminderHabit != "No Reminder")
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
                    .if(showLabelInformation) { view in
                        view
                            .overlay(
                                Image(.labelInformation)
                                    .offset(x: 22, y: isLabelFolded ? -50 : -100)
                            )
                    }

                    CardView {
                        HStack (spacing: 4) {
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
                let repeatHabit = repeatDate.map { $0.weekday }
                AppButton(label: "Save", sizeType: .submit) {
                    loading.2 = "Saving..."
                    loading.0 = true
                    habitVM.editHabit(habitId: habit.id ?? "", habitName: habitName, description: description, label: selected?.rawValue ?? "", frequency: frequency, repeatHabit: repeatHabit != [] ? repeatHabit : habit.repeatHabit, reminderHabit: isReminderOn ? reminderTime : nil) {
                        loadingSuccess(type: .save)
                    }
                    if isReminderOn {
                        // update notif
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
        .alertOverlay($showAlert, content: {
            CustomAlertView(title: "Are you sure you want to Delete this habit?", message: "Any progress and data linked to this will be lost permanently, and you wont be able to recover it.", dismiss: "Cancel", destruct: "Delete", dismissAction: {
                showAlert = false
            }, destructAction: {
                showAlert = false
                loading.2 = "Deleting..."
                loading.0 = true
                habitVM.deleteHabit(habitId: habit.id ?? "") {
                    loadingSuccess(type: .delete)
                }
            })
        })
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Edit Habit Form")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton {
                  showBackAlert = true
                }
            }
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
            for habitDay in habit.repeatHabit! {
                for day in RepeatDay.allCases {
                    if day.weekday == habitDay {
                        repeatDate.insert(day)
                    }
                }
            }
        }
        .navigationTitle("Edit Habit Form")
        .navigationBarTitleDisplayMode(.large)
    }
}

fileprivate enum QueryType {
    case delete, save
}

private extension EditHabitView {
    func loadingSuccess(type: QueryType) {
        switch type {
        case .delete:
            loading.2 = "Deleted"
        case .save:
            loading.2 = "Saved"
        }
        loading.1 = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loading.0 = false
            loading.1 = .loading
            self.presentationMode.wrappedValue.dismiss()
            if type == .delete {
                onDelete()
            }
        }
    }
}
