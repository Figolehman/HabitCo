//
//  PomodoroDetailView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import SwiftUI

struct PomodoroDetailView: View {

    @Binding var loading: (Bool, LoadingType, String)

    @ObservedObject private var pomodoroVM: PomodoroViewModel
    @ObservedObject private var userVM: UserViewModel

    @Environment(\.presentationMode) var presentationMode

    init(loading: Binding<(Bool, LoadingType, String)>, pomodoroVM: PomodoroViewModel, userVM: UserViewModel) {
        self.userVM = userVM
        self.pomodoroVM = pomodoroVM
        self._loading = loading
    }

    var body: some View {
        if let pomodoro = pomodoroVM.pomodoro {
            ScrollView {
                VStack (spacing: 40) {
                    VStack (spacing: 24) {
                        CalendarView(habitId: pomodoro.id ?? "", label: pomodoro.label ?? "", userVM: userVM)

                        CardView {
                            Text("\(pomodoro.description ?? "")")
                        }
                    }

                    VStack (spacing: 24) {
                        CardView {
                            HStack {
                                Text("Label")
                                Spacer()
                                Rectangle()
                                    .cornerRadius(12)
                                    .frame(width: .getResponsiveWidth(124), height: .getResponsiveHeight(46))
                                    .foregroundColor(Color(pomodoro.label ?? ""))
                            }
                        }


                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                Text("\(pomodoro.repeatPomodoro?.getRepeatLabel() ?? "")")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Reminder")
                                Spacer()
                                Text("\(pomodoro.reminderPomodoro ?? "No Reminder")")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Session")
                                Spacer()
                                Text("\(pomodoro.session ?? 0)")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Focus Time")
                                Spacer()
                                Text("\(pomodoro.focusTime ?? 0)")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Break Time")
                                Spacer()
                                Text("\(pomodoro.breakTime ?? 0)")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Long Break Time")
                                Spacer()
                                Text("\(pomodoro.longBreakTime ?? 0)")
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background (
                Color.neutral3
                    .frame(width: ScreenSize.width, height: ScreenSize.height)
                    .ignoresSafeArea()
            )
            .navigationTitle("\(pomodoro.pomodoroName ?? "")")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                pomodoroVM.getPomodoroDetail(pomodoroId: pomodoro.id ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: EditPomodoroView(pomodoroVM: pomodoroVM, loading: $loading) { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    NavigationView {
//        PomodoroDetailView(habit: PomodoroDB(habitName: "Lari Pagi", description: "Mau lari pagi", label: "mushroom", frequency: 0, repeatHabit: [1, 2], reminderHabit: "18:00", dateCreated: Date()))
    }
}
