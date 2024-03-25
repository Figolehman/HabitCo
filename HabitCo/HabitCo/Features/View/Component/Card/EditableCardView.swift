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
    
    @State var text: String = ""
    lazy var isFocus: Bool = false
    
    var body: some View {
        CardView {
            HStack{
                if cardType == .name {
                    TextField(cardType.placeholder, text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text("\(cardType.placeholder)")
                        }
                } else {
                    TextEditorWithPlaceholder(placeholder: cardType.placeholder, text: $text)
                        .frame(height: 122)
                        .padding(.vertical, 16)
                }
            }
            
        }
    }
}

#Preview {
    EditableCardView(cardType: .description)
}
