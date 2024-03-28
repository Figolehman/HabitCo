//
//  FocusView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 28/03/24.
//

import SwiftUI

enum PomodoroTime {
    case focusTime, breakTime, longBreakTime
}

struct FocusView: View {
    
    @State var promptIndex: Int = Int.random(in: 0...3)
    
    @State var isDone = false
    @State var currentTime: Int = 1
    
    let pomodoroTime: (Int, Int, Int) = (1, 1, 1)
    let maxSession = 5
    
    @State var currentPomodoroTime: PomodoroTime = .focusTime
    @State var currentSession: Int = 1
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 40) {
                VStack (spacing: 24) {
                    PomodoroTimer(totalTime: Binding(get: {
                        getCurrentPomodoroDuration(currentPomodoroTime)
                    }, set: { value in
                        
                    }), duration: $currentTime, isDone: $isDone) {
                        if currentPomodoroTime != .focusTime {
                            if currentSession < maxSession {
                                currentPomodoroTime = getNextPomodoroTime(time: currentPomodoroTime, currentSession: currentSession)
                                currentSession = currentSession + 1
                                currentTime = getCurrentPomodoroDuration(currentPomodoroTime)
                            }
                        } else {
                            currentPomodoroTime = getNextPomodoroTime(time: currentPomodoroTime, currentSession: currentSession)
                            currentTime = getCurrentPomodoroDuration(currentPomodoroTime)
                        }
                        promptIndex = Int.random(in: 0...3)
                        isDone = false
                    }
                        .padding(.top, .getResponsiveHeight(36))
                    
                    Text("\(currentPomodoroTime == .focusTime ? Prompt.focusPrompt[promptIndex] : Prompt.breakPrompt[promptIndex])")
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .bottom, spacing: 24) {
                        ControlButton(color: .getAppColor(.primary), buttonSize: .secondaryControl, buttonImage: .backward) {
                            
                        }
                        ControlButton(color: .getAppColor(.primary), buttonSize: .mainControl, buttonImage: .pause) {
                            
                        }
                        ControlButton(color: .getAppColor(.primary), buttonSize: .secondaryControl, buttonImage: .forward) {
                            
                        }
                    }
                }
                
                VStack (spacing: 24) {
                    HStack {
                        AppButton(label: "+5 minute", sizeType: .control) {
                            
                        }
                        AppButton(label: "+10 minute", sizeType: .control) {
                            
                        }
                        AppButton(label: "+15 minute", sizeType: .control) {
                            
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
}

#Preview {
    NavigationView {
        FocusView()
    }
}
