//
//  UserModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AppUser: Codable, Equatable {
    let userId: String
    let name: String
    let pronouns: Pronouns?
    let bio: String?
    let imageUrl: String?
    let currentTrack: Track?
    let location: GeoPoint?
    let valence: String?
    
    init(userId: String) {
        self.userId = userId
        self.name = ""
        self.pronouns = Pronouns.na
        self.bio = "Hey there! I'm using TuneIn."
        self.imageUrl = nil
        self.currentTrack = nil
        self.location = nil
        self.valence = nil
    }
    
    init(dbUser: DBUser) {
        self.userId = dbUser.userId
        self.name = dbUser.name
        self.pronouns = dbUser.pronouns
        self.bio = dbUser.bio
        self.imageUrl = dbUser.imageUrl
        self.currentTrack = dbUser.currentTrack
        self.location = dbUser.location
        self.valence = dbUser.valence
    }
    
    static func ==(lhs: AppUser, rhs: AppUser) -> Bool {
        return lhs.userId == rhs.userId
    }
}

enum Pronouns: String, Codable {
    case na = "--"
    case heHim = "He/Him"
    case sheHer = "She/Her"
    case theyThem = "They/Them"
    
    static var allCases: [Pronouns] {
        return [.na, .heHim, .sheHer, .theyThem]
    }
}

struct Track: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let artist: String
    let album: String
    let albumUrl: String
  //  let preview_url: String
}

class UserModel: ObservableObject {
    @Published var authToken: String?
    @Published var currentUser: AppUser?
    
    func loadAuthenticationTokenFromStorage() async throws {
        DispatchQueue.main.async {
            self.authToken = UserDefaults.standard.string(forKey: "authToken")
        }
    }
    
    func saveAuthenticationTokenToStorage(authToken: String) async throws {
        DispatchQueue.main.async {
            self.authToken = UserDefaults.standard.string(forKey: "authToken")
        }
        UserDefaults.standard.setValue(authToken, forKey: "authToken")
        UserDefaults.standard.synchronize()
    }
    
    func deleteAuthenticationTokenFromStorage() async throws {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.authToken = nil
            self.currentUser = nil
        }
    }
    
    func loadAuthenticationTokenFromAuth(authDataResult: AuthDataResultModel) async throws {
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
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setPronouns(pronouns: Pronouns) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updatePronouns(userId: authToken, newPronouns: pronouns)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setBio(bio: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateBio(userId: authToken, newBio: bio)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setUserImageUrl(imageUrl: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateImage(userId: authToken, newImageUrl: imageUrl)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setCurrentTrack(track: Track) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateTrack(userId: authToken, newTrack: track)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setValence(valence: String) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateValence(userId: authToken, valence: valence)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
    
    func setLocation(latitude: Double, longitude: Double) async throws {
        guard let authToken = self.authToken else { return }
        try await UserManager.shared.updateLocationAndGeohash(userId: authToken, newLatitude: latitude, newLongitude: longitude)
        let newDbUser = try await UserManager.shared.getUser(userId: authToken)
        DispatchQueue.main.async {
            self.currentUser = AppUser(dbUser: newDbUser)
        }
    }
}
