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
    
    // Drag Properties
    @State private var offset: CGFloat = 0
    
    @Binding var condition: Bool
    
    var sheetType: SheetType

    var onLeftButtonTapped: () -> Void = {}
    var onRightButtonTapped: () -> Void = {}

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
                                onLeftButtonTapped()
                            } label: {
                                Text("\(sheetType.closeLabel)")
                                    .font(.body)
                                    .foregroundColor(.getAppColor(.primary))
                                    .padding(.leading, 16)
                            }
                            
                            Spacer()
                            
                            if sheetType == .filters {
                                Button{
                                    onRightButtonTapped()
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
            .frame(height: .getResponsiveHeight(sheetType.height))
            .background(Color.getAppColor(.neutral3))
            .cornerRadius(12)
            .offset(y: condition ? 0 : .getResponsiveHeight(sheetType.height))
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.height
                        self.offset = max(translation, 0)
                    }.onEnded({ _ in
                        if self.offset >= sheetType.height/2 {
                            withAnimation(.linear(duration: 0.5)) {
                                condition = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.offset = 0
                            }

                        } else {
                            withAnimation {
                                self.offset = 0
                            }
                        }
                        
                    })
            )
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
