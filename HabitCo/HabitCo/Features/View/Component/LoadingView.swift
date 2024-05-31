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
    @Binding var loadingType: LoadingType
    @Binding var message: String

    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(8)
                .frame(width: 156, height: 158)
                .foregroundColor(.getAppColor(.neutral3).opacity(0.8))
                .overlay (
                    VStack {
                        if loadingType != .loading {
                            Spacer()
                            Image(systemName: loadingType.view)
                                .foregroundColor(loadingType == .success ? .getAppColor(.primary) : .getAppColor(.danger))
                                .font(.system(size: 68, weight: .light))
                            Spacer(minLength: .getResponsiveHeight(15))
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

#Preview {
    EmptyView()
        .alertOverlay(.constant(true)) {
            LoadingView(loadingType: .constant(.error), message: .constant("Saving..."))
        }
}
