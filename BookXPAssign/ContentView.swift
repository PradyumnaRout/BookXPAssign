//
//  ContentView.swift
//  BookXPAssign
//
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = AuthenticationViewModel()
    
    var body: some View {
        switch vm.authState {
        case .signedIn:
            AppTabView()
                .environmentObject(vm)
        case .signedOut:
            LoginView()
                .environmentObject(vm)
        }
    }
}

#Preview {
    ContentView()
}
