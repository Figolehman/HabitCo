//
//  JournalView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 23/03/24.
//

import SwiftUI

struct JournalView: View {
    
    @State var showSheet = false
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 48) {
                
                ScrollableCalendarView(hasHabit: [])
                    .padding(.top, .getResponsiveHeight(60))
                
                VStack (spacing: 24) {
                    HStack (spacing: 16) {
                        FilterButton(isDisabled: .constant(true)) {
                            
                        }
                        
                        SortButton(label: "Progress", isDisabled: .constant(true), imageType: .unsort) {
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.getAppColor(.primary))
                        }
                    }
                    
                    Text("TES")
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .toolbar {
                HStack {
                    Text("March, 2024")
                        .foregroundColor(.getAppColor(.neutral))
                        .font(.largeTitle.weight(.bold))
                    
                    Spacer()
                    
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.getAppColor(.primary))
                    }
                }
                .padding(.horizontal, 16)
                .frame(width: ScreenSize.width)
            }
            .background(
                Image("blobsJournal")
                    .frame(width: .getResponsiveWidth(558.86658), height: .getResponsiveHeight(509.7464))
                    .offset(y: .getResponsiveHeight(-530))
            )
        }
        .sheet(isPresented: $showSheet, content: {
            
        })
        .onAppear {
            let customNavigation = UINavigationBarAppearance()
            customNavigation.titleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            customNavigation.largeTitleTextAttributes = [.foregroundColor: UIColor(.getAppColor(.neutral))]
            
            UINavigationBar.appearance().standardAppearance = customNavigation
        }
    }
}

#Preview {
    JournalView()
}
