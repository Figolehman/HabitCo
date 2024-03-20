//
//  PomodoroTimer.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

struct PomodoroTimer: View {
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let width: CGFloat = 270
    let height: CGFloat = 270
    
    @State var totalTime = 10
    
    @State var isRunning = true
    
    @State var duration: Int = 10
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: width, height: height)
                
                Circle()
                    .stroke(Color(UIColor.systemGray3), lineWidth: 15)
                    .frame(width: width, height: height)
                
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(1 - Double(duration) / Double(totalTime)))
                    .stroke(Color(UIColor.systemGray), lineWidth: 15)
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(-90))
                
                
                Text("\(formatTime(duration))")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .onReceive(timer) { _ in
                        if duration > 0 {
                            duration = duration - 1
                        }
                    }
                
            }
            
            AppButton(label: "+50 Second", sizeType: .control) {
                duration = duration + 50
                
                if duration > totalTime {
                    totalTime = duration
                }
            }
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
    
    mutating func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        isRunning = true
    }
    
    func pauseTimer() {
        self.timer.upstream.connect().cancel()
        isRunning = false
    }
    
    func addTimer() {
        // add berapa detik
    }
}

#Preview {
    PomodoroTimer()
}
