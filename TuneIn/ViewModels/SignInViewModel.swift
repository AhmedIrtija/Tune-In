//
//  SignInViewModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/20/24.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    // Set up environment variable
    var userModel: UserModel?
    func setUserModel(userModel: UserModel) {
        self.userModel = userModel
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        // create new authenticated user in Firebase
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        
        // load authentication token to user model
        try await userModel?.loadAuthenticationTokenFromAuth(authDataResult: authDataResult)
        
        // save authentication token to local storage
        try await userModel?.saveAuthenticationTokenToStorage(authToken: authDataResult.uid)
        
        // load new appUser object with authentication token
        try await userModel?.loadNewUser()
        
        // create new document in database
        guard let currentUser = userModel?.currentUser else { return }
        try await UserManager.shared.createNewUser(newUser: DBUser(user: currentUser))
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        // get authentication token of existing user
        let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
        // load authentication token to user model
        try await userModel?.loadAuthenticationTokenFromAuth(authDataResult: authDataResult)
        
        // save authentication token to local storage
        try await userModel?.saveAuthenticationTokenToStorage(authToken: authDataResult.uid)
        
        // load user
        try await userModel?.loadUser()
    }
}
