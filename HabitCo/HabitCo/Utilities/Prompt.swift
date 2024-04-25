//
//  Prompt.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import Foundation

struct Prompt {
    static let appName = "HabitCo"
    
    static let focusPrompt = ["Don’t stop until you’re proud!", "Work hard in silence. Let success make the noise.", "The goal is not simply to get more done, but also to have less to do.", "Great things never come from comfort zones."]
    
    static let breakPrompt = ["Take a break, recharge, and come back stronger!", "You've been putting in the effort, now you deserve a well-earned break.", "Remember, breaks are essential for recharging your mind.", "Use this break as an opportunity to pursue activities that inspire and energize you."]
    
    static let gainStreakPrompt = ["Your persistence and determination are truly inspiring. You're one step closer to achieving your goals. Don't forget to share your achievement with your friends!", "Your determination to succeed is both admirable and inspiring. Keep going!  Don't forget to share your achievement with your friends!"]
    
    static let lossStreakPrompt = ["Don't be discouraged! Every setback is a chance to start anew. Losing your streak is just a small setback in your journey. Keep your spirits up!"]
    
    static func shareStreakPrompt(streak: Int, x: Int?, y: Int?) -> String {
        guard let x, let y else { return "I'm thrilled to share that I've successfully maintained my streak for \(streak) consecutive days."}
        
        return "I'm super proud to share that I've successfully completed \(x) out of \(y) habit for the past \(streak) days, without a break!"
    }
}
