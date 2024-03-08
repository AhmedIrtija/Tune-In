//
//  AuthenticationView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var rootViewType: RootViewType
    @State private var showSignInEmailView: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Spotify Login View")
            Button(action: {
                showSignInEmailView = true
            }) {
                Text("Sign in with Email")
                    .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                    .foregroundColor(.white)
                    .padding(10.0)
                    .frame(height: 55.0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            .navigationDestination(isPresented: $showSignInEmailView) {
                SignInEmailView(rootViewType: $rootViewType)
            }
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(rootViewType: .constant(.authenticationView))
    }
}
