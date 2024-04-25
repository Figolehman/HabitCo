//
//  SwiftUIView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 25/04/24.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
