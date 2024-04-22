//
//  CustomAlertView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 03/04/24.
//

import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    let dismiss:  String
    let destruct: String
    var dismissAction: () -> ()
    var destructAction: () -> ()
    
    var body: some View {
        VStack(spacing: 0){
            VStack(spacing: 2){
                Text("\(title)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("\(message)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }.padding(16)
            Divider()
                .background(Color.gray)
            HStack{
                Spacer()
                    .overlay(
                        Button (action: {
                            dismissAction()
                        }, label: {
                            Text("\(dismiss)")
                                .font(.body)
                                .foregroundColor(.getAppColor(.primary))
                        })
                    )
                Divider()
                    .frame(height: 44)
                    .background(Color.gray)
                Spacer()
                    .overlay(
                        Button (action: {
                            destructAction()
                        }, label: {
                            Text("\(destruct)")
                                .font(.headline)
                                .foregroundColor(.getAppColor(.danger))
                        })
                    )
            }
        }
        .frame(width: 273)
        .foregroundColor(.getAppColor(.neutral))
        .background(Color.getAppColor(.neutral3).opacity(0.8))
        .cornerRadius(14)
    }
}

#Preview {
    ZStack {
        Color.black
        CustomAlertView(title: "Are you sure you want to Sign Out?", message: "Signing out means that you will need to sign in again when you open the apps.", dismiss: "Cancel", destruct: "Sign Out", dismissAction: {}, destructAction: {})
    }
}
