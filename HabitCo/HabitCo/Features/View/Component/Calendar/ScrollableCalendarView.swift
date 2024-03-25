//
//  WeeklyView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//


import SwiftUI

struct ScrollableCalendarView: View {
    let currentDate = Date()
    var hasHabit: [Date] = []
    let spacing: CGFloat = 12
    
    @State var days: [Date] = []
    @State var selectedDate: Date
    
    @State var scrollOffset: CGPoint = .zero
    @State var startOffset: CGPoint = .zero
    
    @State var lastItem: Date
    
    init(hasHabit: [Date]) {
        let lastDate = Calendar.current.date(byAdding: .year, value: 1, to: currentDate)!
        self.hasHabit = hasHabit
        self._days = State(initialValue: Date.getDatesInRange(of: Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!, to: lastDate))
        
        //        self._days = State(initialValue: Date.getDatesInRange(of: currentDate, to: Calendar.current.date(byAdding: .day, value: 8, to: currentDate)!))
        
        self._selectedDate = State(initialValue: currentDate)
        
        self._lastItem = State(initialValue: lastDate)
    }
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                LazyHStack (alignment: .center) {
                    ForEach(days, id: \.self) { day in
                        if day != selectedDate {
                            notSelectedDate(day: day)
                                .foregroundColor(.getAppColor(.neutral))
                                .onTapGesture {
                                    selectedDate = day
                                }
                                .onAppear {
                                    if day == days.last {
                                        days.append(contentsOf: Date.getDatesInRange(of: Calendar.current.date(byAdding: .day, value: 1, to: days.last!)!, to: Calendar.current.date(byAdding: .year, value: 1, to: days.last!)!))
                                    }
                                }
                        } else {
                            selectedDate(day: day)
                        }
                    }
                }
                .onAppear {
                    value.scrollTo(currentDate, anchor: .center)
                }
            }
            
        }
        .frame(height: 80)
        
        
        
    }
}

// MARK: - View Builder
extension ScrollableCalendarView {
    
    // Frame ga selected (ga ijo)
    @ViewBuilder
    func notSelectedDate(day: Date) -> some View {
        VStack (spacing: 0) {
            Text(day.getDayName)
                .frame(maxWidth: .infinity)
                .font(day.isSameDay(currentDate) ? .footnote.weight(.heavy) : .footnote.weight(.semibold))
                .foregroundColor(Color(.tertiaryLabel))
            
            Spacer()
                .frame(height: spacing)
            
            
            ZStack {
                Text("\(day.get(.day))")
                    .frame(maxWidth: .infinity)
                    .font(day.isSameDay(currentDate) ? .title3.weight(.heavy) : .title3)
                
                if hasHabit.contains(day) {
                    Circle()
                        .frame(width: 6, height: 6)
                        .offset(y: 16)
                }
            }
            
            
        }
        .frame(width: .getResponsiveWidth(42), height: .getResponsiveHeight(80))
        .cornerRadius(12)
    }
    
    // Frame ijo
    @ViewBuilder
    func selectedDate(day: Date) -> some View {
        VStack (spacing: spacing) {
            Text(day.getDayName)
                .frame(maxWidth: .infinity)
                .font(.footnote.weight(.semibold))
            //                        .foregroundColor(Color(.tertiaryLabel))
            
            Text("\(day.get(.day))")
                .frame(maxWidth: .infinity)
                .font(.title3.weight(.semibold))
        }
        .frame(width: .getResponsiveWidth(50), height: .getResponsiveHeight(80))
        .background(Color.getAppColor(.primary))
        .cornerRadius(12)
        .foregroundColor(.neutral3)
    }
}

#Preview {
    ScrollableCalendarView(hasHabit: [Date()])
}

#Preview {
    JournalView()
}
