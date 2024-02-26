//
//  UserModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable {
    let userId: String
    let name: String
    let imageUrl: String?
    let currentTrack: Track?
    let location: GeoPoint?
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
    @Published var currentUser: User?
}
