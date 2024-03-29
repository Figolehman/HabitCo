//
//  SwiftUIView.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 29/03/24.
//

import SwiftUI

struct HabitDetailView: View {
    var body: some View {
        ScrollView {
            VStack (spacing: 40) {
                VStack (spacing: 24) {
                    CalendarView()
                    
                    CardView {
                        Text("Habit Description")
                    }
                }
                
                VStack (spacing: 24) {
                    CardView {
                        HStack {
                            Text("Label")
                            Spacer()
                            Rectangle()
                                .cornerRadius(12)
                                .frame(width: .getResponsiveWidth(124), height: .getResponsiveHeight(46))
                                .foregroundColor(.aluminium)
                        }
                    }
                    
                    CardView {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text("APSKD")
                        }
                    }
                    CardView {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text("APSKD")
                        }
                    }
                    CardView {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text("APSKD")
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Habit Name")
        
    }
}

#Preview {
    NavigationView {
        HabitDetailView()
    }
}
