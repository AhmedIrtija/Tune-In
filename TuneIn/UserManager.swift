//
//  UserManager.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
    let userId: String
    var name: String
    var imageUrl: String?
    var currentTrack: Track?
    var location: GeoPoint?
    let date_created: Date?
    
    init(user: User) {
        self.userId = user.userId
        self.name = user.name
        self.imageUrl = user.imageUrl
        self.currentTrack = user.currentTrack
        self.location = user.location
        self.date_created = Date()
    }
    
    init(
        userId: String,
        name: String,
        imageUrl: String? = nil,
        currentTrack: Track? = nil,
        location: GeoPoint? = nil,
        date_created: Date? = nil
    ) {
        self.userId = userId
        self.name = name
        self.imageUrl = imageUrl
        self.currentTrack = currentTrack
        self.location = location
        self.date_created = date_created
    }
    
    mutating func updateName(newName: String) {
        name = newName
    }
    
    mutating func updateImage(newImageUrl: String) {
        imageUrl = newImageUrl
    }
    
    mutating func updateTrack(newTrack: Track) {
        currentTrack = newTrack
    }
    
    mutating func updateLocation(newLocation: GeoPoint) {
        location = newLocation
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
        case imageUrl = "image_url"
        case currentTrack = "current_track"
        case location = "location"
        case date_created = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.currentTrack = try container.decodeIfPresent(Track.self, forKey: .currentTrack)
        self.location = try container.decodeIfPresent(GeoPoint.self, forKey: .location)
        self.date_created = try container.decodeIfPresent(Date.self, forKey: .date_created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(self.currentTrack, forKey: .currentTrack)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encodeIfPresent(self.date_created, forKey: .date_created)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(newUser: DBUser) async throws {
        try userDocument(userId: newUser.userId).setData(from: newUser, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func updateName(userId: String, newName: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.name.rawValue: newName
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateImage(userId: String, newImageUrl: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.imageUrl.rawValue: newImageUrl
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateTrack(userId: String, newTrack: Track) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.currentTrack.rawValue: newTrack
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateLocation(userId: String, newLocation: GeoPoint) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.location.rawValue: newLocation
        ]
        try await userDocument(userId: userId).updateData(data)
    }
}
