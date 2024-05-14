//
//  LabelButton.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 15/03/24.
//

import SwiftUI

struct LabelButton: View {
    @Binding var isSelected: Bool
    let color: Color
    
    init(tag: Color.FilterColors, selection: Binding<Color.FilterColors?>, color: Color) {
        self._isSelected = Binding(
            get: { selection.wrappedValue == tag },
            set: { _ in selection.wrappedValue = tag }
        )
        self.color = color
    }
    
    init(tag: Color.FilterColors, selection: Binding<Set<Color.FilterColors>>, color: Color){
        self._isSelected = Binding(
            get: { selection.wrappedValue.contains(tag)},
            set: { tes in
                if !tes {
                    selection.wrappedValue.remove(tag)
                } else{
                    selection.wrappedValue.insert(tag)
                }
            }
        )
        self.color = color
    }

    init(tag: Color.FilterColors, selection: Binding<[Color.FilterColors]>, color: Color){
        self._isSelected = Binding(
            get: { selection.wrappedValue.contains(tag)},
            set: { tes in
                if !tes {
                    if let index = selection.wrappedValue.firstIndex(of: tag) {
                        selection.wrappedValue.remove(at: index)
                    }
                } else{
                    selection.wrappedValue.append(tag)
                }
            }
        )
        self.color = color
    }

    var body: some View {
        Button(action: {
            isSelected.toggle()
        }, label: {
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.black)
            } else {
                Color.clear
            }
        })
        .frame(width: 40, height: 40)
        .background(
            ZStack{
                Circle()
                    .foregroundColor(color)
                
                if isSelected {
                    Circle()
                        .stroke(lineWidth: 2)
                }
            }
        )
    }
}

#Preview {
    LabelButton(tag: Color.FilterColors.aluminium, selection: .constant(Color.FilterColors.aluminium), color: Color.aluminium)
}
