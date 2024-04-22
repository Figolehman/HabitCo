//
//  CustomSheetView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 01/04/24.
//

import SwiftUI

// 738 Setting
// 373 Filter
// 757

enum SheetType {
    case settings
    case filters
    case rules
    
    var height: CGFloat {
        get {
            switch self {
            case .settings:
                return 738
            case .filters:
                return 373
            case .rules:
                return 757
            }
        }
    }
    
    var title: String? {
        get {
            switch self {
            case .settings:
                return "Settings"
            case .filters:
                return "Filter"
            case .rules:
                return nil
            }
        }
    }
    
    var closeLabel: String {
        get {
            switch self {
            case .filters:
                return "Cancel"
            default:
                return "Back"
            }
        }
    }
}

struct CustomSheetView<Content: View>: View {
    
    @Binding var condition: Bool
    
    var sheetType: SheetType
    
    var content: () -> Content
    
    var body: some View {
        VStack{
            Spacer()
            VStack (spacing: 14) {
                Capsule()
                    .fill(.gray).frame(width: 36, height: 5)
                
                VStack (spacing: 38) {
                    ZStack {
                        HStack(alignment: .top){
                            
                            Button{
                                withAnimation {
                                    condition = false
                                }
                            } label: {
                                Text("\(sheetType.closeLabel)")
                                    .font(.body)
                                    .foregroundColor(.getAppColor(.primary))
                                    .padding(.leading, 16)
                            }
                            
                            Spacer()
                            
                            if sheetType == .filters {
                                Button{
                                    
                                } label: {
                                    Text("Reset")
                                        .font(.body)
                                        .foregroundColor(.getAppColor(.primary))
                                        .padding(.trailing, 16)
                                }
                            }
                        }
                        
                        if let title = sheetType.title {
                            //bakal jalan kalo sheetType.title ada isinya, jadi distore ke title yang baru{
                            HStack {
                                Spacer()
                                Text(title)
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                    
                    content()
                }

                Spacer()
            }
            .padding(.top, 6)
            .frame(width: ScreenSize.width, height: condition ? .getResponsiveHeight(sheetType.height) : 0)
            .background(Color.getAppColor(.neutral3))
            .cornerRadius(12)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyView()
        .customSheet(.constant(true), sheetType: .settings) {
            SettingsView(username: "Full Name", userEmail: "FullName@habitmail.com", initial: "FL", showAlert: .constant(true), showPrivacyPolicy: .constant(true), showTermsAndConditions: .constant(true))
        }
}