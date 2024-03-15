//
//  ContentView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI

struct ContentView: View {
    @State var pomodoroView = PomodoroTimer()
    @State var mark = true
    var body: some View {
        CalendarView()
//        VStack {
//            pomodoroView
//            AppButton(color: .appColor, label: "Pause/Resume", sizeType: .submit) {
//                if !mark {
//                    pomodoroView.startTimer()
//                    print("Starting")
//                    mark.toggle()
//                } else {
//                    pomodoroView.pauseTimer()
//                    print("Pausing")
//                    mark.toggle()
//                }
//            }
//        }
//        .padding()
    }
}

#Preview {
    ContentView()
}
