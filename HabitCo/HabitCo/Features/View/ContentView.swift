//
//  ContentView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var selectedDate = Date()
    
    @State private var isRepeatOn = false
    
    @State private var isRepeatFolded = true
    
    @State private var repeatDate: Set<RepeatDay> = []
    
    var repeatWeekdays: [Int] {
        get {
            let weekdays = repeatDate.map {
                $0.weekday
            }
            return weekdays
        }
    }
    //    @AppStorage("notificationTimeString") var notificationTimeString = ""
    //    @AppStorage("currentProgress") var currentProgress: Int = 3
    
    let notify = NotificationHandler()
    
    var body: some View {
        VStack {
            CardView {
                VStack (spacing: 12) {
                    HStack {
                        Text("Repeat")
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
                        Spacer()
                        Button("Replace"){
                            notify.replaceNotification(withIdentifier: "journal")
                        }
                        
                        DatePicker("Notification Time", selection: Binding(get: {
                            Date()
                        }, set: { date in
                            notify.askPermission()
                            notify.sendNotification(date: date, weekdays: repeatWeekdays, title: "tes", body: "tes", withIdentifier: "journal")
                        }), displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        Button("notify 5 seconds after") {
                            //                notify.sendNotification(date: Date(), type: "time", timeInterval: 5, title: "TEST", body: "your current progress is")
                        }
                        Spacer()
                        Button("Request permission") {
                            notify.askPermission()
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
