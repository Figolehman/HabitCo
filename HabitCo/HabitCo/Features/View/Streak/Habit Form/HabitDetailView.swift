//
//  SwiftUIView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import SwiftUI

struct HabitDetailView: View {
    
    @ObservedObject private var habitVM: HabitViewModel

    init(habitVM: HabitViewModel) {
        self.habitVM = habitVM
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
                    NavigationLink(destination: EditHabitView(habitVM: habitVM)) {
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
//        HabitDetailView(habit: HabitDB(habitName: "Lari Pagi", description: "Mau lari pagi", label: "mushroom", frequency: 0, repeatHabit: [1, 2], reminderHabit: "18:00", dateCreated: Date()))
    }
}
