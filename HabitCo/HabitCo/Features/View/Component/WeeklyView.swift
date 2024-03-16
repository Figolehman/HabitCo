//
//  WeeklyView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

struct WeeklyView: View {
    let currentDate = Date()
    var days: [Date] = []
    let hasHabit: [Int]
    let spacing: CGFloat = 12
    
    init(hasHabit: [Int]) {
        self.hasHabit = hasHabit
        days = currentDate.weeklyDisplayDate
    }
    
    var body: some View {
        HStack (alignment: .center) {
            ForEach((0..<7), id: \.self) { index in
                if days[index] != currentDate {
                    notTodayView(index: index)
                } else {
                    todayView(index: index)
                }
            }
        }
    }
}

// MARK: - View Builder
extension WeeklyView {
    @ViewBuilder
    func notTodayView(index: Int) -> some View {
        VStack (spacing: 0) {
            Text("\(Date.nameOfDays[index])")
                .frame(maxWidth: .infinity)
                .font(.footnote.weight(.semibold))
                .foregroundColor(Color(.tertiaryLabel))
            
            Spacer()
                .frame(height: spacing)
            
            
            ZStack {
                Text("\(days[index].get(.day))")
                    .frame(maxWidth: .infinity)
                .font(.title3)
                
                if hasHabit.contains(days[index].get(.day)) {
                    Circle()
                        .frame(width: 6, height: 6)
                        .offset(y: 16)
                }
            }
            
            
        }
        .frame(width: 50, height: 80)
//        .background(Color.yellow)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    func todayView(index: Int) -> some View {
        VStack (spacing: spacing) {
            Text("\(Date.nameOfDays[index])")
                .frame(maxWidth: .infinity)
                .font(.footnote.weight(.semibold))
//                        .foregroundColor(Color(.tertiaryLabel))
            
            Text("\(days[index].get(.day))")
                .frame(maxWidth: .infinity)
                .font(.title3)
        }
        .frame(width: 50, height: 80)
        .background(Color.black)
        .cornerRadius(12)
        .foregroundColor(.white)
    }
}

#Preview {
    WeeklyView(hasHabit: [Calendar.current.date(byAdding: .day, value: -1, to: Date())!.get(.day)])
}
