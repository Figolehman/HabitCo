//
//  FocusView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 28/03/24.
//

import SwiftUI
import Combine
import AVFoundation

enum PomodoroTime {
    case focusTime, breakTime, longBreakTime
}

struct FocusView: View {
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isRunning = true
    
    @State var promptIndex: Int = Int.random(in: 0...3)
    
    @State var isDone = false
    @State var currentTime: Int
    @State var totalTime: Int
        
    @State var currentPomodoroTime: PomodoroTime = .focusTime
    @State var currentSession: Int
    
    @StateObject private var userViewModel = UserViewModel()
    
    let pomodoro: PomodoroDB?
    let subJournal: SubJournalDB?
    let date: Date
    let minute = 60
    
    init(pomodoro: PomodoroDB?, subJournal: SubJournalDB?, date: Date) {
        self.pomodoro = pomodoro
        self.subJournal = subJournal
        self.date = date

        _currentSession = State(initialValue: subJournal?.startFrequency ?? 0)
        _currentTime = State(initialValue: pomodoro!.focusTime! * minute)
        _totalTime = State(initialValue: pomodoro!.focusTime! * minute)
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 40) {
                VStack (spacing: 24) {
                    PomodoroTimer(timer: $timer, totalTime: $totalTime, isRunning: $isRunning, duration: $currentTime, isDone: $isDone) {
                        if currentSession < pomodoro?.session ?? 0 {
                            if currentPomodoroTime != .focusTime {
                                currentPomodoroTime = getNextPomodoroTime(time: currentPomodoroTime, currentSession: currentSession)
                                currentSession = currentSession + 1
                                currentTime = getCurrentPomodoroDuration(currentPomodoroTime)
                                totalTime = currentTime
                                userViewModel.updateCountSubJournal(subJournalId: subJournal?.id ?? "", from: Date().formattedDate(to: .fullMonthName))
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
                            Text("\(currentSession)")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .focusTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Focus Time")
                            Spacer()
                            Text("\(pomodoro?.focusTime ?? 0) Minutes")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .breakTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Break Time")
                            Spacer()
                            Text("\(pomodoro?.breakTime ?? 0) Minutes")
                        }
                    }
                    
                    CardView (height: .getResponsiveHeight(70), color: currentPomodoroTime == .longBreakTime ? .getAppColor(.primary3) : .getAppColor(.neutral3)) {
                        HStack {
                            Text("Long Break Time")
                            Spacer()
                            Text("\(pomodoro?.longBreakTime ?? 0) Minutes")
                        }
                    }
                    
                }
            }
        }
        .navigationTitle("\(pomodoro?.pomodoroName ?? "")")
    }
}

// MARK: - Functions
extension FocusView {
    func getCurrentPomodoroDuration(_ time: PomodoroTime) -> Int {
        switch time {
        case .focusTime:
            minute * pomodoro!.focusTime!
        case .breakTime:
            minute * pomodoro!.breakTime!
        case .longBreakTime:
            minute * pomodoro!.longBreakTime!
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
        FocusView(pomodoro: PomodoroDB(pomodoroName: "", description: "", label: "", session: 0, focusTime: 0, breakTime: 0, longBreakTime: 0, repeatPomodoro: [], reminderPomodoro: "", dateCreated: Date()), subJournal: SubJournalDB(id: "", habitPomodoroId: "", subJournalType: .pomodoro, label: "", frequencyCount: 0, startFrequency: 0, fraction: 0.0, isCompleted: false), date: Date())
    }
}
