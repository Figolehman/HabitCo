//
//  ContentView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 06/02/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State var titles = ["Cell #1", "Cell #2", "Cell #3", "Cell #4"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.titles, id: \.self) { title in
                        HStack {
                            Text(title)
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .swipeButtons([
                            CustomSwipeButton(
                                image: Image(systemName: "plus"),
                                title: "Duplicate",
                                color: .blue,
                                action: { self.titles.append("\(title) (2)") }
                            ),
                            CustomSwipeButton(
                                image: Image(systemName: "trash"),
                                title: "Delete",
                                color: .red,
                                action: { self.titles.remove(at: self.titles.firstIndex(of: title)!) }
                            )
                        ])
                    }
                }
                .animation(.default, value: self.titles)
            }
            .navigationTitle(Text("Custom swipe action"))
        }
    }
}

struct CustomSwipeButton {
    let image: Image?
    let title: String?
    let color: Color
    let action: () -> Void
}

struct SwipeButtonsModifier: ViewModifier {
    @State private var position: CGFloat = 0
    @State private var lastPosition: CGFloat = 0
    @State private var swipeShouldPublishNotification = true

    let buttons: [CustomSwipeButton]

    private let notificationName = Notification.Name("customSwipeDidStart")
    private let buttonWidth: CGFloat = 70
    private let animation = Animation.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.25)

    private var count: CGFloat {
        CGFloat(self.buttons.count)
    }

    func body(content: Content) -> some View {
        ZStack {
            HStack(spacing: 0) {
                content
                    .hidden()

                ForEach(Array(zip(self.buttons, self.buttons.indices)), id: \.0.title) { button, idx in
                    let width = max(0, -self.position / self.count)

                    Button {
                        self.dismiss()

                        button.action()
                    } label: {
                        VStack {
                            if let image = button.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }

                            if let title = button.title {
                                Text(title)
                                    .fixedSize()
                                    .font(.footnote)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(width: width)
                        .frame(maxHeight: .infinity)
                        .background(button.color)
                    }
                }
            }

            content
                .offset(x: self.position)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if self.swipeShouldPublishNotification {
                                NotificationCenter.default.post(Notification(name: self.notificationName))

                                self.swipeShouldPublishNotification = false
                            }

                            if value.translation.width < 0 || self.lastPosition < 0 {
                                self.position = self.lastPosition + value.translation.width
                            }
                        }
                        .onEnded { value in
                            self.swipeShouldPublishNotification = true

                            if value.translation.width < 0 && abs(value.translation.width + self.lastPosition) > 20 * self.count {
                                let fixedWidth = -self.buttonWidth * self.count

                                withAnimation(self.animation) {
                                    self.position = fixedWidth
                                    self.lastPosition = fixedWidth
                                }
                            } else {
                                self.dismiss()
                            }
                        }
                )
                .onReceive(NotificationCenter.default.publisher(for: self.notificationName)) { _ in
                    self.dismiss()
                }
        }
    }

    private func dismiss() {
        withAnimation(self.animation) {
            self.position = 0
            self.lastPosition = 0
        }
    }
}

extension View {
    func swipeButtons(_ buttons: [CustomSwipeButton]) -> some View {
        self.modifier(SwipeButtonsModifier(buttons: buttons))
    }
}

//struct DateHelper {
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter
//    }()
//}

#Preview {
    ContentView()
}
