//
//  OnboardingView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject private var userViewModel = UserViewModel()
    @State private var showSignInView: Bool = false
    @State var index = 0
    @Environment(\.auth) private var userAuth
    @EnvironmentObject var appRootManager: AppRootManager

    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false

    init () {
        setupPageTabIndicator()
        
    }
    
    func setupPageTabIndicator() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.getAppColor(.primary))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.getAppColor(.neutral2))
    }
    
    var body: some View {
        
        ZStack {
                
                TabView(selection: $index) {
                    
                    // MARK: - Item 1
                    ZStack {
                        Image("plant")
                            .frame(width: .getResponsiveWidth(456), height: .getResponsiveHeight(623.57574))
                            .offset(x: .getResponsiveWidth(-180), y: .getResponsiveHeight(-65))
                        
                        VStack (spacing: 24) {
                            Spacer(minLength: .getResponsiveHeight(376 - 24))
                            
                            Text("Welcome to HabitCo")
                                .font(.body.weight(.semibold))
                            
                            Text("HabitCo is an application designed to help people build a good habit.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .frame(width: .getResponsiveWidth(345))
                        
                        
                    }
                    .tag(0)
                    
                    // MARK: - Item 2
                    ZStack {
                        Image("hourglass")
                            .frame(width: .getResponsiveWidth(312), height: .getResponsiveHeight(342))
                            .offset(x: .getResponsiveWidth(180), y: .getResponsiveHeight(-320))
                        
                        VStack (spacing: 24) {
                            Spacer(minLength: .getResponsiveHeight(376 - 24))
                            
                            Text("Work more efficiently with Pomodoro")
                                .font(.body.weight(.semibold))
                            
                            Text("Having trouble maintaining your focus? Do your task with Pomodoro session to increase your productivity!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .frame(width: .getResponsiveWidth(345))
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
            
            
            VStack (spacing: 0) {
                
                Spacer()
                
                VStack (spacing: .getResponsiveHeight(88)){
                    CustomPageControl(numberOfPages: 2, currentPage: $index)
                        
                    
                    VStack (spacing: .getResponsiveHeight(36)) {
                        SignInButton(type: .continue, style: .black) {
                            Task {
                                let (_, _) = try await userAuth.signInApple()
                                appRootManager.currentRoot = .journalView
                            }
                        }
                        
                        Group {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("By signing up, you ") +
                                    Text("Agree ")
                                        .bold() +
                                    Text("to HabitCo ")
                                    Text("Privacy Policy ")
                                        .bold()
                                        .onTapGesture {
                                            showPrivacyPolicy = true
                                        }
                                }
                                HStack(spacing: 0) {
                                    Text("and ")
                                    Text("Terms of Service")
                                        .bold()
                                        .onTapGesture {
                                            showTermsAndConditions = true
                                        }
                                }
                            }
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(width: .getResponsiveWidth(345))
        }
        .customSheet($showPrivacyPolicy, sheetType: .rules, content: {
            PrivacyPolicyView()
        })
        .customSheet($showTermsAndConditions, sheetType: .rules, content: {
            TermsAndConditionsView()
        })
    }
}

#Preview {
    OnboardingView()
}
