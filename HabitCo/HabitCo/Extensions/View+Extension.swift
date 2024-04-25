//
//  File.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 17/03/24.
//

import Foundation
import SwiftUI


// MARK: - View Modifier Utility
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Elevation Effect View Modifier
extension View {
    func elevate1() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 6, x: 0, y: 2)
    }
    
    func elevate2() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 16, x: 0, y: 4)
    }
    
    func elevate3() -> some View {
        return self.shadow(color: .getAppColor(.shadow), radius: 24, x: 0, y: 10)
    }
}

// MARK: - Popover
extension View {
    @ViewBuilder
    func alertOverlay(_ condition: Binding<Bool>, closeOnTap: Bool = false, content: () -> (some View)) -> some View {
        
        ZStack {
            self
            
            if condition.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .if(closeOnTap) { view in
                        view.onTapGesture {
                            condition.wrappedValue = false
                        }
                    }
                
                content()
            }
        }
    }
}

// MARK: - Placeholder with Color
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Half Sheet
extension View {
    func customSheet(_ condition: Binding<Bool>, sheetType: SheetType, content: @escaping () -> (some View)) -> some View {
        ZStack {
            
            self // = journal view
            
            if condition.wrappedValue {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
            }
            
            CustomSheetView(condition: condition, sheetType: sheetType) {
                content()
            }
            
        }
    }
}

// MARK: - View to UIImage
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = UIScreen.main.bounds.size
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


#Preview {
    EmptyView()
        .alertOverlay(.constant(true), closeOnTap: true) {
            Text("ASD")
        }
}
