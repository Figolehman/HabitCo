//
//  SwiftUIView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import SwiftUI

struct HabitDetailView: View {

    @State private var showNavigationToEdit = true

    @Binding var loading: (Bool, LoadingType, String)
    @Binding var showBackAlert: Bool

    @ObservedObject private var habitVM: HabitViewModel

    @Environment(\.presentationMode) var presentationMode

    init(loading: Binding<(Bool, LoadingType, String)>, showBackAlert: Binding<Bool>, habitVM: HabitViewModel) {
        self._showBackAlert = showBackAlert
        self.habitVM = habitVM
        self._loading = loading
    }
    
    var body: some View {
        if let habit = habitVM.habit {
            ScrollView {
                VStack (spacing: 40) {
                    VStack (spacing: 24) {
                        CalendarView(habitId: habit.id ?? "", label: habit.label ?? "", habitVM: habitVM)

                        CardView {
                            Text("\(habit.description ?? "")")
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
                                    .foregroundColor(Color(habit.label ?? ""))
                            }
                        }

                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Frequency")
                                Spacer()
                                Text("\(habit.frequency ?? 0)")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                Text("\(habit.repeatHabit?.getRepeatLabel() ?? "")")
                            }
                        }
                        CardView(height: .getResponsiveHeight(70)) {
                            HStack {
                                Text("Reminder")
                                Spacer()
                                Text("\(habit.reminderHabit ?? "No Reminder")")
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
            .navigationTitle("\(habit.habitName ?? "")")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if showNavigationToEdit {
                        NavigationLink(destination: EditHabitView(habitVM: habitVM, loading: $loading, showBackAlert: $showBackAlert) { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .onAppear {
                BackButtonActionAlert.shared.backAction = {
                    withAnimation {
                        showBackAlert = false
                        showNavigationToEdit = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showNavigationToEdit = true
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
//        HabitDetailView(habit: HabitDB(habitName: "Lari Pagi", description: "Mau lari pagi", label: "mushroom", frequency: 0, repeatHabit: [1, 2], reminderHabit: "18:00", dateCreated: Date()))
    }
}
