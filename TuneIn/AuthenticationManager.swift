//
//  AuthenticationManager.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let additionalUserInfo: [String: Any] = [
            "name": email,
            "imageUrl": ""
        ]
        try await linkUser(user: authDataResult.user, additionalUserInfo: additionalUserInfo)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Updates user info to default values
    func linkUser(user: User, additionalUserInfo: [String: Any]) async throws {
        let userManager = UserManager.shared
        let dbUser = DBUser(userId: user.uid, 
                            name: user.displayName ?? "",
                            pronouns: (additionalUserInfo["pronouns"] as? Pronouns) ?? .na,
                            bio: additionalUserInfo["bio"] as? String ?? "Hey there! I am using TuneIn",
                            imageUrl: user.photoURL?.absoluteString,
                            date_created: Date())
        let mergedUserInfo = try mergeAdditionalUserInfo(user: dbUser, additionalUserInfo: additionalUserInfo)
        try await userManager.createNewUser(newUser: mergedUserInfo)
    }
    
    // Updates user info with information provided at log in
    private func mergeAdditionalUserInfo(user: DBUser, additionalUserInfo: [String: Any]) throws -> DBUser {
        var mergedUserInfo = user
        for (key, value) in additionalUserInfo {
            switch key {
            case "name":
                if let newName = value as? String {
                    mergedUserInfo.name = newName
                }
            case "imageUrl":
                if let newImageUrl = value as? String {
                    mergedUserInfo.imageUrl = newImageUrl
                }
            default:
                break
            }
        }
        return mergedUserInfo
    }
}
