//
//  FocusView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 28/03/24.
//

import SwiftUI
import AVFoundation

enum PomodoroTime {
    case focusTime, breakTime, longBreakTime
}

struct FocusView: View {

    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isRunning = true
    
    @State var promptIndex: Int = Int.random(in: 0...3)
    
    @State var isDone = false
    @State var currentTime: Int = 3
    @State var totalTime: Int = 3
    
    let pomodoroTime: (Int, Int, Int) = (1, 1, 1)
    let maxSession = 5
    
    @State var currentPomodoroTime: PomodoroTime = .focusTime
    @State var currentSession: Int = 1
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 40) {
                VStack (spacing: 24) {
                    PomodoroTimer(timer: $timer, totalTime: $totalTime, isRunning: $isRunning, duration: $currentTime, isDone: $isDone) {
                        if currentSession < maxSession {
                            if currentPomodoroTime != .focusTime {
                                currentPomodoroTime = getNextPomodoroTime(time: currentPomodoroTime, currentSession: currentSession)
                                currentSession = currentSession + 1
                                currentTime = getCurrentPomodoroDuration(currentPomodoroTime)
                                totalTime = currentTime
                            } else {
                                currentPomodoroTime = getNextPomodoroTime(time: currentPomodoroTime, currentSession: currentSession)
                                currentTime = getCurrentPomodoroDuration(currentPomodoroTime)
                                totalTime = currentTime
                            }
                            
                            promptIndex = Int.random(in: 0...3)
                            isDone = false
                        }
                    }
                        .padding(.top, .getResponsiveHeight(36))
                    
                    Text("\(currentPomodoroTime == .focusTime ? Prompt.focusPrompt[promptIndex] : Prompt.breakPrompt[promptIndex])")
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .bottom, spacing: 24) {
                        ControlButton(color: .getAppColor(.primary), buttonSize: .secondaryControl, buttonImage: .backward) {
                            currentTime = totalTime
                        }
                        ControlButton(color: .getAppColor(.primary), buttonSize: .mainControl, buttonImage: isRunning ? .pause : .play) {
                            if isRunning {
                                timer.upstream.connect().cancel()
                                isRunning = false
                            } else {
                                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                                isRunning = true
                            }
                        }
                        ControlButton(color: .getAppColor(.primary), buttonSize: .secondaryControl, buttonImage: .forward) {
                            currentTime = 0
                        }
                    }
                }
                
                VStack (spacing: 24) {
                    HStack {
                        AppButton(label: "+5 minute", sizeType: .control) {
                            addTimer(300)
                        }
                        AppButton(label: "+10 minute", sizeType: .control) {
                            addTimer(600)
                        }
                        AppButton(label: "+15 minute", sizeType: .control) {
                            addTimer(900)
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70)) {
                        HStack {
                            Text("Session")
                            Spacer()
                            Text("\(maxSession)")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .focusTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Focus Time")
                            Spacer()
                            Text("\(pomodoroTime.0) Minutes")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .breakTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Break Time")
                            Spacer()
                            Text("\(pomodoroTime.1) Minutes")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .longBreakTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Long Break Time")
                            Spacer()
                            Text("\(pomodoroTime.2) Minutes")
                        }
                    }
                    
                }
            }
        }
        .navigationTitle("Habit Name")
    }
}

// MARK: - Functions
extension FocusView {
    func getCurrentPomodoroDuration(_ time: PomodoroTime) -> Int {
        switch time {
        case .focusTime:
            pomodoroTime.0 * 3
        case .breakTime:
            pomodoroTime.1 * 3
        case .longBreakTime:
            pomodoroTime.2 * 5
        }
    }
    
    func getNextPomodoroTime(time: PomodoroTime, currentSession: Int) -> PomodoroTime {
        if currentSession % 4 == 0 {
            switch time {
            case .focusTime:
                return .longBreakTime
            case .breakTime:
                return .breakTime
            case .longBreakTime:
                return .focusTime
            }
        } else {
            switch time {
            case .focusTime:
                return .breakTime
            case .breakTime:
                return .focusTime
            case .longBreakTime:
                return .longBreakTime
            }
        }
    }
    
    func addTimer(_ time: Int) {
        currentTime = currentTime + time
        if totalTime < currentTime {
            totalTime = currentTime
        }
    }
}

#Preview {
    NavigationView {
        FocusView()
    }
}
