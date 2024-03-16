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
             if text.isEmpty {
                VStack {
                     Text(placeholder)
                         .padding(.top, 10)
                         .padding(.leading, 6)
                         .opacity(0.6)
                     Spacer()
                 }
             }
             
             VStack {
                 TextEditor(text: $text)
                     .frame(minHeight: 150, maxHeight: 300)
                     .opacity(text.isEmpty ? 0.85 : 1)
                 Spacer()
             }
         }
     }
 }

#Preview {
    TextEditorWithPlaceholder(placeholder: "Insert...", text: .constant("Hello World"))
}
