//
//  GoogleSinginButton.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import SwiftUI
import GoogleSignIn

// Google Sign In button using UIViewRepresentable
struct GoogleSignInButton: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    private var button = GIDSignInButton()
    
    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = colorScheme == .dark ? .dark : .light
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        button.colorScheme = colorScheme == .dark ? .dark : .light
    }
}
