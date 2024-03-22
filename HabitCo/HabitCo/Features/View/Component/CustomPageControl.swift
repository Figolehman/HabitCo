//
//  CustomPageControl.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import Foundation
import SwiftUI

struct CustomPageControl: UIViewRepresentable {
    
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let view = UIPageControl()
        view.numberOfPages = numberOfPages
        view.backgroundStyle = .minimal
        view.addTarget(context.coordinator, action: #selector(Coordinator.pageChanged), for: .valueChanged)
        return view
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomPageControl
        
        init(_ parent: CustomPageControl) {
            self.parent = parent
        }
        
        @objc func pageChanged(sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
    }
}
