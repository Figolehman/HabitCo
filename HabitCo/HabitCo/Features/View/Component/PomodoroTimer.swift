//
//  PomodoroTimer.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI
import Combine

struct PomodoroTimer: View {
    var soundPlayer = SoundHandler()
    
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let width: CGFloat = 270
    let height: CGFloat = 270
    
    
    @Binding var totalTime: Int
    
    @Binding var isRunning: Bool
    
    @Binding var duration: Int
    
    @Binding var isDone: Bool

    let action: () -> ()
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.getAppColor(.primary))
                    .frame(width: width, height: height)
                
                Circle()
                    .stroke(Color.getAppColor(.primary2), lineWidth: 15)
                    .frame(width: width, height: height)
                
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(1 - Double(duration) / Double(totalTime)))
                    .stroke(Color.getAppColor(.neutral), lineWidth: 15)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(-90))
                
                
                Text("\(formatTime(duration))")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .onReceive(timer) { _ in
                        if duration > 0 {
                            duration = duration - 1
                        } else if duration == 0 && !isDone{
                            isDone = true
                            action()
                            if duration == 0 {
                                soundPlayer.playSound(.endPomodoro)
                            }
                        }
                    }
                
            }
//            
//            AppButton(label: "+50 Second", sizeType: .control) {
//                duration = duration + 50
//                
//                if duration > totalTime {
//                    totalTime = duration
//                }
//            }
        }
    }
}


// MARK: - Function
extension PomodoroTimer {
    func formatTime(_ duration: Int) -> String {
        let minute = duration / 60
        let second = (duration - minute * 60)
        
        return (minute < 10 ? "0\(minute)" : "\(minute)") + " : " + (second < 10 ? "0\(second)" : "\(second)")
    }
    
    func addTimer(_ time: Int) {
        // add berapa detik
        duration = duration + time
        isDone = false
        
        if duration > totalTime {
            totalTime = duration
        }
    }
}

//#Preview {
////    PomodoroTimer() {
////        
////    }
//}
