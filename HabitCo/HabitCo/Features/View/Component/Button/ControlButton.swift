//
//  RepeatButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/03/24.
//

import SwiftUI

enum ControlButtonSize: CGFloat {
    case mainControl = 40
    case secondaryControl = 30
}

enum ControlButtonImage: String {
    case play = "play.fill"
    case pause = "pause.fill"
    case backward = "backward.end.fill"
    case forward = "forward.end.fill"
}

struct ControlButton: View {
    var color: Color
    var buttonSize: ControlButtonSize
    var buttonImage: ControlButtonImage
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: buttonImage.rawValue)
                .foregroundColor(.white)
                .font(.system(size: buttonSize.rawValue/2))
        })
        .frame(width: buttonSize.rawValue, height: buttonSize.rawValue)
        .background(color)
        .clipShape(Circle())
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ControlButton(color: .appColor, buttonSize: .mainControl, buttonImage: .play) {
        
    }
}
