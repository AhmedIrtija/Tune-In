//
//  UserManager.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser {
    let userId: String
    let name: String
    let imageUrl: String?
    let currentTrack: Track?
    let location: GeoPoint?
    let date_created: Timestamp?
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    // usage:
    // try await UserManager.shared.createNewUser(newUser: newUser)
    func createNewUser(newUser: User) async throws {
        var userData: [String : Any] = [
            "user_id": newUser.userId,
            "name": newUser.name,
            "date_created": Timestamp(),
        ]
        
        if let imageUrl = newUser.imageUrl {
            userData["image_url"] = imageUrl
        }
        
        if let currentTrack = newUser.currentTrack {
            let trackData: [String: String] = [
                "id": currentTrack.id,
                "name": currentTrack.name,
                "artist": currentTrack.artist,
                "album": currentTrack.album,
                "album_url": currentTrack.albumUrl
            ]
            userData["current_track"] = trackData
        }
        
        if let location = newUser.location {
            userData["location"] = location
        }
        
        try await Firestore.firestore().collection("users").document(newUser.userId).setData(userData, merge: false)
    }
    
    // usage:
    // try await UserManager.shared.getUser(userId: "UserId")
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(),
              let userId = data["user_id"] as? String,
              let name = data["name"] as? String,
              let location = data["location"] as? GeoPoint
        else {
            throw URLError(.badServerResponse)
        }
        
        let imageUrl = data["image_url"] as? String
        
        let currentTrackData = data["current_track"] as? [String: String]
        let currentTrack = currentTrackData.map { trackData in
            Track(id: trackData["id"] ?? "",
                  name: trackData["name"] ?? "",
                  artist: trackData["artist"] ?? "",
                  album: trackData["album"] ?? "",
                  albumUrl: trackData["album_url"] ?? "")
        }
            
        let dateCreated = data["date_created"] as? Timestamp
        
        return DBUser(userId: userId,
                      name: name,
                      imageUrl: imageUrl,
                      currentTrack: currentTrack,
                      location: location,
                      date_created: dateCreated)
    }
}
