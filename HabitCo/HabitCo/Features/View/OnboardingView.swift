//
//  OnboardingView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 22/03/24.
//

import SwiftUI

struct OnboardingView: View {
    @State var index = 0
    
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
                    
                    ZStack {
                        Image("plant")
                            
                        
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
                    ZStack {
                        Image("hourglass")
                        
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
                            
                        }
                        
                        Group {
                            Text("By signing up, you ") +
                            Text("Agree ")
                                .bold() +
                            Text("to HabitCo ") +
                            Text("Privacy Policy ")
                                .bold() +
                            Text("and ") +
                            Text("Terms of Service")
                                .bold()
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(width: .getResponsiveWidth(345))
        }
    }
}

#Preview {
    OnboardingView()
}
