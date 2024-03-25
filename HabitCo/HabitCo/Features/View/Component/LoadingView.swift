//
//  LoadingView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 24/03/24.
//

import SwiftUI

enum LoadingType {
    case loading
    case success
    case error
    
    var view: String {
        get {
            switch self {
            case .error:
                return "xmark.circle"
            case .success:
                return "checkmark.circle"
            default:
                return ""
            }
        }
    }
}

struct LoadingView: View {
    var loadingType: LoadingType
    var message: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(8)
                .frame(width: 156, height: 158)
                .foregroundColor(.getAppColor(.neutral3).opacity(0.8))
                .overlay (
                    VStack {
                        if loadingType != .loading {
                            Text(message)
                        } else {
                            Spacer()
                            HStack {
                                ProgressView()
                                    .scaleEffect(3, anchor: .center)
                            }
                            Spacer(minLength: 23)
                            Text("\(message)")
                        }
                    }
                        .padding(.vertical, 18)
                        
                )
            
            
        }
    }
}

extension LoadingView {
    mutating func changeLoadingStatus (message: String, type: LoadingType) {
        changeLoadingType(type)
        changeLoadingMessage(message)
    }
    
    mutating func changeLoadingMessage(_ message: String) {
        self.message = message
    }
    
    mutating func changeLoadingType(_ type: LoadingType) {
        self.loadingType = type
    }
}

#Preview {
    EmptyView()
        .alertOverlay(.constant(true)) {
            LoadingView(loadingType: .loading, message: "Saving..")
        }
}
