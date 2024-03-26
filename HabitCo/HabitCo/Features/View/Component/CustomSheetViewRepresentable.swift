//
//  CustomSheetViewRepresentable.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 26/03/24.
//

import SwiftUI

struct CustomSheetViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController() // Instantiate your custom UIViewController
        viewController.view.backgroundColor = .white
        viewController.preferredContentSize = CGSize(width: 300, height: 100) // Set preferred content size
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct TestView: View {
    @State private var isPresented = false

    var body: some View {
        Button("Show Sheet") {
            self.isPresented.toggle()
        }
        .sheet(isPresented: $isPresented) {
            CustomSheetViewController()
        }
    }
}

#Preview {
    TestView()
}
