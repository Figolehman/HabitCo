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

    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        ZStack(alignment: .leading) {


            VStack {
                TextEditor(text: $text)
                    .frame(minHeight: 150, maxHeight: 300)
                    .textEditorBackground(.getAppColor(.neutral3))
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

extension View {

    func textEditorBackground(_ content: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
                .background(content)
        } else {
            print("ASKDM")
            UITextView.appearance().backgroundColor = .clear
            return self.background(content)
        }
    }
}

#Preview {
//    TextEditorWithPlaceholder(placeholder: "Insert...", text: .constant(""))
    TextEditor(text: .constant("HELLO WORLD"))
        .textEditorBackground(.red)
}
