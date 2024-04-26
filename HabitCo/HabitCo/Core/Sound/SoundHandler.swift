//
//  SoundHandler.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/04/24.
//

import Foundation
import AVFoundation
import SwiftUI

enum SoundContent {
    case endPomodoro
}

class SoundHandler {
    var endPomodoroID: SystemSoundID = 1000
    
    init() {
//        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: Bundle.main.path(forResource: "endPomodoro", ofType: "mp3")!), &endPomodoroID)
    }
    
    func playSound(_ sound: SoundContent) {
        var soundID: SystemSoundID?
        switch sound {
        case .endPomodoro:
            soundID = endPomodoroID
        }
        
        AudioServicesPlaySystemSound(soundID ?? 1)
    }
}

struct SoundTestView: View {
    let soundHandler = SoundHandler()
    
    var body: some View {
        Button("test") {
            AudioServicesPlaySystemSound(1016)
        }
    }
}

#Preview {
    SoundTestView()
}
