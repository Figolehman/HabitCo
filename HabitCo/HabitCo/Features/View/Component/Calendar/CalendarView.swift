//
//  Calendar.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//


import SwiftUI

struct CalendarView: View {
    let today = Date()
    let dummyDays = 1..<32

    @State var currentDate = Date()
    @State var days = [Date]()
    @State var selectedDate: Int?
    
    @ObservedObject private var userVM: UserViewModel

    let habitId: String
    let label: String

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

    init(habitId: String, label: String, userVM: UserViewModel) {
        self.habitId = habitId
        self.userVM = userVM
        self.label = label
        
        self._days = State(initialValue: currentDate.calendarDisplayDate)
    }

    var body: some View {

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
                }

                Button {
                    currentDate = currentDate.startOfNextMonth

                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                }


            }
            .padding(.vertical, 7)

            HStack {
                ForEach(DateName.allCases, id: \.self) { day in
                    Text(day.rawValue)
                        .frame(maxWidth: .infinity)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            calendarView(fractionForDate: userVM.progress ?? [:], label: label)
        }
        .onAppear{
            userVM.getProgressHabit(habitPomodoroId: habitId, date: currentDate)
        }
        .padding()
        .onChange(of: currentDate, perform: { _ in
            days = currentDate.calendarDisplayDate
            userVM.getProgressHabit(habitPomodoroId: habitId, date: days.first?.formattedDate(to: .fullMonthName) ?? Date() )
        })
        .background(Color.white)
        .cornerRadius(13)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - View Builder
extension CalendarView {
    @ViewBuilder
    func calendarView(fractionForDate: [Date: CGFloat], label: String) -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        let emptyDays = currentDate.startOfMonth.get(.weekday) - 1

        LazyVGrid(columns: columns, spacing: 20, content: {
            ForEach((-10..<emptyDays-10), id: \.self) { i in
                Text("")
            }
            ForEach(days, id: \.self) { day in
                let dayDate = day.get(.day)
                Text("\(dayDate)")
                    .if(day.isSameDay(today), transform: { text in
                        text.font(.title3.bold())
                    })
                    .font(.title3)
                    .modifier(DateMarking(fraction: fractionForDate[day] ?? 0, isSelected: selectedDate == dayDate, label: label))
                    .onTapGesture {
                        selectedDate = dayDate
                    }
            }
        })
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

    let size: CGFloat = 40

    let fraction: CGFloat
    let midPoint: CGFloat = 0.5
    let startPoint: CGFloat
    let endPoint: CGFloat
    let isSelected: Bool
    let label: String

    init(fraction: CGFloat = 1, isSelected: Bool, label: String) {
        self.fraction = fraction
        self.label = label
        // Calculate start and end point
        let halfFraction = fraction/2
        self.startPoint = midPoint - halfFraction
        self.endPoint = midPoint + halfFraction

        self.isSelected = isSelected
    }

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Circle()
                        .trim(from: startPoint, to: endPoint)
                        .rotation(.degrees(-90))
                        .foregroundColor(Color(label))
                        .frame(width: size, height: size)

                    if isSelected {
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                            .frame(width: size, height: size)
                    }
                }
            )
    }
}
//
//#Preview {
//    CalendarView(habitId: "")
//}
