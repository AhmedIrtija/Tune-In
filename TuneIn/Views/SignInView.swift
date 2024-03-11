//
//  SignInEmailView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

@MainActor
final class SignInViewModel: ObservableObject {
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

struct SignInView: View {
    @Binding var rootViewType: RootViewType
    @State private var showLoginView: Bool = false
    @State private var errorMessage: String = ""
    @StateObject private var viewModel = SignInViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // App Icon
                Image(uiImage: UIImage(imageLiteralResourceName: "AppIcon"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140.0)
                    .padding([.top], 50)
                // Title
                Text("Sign In")
                    .font(Font.custom("Damion", size: 50))
                    .padding([.top], -10)
                    .padding([.bottom], 10)
                    .foregroundColor(.white)
                Form {
                    // Email
                    Section(header: Text("Email")) {
                        TextField("", text: $viewModel.email)
                            .foregroundColor(.white)
                            .focused($isTextFieldFocused)
                            .onChange(of: viewModel.email) {
                                errorMessage = ""
                            }
                            .keyboardType(.emailAddress)
                    }
                    // Password
                    Section(header: Text("Password")) {
                        SecureField("", text: $viewModel.password)
                            .foregroundColor(.white)
                            .focused($isTextFieldFocused)
                            .onChange(of: viewModel.password) {
                                errorMessage = ""
                            }
                    }
                }
                .preferredColorScheme(.dark)
                
                if !errorMessage.isEmpty {
                    Label(
                        title: { Text(errorMessage) },
                        icon: { Image(systemName: "xmark.circle") }
                    )
                    .foregroundStyle(.red)
                }
                
                Button("Sign In") {
                    Task {
                        if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            errorMessage = "Invalid email or password"
                            return
                        } else {
                            errorMessage = ""
                        }
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
                            // display error message if account exists but sign in failure
                            errorMessage = "Invalid email or password"
                        }
                    }
                }
                .frame(width: 125, height: 32)
                .foregroundStyle(Color.gray)
                .background(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .circular
                    )
                    .stroke(Colors.gray, lineWidth: 2)
                )
                .padding([.top], -180.0)
                .navigationDestination(isPresented: $showLoginView) {
                    SpotifyLoginView(rootViewType: $rootViewType)
                }
            }
            .padding()
            .ignoresSafeArea(.keyboard)
        }
        .onTapGesture { isTextFieldFocused = false }
    }
}

#Preview {
    SignInView(rootViewType: .constant(.signInView))
}
