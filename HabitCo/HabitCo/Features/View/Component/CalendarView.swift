//
//  Calendar.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import SwiftUI

struct CalendarView: View {
    let dummyDays = 1..<32
    
    @State var currentDate = Date()
    @State var days = [Date]()
    
    var currentMonth: Int {
        get {
            currentDate.get(.month)
        }
    }
    var currentYear: Int {
        get {
            currentDate.get(.year)
        }
    }
    
    init() {
        self._days = State(initialValue: currentDate.calendarDisplayDate)
    }
    
    
    var body: some View {
        Group {
            VStack {
                HStack {
                    Text("\(getMonthName(currentMonth)) " + String(currentYear))
                        .font(.body)
                    
                    Spacer()
                    
                    Button {
                        currentDate = currentDate.startOfPreviousMonth
                        
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Button {
                        currentDate = currentDate.startOfNextMonth
                        
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                    }


                }
                .padding(.vertical, 7)
                
                HStack {
                    let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                let emptyDays = currentDate.startOfMonth.get(.weekday) - 1

                LazyVGrid(columns: columns, spacing: 20, content: {
                    ForEach((-10..<emptyDays-10), id: \.self) { i in
                        Text("")
                    }
                    ForEach(days, id: \.self) { day in
                        Text("\(day.get(.day))")
                            .font(.title3)
                            .modifier(DateMarking(0.6))
                    }
                })
            }
            .padding()
        }
        .onChange(of: currentDate, perform: { _ in
            days = currentDate.calendarDisplayDate
        })
        .background(Color.white)
        .cornerRadius(13)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Functions
extension CalendarView {
    
    func getMonthName(_ month: Int) -> String {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "Month"
        }
    }
}

// MARK: - Date Marking
struct DateMarking: ViewModifier {
    let fraction: CGFloat
    let midPoint: CGFloat = 0.5
    let startPoint: CGFloat
    let endPoint: CGFloat
    
    init(_ fraction: CGFloat = 1) {
        self.fraction = fraction
        
        // Calculate start and end point
        let halfFraction = fraction/2
        self.startPoint = midPoint - halfFraction
        self.endPoint = midPoint + halfFraction
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .trim(from: startPoint, to: endPoint)
                    .rotation(.degrees(-90))
                    .foregroundColor(Color(red: 0.58, green: 0.89, blue: 0.99))
                    .frame(width: 35, height: 35)
            )
    }
}

#Preview {
    CalendarView()
}
