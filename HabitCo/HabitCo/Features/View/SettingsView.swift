//
//  CustomSheetView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 01/04/24.
//

import SwiftUI

struct SettingsView: View {
    let username: String
    let userEmail: String
    let initial: String
    @Binding var showAlert: Bool
    @State var showSheet = false
    @Binding var showPrivacyPolicy: Bool
    @Binding var showTermsAndConditions: Bool
    
    var body: some View {
        VStack (spacing: 48) {
            VStack (spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 240/255, green: 225/255, blue: 206/255)).frame(width: 160, height: 160)
                    
                    Text(initial).font(.system(size: 68))
                        .foregroundColor(.getAppColor(.neutral3))
                }
                // 16
                VStack (spacing: 4) {
                    Text(username).font(.body)
                    Text(userEmail).font(.caption2)
                }
            }
            
            VStack (spacing: 80) {
                VStack (spacing: 16) {
                    SettingButton(label: "Help", action: {
                        UIApplication.shared.open(URL(string: "mailto:HabitCo.HelpCenter@Gmail.com?subject=Help")!,options: [:], completionHandler: nil)
                    }, icon: "questionmark.circle")
                    
                    SettingButton(label: "Privacy Policy", action: {
                        withAnimation {
                            showPrivacyPolicy = true
                        }
                    }, icon: "lock.shield")
                   
                    
                    SettingButton(label: "Terms and Conditions", action: {
                        withAnimation {
                            showTermsAndConditions = true
                        }
                    }, icon: "doc.text")
                }
                
                Button (action: {
                    showAlert = true
                }, label: {
                    Text("Sign Out")
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(width: 345, height: 48)
                        .background(Color.getAppColor(.danger))
                        .cornerRadius(12)
                        .elevate3()
                })
            }
            .padding(.bottom, 47)
        }
    }
}

#Preview {
    EmptyView()
        .customSheet(.constant(true), sheetType: .settings) {
            SettingsView(username: "Full Name", userEmail: "FullName@habitmail.com", initial: "FL", showAlert: .constant(true), showPrivacyPolicy: .constant(true), showTermsAndConditions: .constant(true))
        }
}
