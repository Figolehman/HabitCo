//
//  RootView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 07/02/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView = false
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationView {
                    EmptyView()
                }
            }
        }
        .onAppear {
            let authUser = try? AuthManagerEnvironmentKey.defaultValue.currentUser
            self.showSignInView = authUser?.profile == nil
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationView {
                ContentView(showSignInView: $showSignInView)
            }
        })
    }
}

#Preview {
    RootView()
}
