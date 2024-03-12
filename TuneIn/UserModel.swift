//
//  UserModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AppUser: Codable {
    let userId: String
    let name: String
    let pronouns: Pronouns?
    let bio: String?
    let imageUrl: String?
    let currentTrack: Track?
    let location: GeoPoint?
    
    init(userId: String) {
        self.userId = userId
        self.name = ""
        self.pronouns = Pronouns.na
        self.bio = "Hey there! I'm using TuneIn."
        self.imageUrl = nil
        self.currentTrack = nil
        self.location = nil
    }
    
    init(dbUser: DBUser) {
        self.userId = dbUser.userId
        self.name = dbUser.name
        self.pronouns = dbUser.pronouns
        self.bio = dbUser.bio
        self.imageUrl = dbUser.imageUrl
        self.currentTrack = dbUser.currentTrack
        self.location = dbUser.location
    }
}

struct Track: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let artist: String
    let album: String
    let albumUrl: String
}

class UserModel: ObservableObject {
    @Published var authToken: String?
    @Published var currentUser: AppUser?
    
    func loadAuthenticationToken(authDataResult: AuthDataResultModel) async throws {
        let userId = authDataResult.uid
        DispatchQueue.main.async {
            self.authToken = userId
        }
    }
    
    func loadNewUser() async throws {
        guard let authToken = self.authToken else { return }
        DispatchQueue.main.async {
            self.currentUser = AppUser(userId: authToken)
        }
    }
    
    func loadUser() async throws {
        guard let authToken = self.authToken else { return }
        let dbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: dbUser)
        }
    }
    
    func setUserName(name: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateName(userId: authToken, newName: name)
    }
    
    func setPronouns(pronouns: Pronouns) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updatePronouns(userId: authToken, newPronouns: pronouns)
    }
    
    func setBio(bio: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateBio(userId: authToken, newBio: bio)
    }
    
    func setUserImageUrl(imageUrl: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateImage(userId: authToken, newImageUrl: imageUrl)
    }
    
    func setCurrentTrack(track: Track) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateTrack(userId: authToken, newTrack: track)
    }
    
    func setLocation(latitude: Double, longitude: Double) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateLocation(userId: authToken, newLatitude: latitude, newLongitude: longitude)
    }
}
