//
//  EditCardView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 16/03/24.
//

import SwiftUI

enum EditableCardType {
    case name
    case description
    
    var placeholder: String {
        get {
            switch self {
            case .name:
                return "Habit Name"
            case .description:
                return "Describe your habits and goals here..."
            }
        }
    }
    
    var height: CGFloat {
        get {
            switch self {
            case .name:
                return .nan
            case .description:
                return 122
            }
        }
    }
    
}

struct EditableCardView: View {
    let cardType: EditableCardType
    
    @Binding var text: String
    lazy var isFocus: Bool = false
    
    var body: some View {
        CardView {
            HStack{
                if cardType == .name {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text("\(cardType.placeholder)")
                                .foregroundColor(.getAppColor(.primary2))
                                
                        }
                        .padding(.leading, 4)
                } else {
                    TextEditorWithPlaceholder(placeholder: cardType.placeholder, text: $text)
                        .frame(height: 122)
                        .padding(.vertical, 16)
                }
            }
            
        }
        .autocorrectionDisabled()
    }
}

#Preview {
    VStack {
        EditableCardView(cardType: .name, text: .constant("aaaaa"))
        EditableCardView(cardType: .description, text: .constant("BBBB"))
    }
}
