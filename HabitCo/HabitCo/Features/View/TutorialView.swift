//
//  TutorialView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 14/05/24.
//

import SwiftUI

struct TutorialView: View {

    let completion: () -> Void

//    @EnvironmentObject var appRootManager: AppRootManager

    @State var page = 1

    @State var point: CGPoint = .zero
    @State var size: CGSize = .zero

    @State var point2: CGPoint = .zero
    @State var size2: CGSize = .zero

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 48) {
                    HStack (spacing: 8) {
                        Image(systemName: "flame")
                            .font(.caption)
                        Text("1 Day Streak!")
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(width: ScreenSize.width)

                    Group {
                        ScrollableCalendarView(hasHabit: [], selectedDate: .constant(Date()))

                        VStack (spacing: 24) {
                            HStack (spacing: 16) {
                                FilterButton(isDisabled: .constant(false))

                                SortButton(label: "Progress", isDisabled: .constant(false), imageType: .constant(.unsort))

                                Spacer()

                                Button {
                                    //                                showCreateHabit = true
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.getAppColor(.primary))
                                }
                            }
                            .padding(.horizontal, 24)
                            .frame(width: ScreenSize.width)

                            ScrollView {
                                VStack (spacing: .getResponsiveHeight(24)) {
                                    HabitItem(isShownSlided: Binding(get: {
                                        page == 4
                                    }, set: { value in
                                        
                                    }), habitType: .regular, habitName: "Habit Name", label: Color.FilterColors.cornflower.rawValue)
                                        .readPosition { point = $0 }
                                        .readSize { size = $0 }

                                    HabitItem(habitType: .pomodoro, habitName: "Habit Name", label: Color.FilterColors.blossom.rawValue)
                                        .readPosition { point2 = $0 }
                                        .readSize { size2 = $0 }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 8)
                .background(
                    ZStack {
                        Color.getAppColor(.neutral3)
                            .ignoresSafeArea()

                        Image("blobsJournal")
                            .frame(width: .getResponsiveWidth(558.86658), height: .getResponsiveHeight(509.7464))
                            .offset(y: .getResponsiveHeight(-530))
                    }
                )
                .onAppear {
                    let customNavigation = UINavigationBarAppearance()
                    customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
                    customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
                }
                .toolbar {

                    HStack {
                        Text(Date().getMonthAndYearString())
                            .foregroundColor(.getAppColor(.neutral))
                            .font(.largeTitle.weight(.bold))

                        Spacer()

                        Button {

                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.getAppColor(.primary))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(width: ScreenSize.width)
                }

                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if page < 4{
                            page = page + 1
                        } else {
                            completion()
                        }
                    }

                if page == 1 {
                    Image("habitdetail-tutorial-1")
                        .position(x: point.x + (size.width / 2), y: point.y - (size.height / 2) + 1 - size.height)
                        .offset(x: .getResponsiveWidth(50), y: .getResponsiveHeight(-20))
                    Image("habitdetail-tutorial-2")
                        .position(x: point2.x + (size2.width / 2), y: point2.y - (size2.height / 2) + 1 + size2.height)
                        .offset(x: .getResponsiveWidth(50), y: .getResponsiveHeight(-20))
                } else if page == 2 {
                    Image("pomodoro-tutorial")
                        .position(x: point2.x + (size2.width / 2), y: point2.y - (size2.height / 2) + 1 + size2.height)
                        .offset(x: .getResponsiveWidth(70), y: .getResponsiveHeight(-20))
                } else if page == 3 {
                    Image("addhabit-tutorial")
                        .position(x: point.x + (size.width / 2), y: point.y - (size.height / 2) + 1 - size.height)
                        .offset(x: .getResponsiveWidth(100), y: .getResponsiveHeight(-20))
                } else if page == 4 {
                    Image("undo-tutorial")
                        .position(x: point.x + (size.width / 2), y: point.y - (size.height / 2) + 1 - size.height)
                        .offset(x: .getResponsiveWidth(124), y: .getResponsiveHeight(-20))
                }

            }
        }
    }
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

extension View {
  func readPosition(onChange: @escaping (CGPoint) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: PositionPreferenceKey.self, value: geometryProxy.frame(in: CoordinateSpace.global).origin)
      }
    )
    .onPreferenceChange(PositionPreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private struct PositionPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero
  static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}


#Preview {
    //    NavigationView{
    TutorialView() {}
//        .environmentObject(AppRootManager())
    //    }
}
