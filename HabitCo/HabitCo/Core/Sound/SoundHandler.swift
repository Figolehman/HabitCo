//
//  SoundHandler.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/04/24.
//

import Foundation
import AVFoundation

enum SoundContent {
    case endPomodoro
}

class SoundHandler {
    var endPomodoroID: SystemSoundID = 1
    
    init() {
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: Bundle.main.path(forResource: "endPomodoro", ofType: "mp3")!), &endPomodoroID)
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
