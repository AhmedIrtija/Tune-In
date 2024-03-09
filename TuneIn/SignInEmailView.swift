//
//  SignInEmailView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    @Binding var rootViewType: RootViewType
    @State private var showLoginView: Bool = false
    @StateObject private var viewModel = SignInEmailViewModel()
    
    var body: some View {
        VStack {
            Text("Sign in with Email View")
            
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10.0)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10.0)
            
            Button(action: {
                Task {
                    // sign up if new account
                    do {
                        try await viewModel.signUp()
                        showLoginView = true
                        return
                    } catch {
                        print(error)
                    }
                    
                    // sign in if account exists
                    do {
                        try await viewModel.signIn()
                        showLoginView = true
                        return
                    } catch {
                        print(error)
                    }
                }
                
            }) {
                Text("Sign In")
                    .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                    .foregroundColor(.white)
                    .padding(10.0)
                    .frame(height: 55.0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            .navigationDestination(isPresented: $showLoginView) {
                SpotifyLoginView(rootViewType: $rootViewType)
            }
            
            Spacer()
        }
        .navigationTitle("Sign In With Email")
        .padding()
    }
}

#Preview {
    SignInEmailView(rootViewType: .constant(.authenticationView))
}
