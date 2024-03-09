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
    @Published var showLoginView = false
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                self.showLoginView = true
                print("success")
                print(returnedUserData)
            } catch {
                print("Error: \(error)")
            }
        }
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
                viewModel.signIn()
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
            .navigationDestination(isPresented: $viewModel.showLoginView) {
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
