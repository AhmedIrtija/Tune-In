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
            // Sign in with email
            Button(action: {
                showSignInEmailView = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24.0)
                        .foregroundStyle(.white)
                        .padding([.leading, .trailing], 48.0)
                    Text("Sign in with Email")
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundStyle(.white)
                        .padding(10.0)
                    Spacer()
                }
                .frame(height: 55.0)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.blue)
                .cornerRadius(10.0)
            }
            .navigationDestination(isPresented: $showSignInEmailView) {
                SignInEmailView(rootViewType: $rootViewType)
            }
            
            // Sign in with Google
            Button(action: {
                showSignInEmailView = true
            }) {
                HStack {
                    Image("GoogleIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24.0)
                        .padding([.leading, .trailing], 48.0)
                    Text("Sign in with Google")
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundStyle(.white)
                        .padding(10.0)
                    Spacer()
                }
                .frame(height: 55.0)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.green)
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
