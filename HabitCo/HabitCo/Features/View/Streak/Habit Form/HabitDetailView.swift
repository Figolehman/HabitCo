//
//  SwiftUIView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import SwiftUI

struct HabitDetailView: View {
    
    let habit: HabitDB?
        
    init(habit: HabitDB?) {
        self.habit = habit
    }
    
    var body: some View {
        ScrollView {
            VStack (spacing: 40) {
                VStack (spacing: 24) {
                    CalendarView(habitId: habit?.id ?? "")
                    
                    CardView {
                        Text("\(habit?.description ?? "")")
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
                                .foregroundColor(Color(habit?.label ?? ""))
                        }
                    }
                    
                    CardView(height: .getResponsiveHeight(70)) {
                        HStack {
                            Text("Frequency")
                            Spacer()
                            Text("\(habit?.frequency ?? 0)")
                        }
                    }
                    CardView(height: .getResponsiveHeight(70)) {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text("\(habit?.repeatHabit?.getRepeatLabel() ?? "")")
                        }
                    }
                    CardView(height: .getResponsiveHeight(70)) {
                        HStack {
                            Text("Reminder")
                            Spacer()
                            Text("\(habit?.reminderHabit ?? "")")
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("\(habit?.habitName ?? "")")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: EditHabitView(habit: habit!)) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HabitDetailView(habit: HabitDB(habitName: "Lari Pagi", description: "Mau lari pagi", label: "mushroom", frequency: 0, repeatHabit: [1, 2], reminderHabit: "18:00", dateCreated: Date()))
    }
}
