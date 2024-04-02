//
//  CustomSheetView.swift
//  HabitCo
//
//  Created by Yovita Handayiani on 01/04/24.
//

import SwiftUI

struct CustomSheetView: View {
    let username: String
    let userEmail: String
    let initial: String
    @State private var presentAlert = false
    
    var body: some View {
        //buat overlay
        VStack{
            //buat sheet
            VStack{
                //header
                Capsule().fill(.gray).frame(width: 36, height: 5).padding(EdgeInsets(top: 6, leading: 0, bottom: 25, trailing: 0))
                HStack(alignment: .top){
                    Button{
                        
                    }label: {
                        Text("Back").font(.body).foregroundColor(.getAppColor(.primary))
                    }.padding(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 90))
                    Text("Settings")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 38, trailing: 146))
                }
                //user profile
                VStack{
                    ZStack{
                        Circle().fill(Color(red: 240/255, green: 225/255, blue: 206/255)).frame(width: 160, height: 160)
                        Text(initial).font(.system(size: 68)).foregroundColor(.getAppColor(.neutral3))
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    Text(username).font(.body)
                    Text(userEmail).font(.caption2)
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 48, trailing: 0))
                
                //settings
                VStack{
                    SettingButton(label: "Help", action: {}, icon: "questionmark.circle")
                    SettingButton(label: "Privacy Policy", action: {}, icon: "lock.shield")
                    SettingButton(label: "Terms and Conditions", action: {}, icon: "doc.text")
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 80, trailing: 0))
                
                Button{
                    presentAlert = true
                }label: {
                    Text("Sign Out").foregroundColor(.getAppColor(.neutral3))
                }.alert(isPresented: $presentAlert){
                    Alert(
                        title: Text("Are you sure you want to Sign Out?"),
                        message: Text("Signing out means that you will need to sign in again when you open the apps. "),
                        primaryButton: .default(Text("Cancel"), action: {
                            
                        }),
                        secondaryButton: .destructive(Text("Sign Out"), action: {
                            
                        })
                    )
                }
                .frame(width: 345, height: 48, alignment: .center)
                .background(Color.getAppColor(.danger))
                .cornerRadius(12)
                .shadow(color: Color(red: 22/255, green: 22/255, blue: 22/255).opacity(0.1), radius: 8, x: 0, y: 10)
            }
            .frame(width: UIScreen.main.bounds.width, height: 738)
            .background(Color.getAppColor(.neutral3))
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.4).ignoresSafeArea())
    }
}

#Preview {
    CustomSheetView(username: "Full Name", userEmail: "FullName@habitmail.com", initial: "FL")
}
