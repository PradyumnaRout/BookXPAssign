//
//  AppTabView.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import SwiftUI

struct AppTabView: View {
    
    @State private var currentTab: Int = 0
    
    var body: some View {
        TabView(selection: $currentTab) {
            NavigationStack() {
                HomeView()
                    .navigationTitle("Home")
            }
            .tabItem {
                Text("Home")
                Image(systemName: "house.fill")
                    .renderingMode(.template)
            }
            .tag(0)
            
            NavigationStack() {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(1)
        }
    }
}

#Preview {
    AppTabView()
}
