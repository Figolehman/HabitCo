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
    case undo
    
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
            case .undo:
                return 116
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
            case .undo:
                return 80
            }
        }
    }
    
    var color: Color {
        get {
            switch self {
            case .submit:
                return .getAppColor(.primary)
            case .share:
                return .getAppColor(.primary)
            case .select:
                return .getAppColor(.primary)
            case .control:
                return .getAppColor(.primary)
            case .undo:
                return .gray
            }
        }
    }
}

struct AppButton: View {
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
        .background(sizeType.color)
        .cornerRadius(12)
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), radius: 12, x: 0, y: 10)
    }
}

#Preview {
    AppButton(label: "+5 minute", sizeType: .share) {}
}
