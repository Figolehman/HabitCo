//
//  TextEditorWithPlaceholder.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

struct TextEditorWithPlaceholder: View {
    let placeholder: String
     @Binding var text: String
     
     var body: some View {
         ZStack(alignment: .leading) {
             
             
             VStack {
                 TextEditor(text: $text)
                     .frame(minHeight: 150, maxHeight: 300)
                     
//                     .opacity(text.isEmpty ? 0.85 : 1)
                 Spacer()
             }
             
             if text.isEmpty {
                VStack {
                     Text(placeholder)
                        .foregroundColor(.getAppColor(.primary2))
                         .padding(.top, 10)
                         .padding(.leading, 3)
                         
                     Spacer()
                 }
             }
         }
     }
 }

#Preview {
    TextEditorWithPlaceholder(placeholder: "Insert...", text: .constant(""))
}
