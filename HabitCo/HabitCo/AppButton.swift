//
//  AppButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 13/03/24.
//

import SwiftUI

enum AppButtonSize{
    case submit
    case share
    case select
    case control
    
    var width: CGFloat {
        get {
            switch self {
            case .submit:
                return 345
            case .share:
                return 310
            case .select:
                return 124
            case .control:
                return .nan
            }
            
        }
    }
    
    var height: CGFloat {
        get {
            switch self {
            case .submit:
                return 48
            case .share:
                return 48
            case .select:
                return 46
            case .control:
                return 38
            }
        }
    }
}

struct AppButton: View {
    var color: Color
    var label: String
    var sizeType: AppButtonSize
    var action: () -> ()

    var body: some View {
        Button (action: {
            action()
        }, label: {
            Text(label)
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        })
        .padding(12)
        .frame(width: sizeType.width, height: sizeType.height)
        .background(color)
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 12, x: 0, y: 10)
    }
}

#Preview {
    AppButton(color: .appColor, label: "Logout", sizeType: .control) {}
}
