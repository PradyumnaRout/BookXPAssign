//
//  LoginView.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("bookLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("Welcome to BookXP!")
                .fontWeight(.black)
                .foregroundColor(Color(.systemIndigo))
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                        
            GoogleSignInButton()
                .padding()
                .onTapGesture {
                    vm.singIn()
                }
            
            Spacer()
        }
    }
}

#Preview {
    LoginView()
}
