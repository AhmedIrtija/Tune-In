//
//  UserManager.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import GeoFire
import MapKit

enum Pronouns: String, Codable {
    case na = "--"
    case heHim = "He/Him"
    case sheHer = "She/Her"
    case theyThem = "They/Them"
    
    static var allCases: [Pronouns] {
        return [.na, .heHim, .sheHer, .theyThem]
    }
}

struct DBUser: Codable {
    let userId: String
    var name: String
    var pronouns: Pronouns?
    var bio: String?
    var imageUrl: String?
    var currentTrack: Track?
    var location: GeoPoint?
    var geohash: String?        // database only
    let date_created: Date?     // database only
    
    init(user: AppUser) {
        self.userId = user.userId
        self.name = user.name
        self.pronouns = user.pronouns
        self.bio = user.bio
        self.imageUrl = user.imageUrl
        self.currentTrack = user.currentTrack
        self.location = user.location
        self.date_created = Date()
    }
    
    init(
        userId: String,
        name: String,
        pronouns: Pronouns = .na,
        bio: String = "Hey there! I am using TuneIn",
        imageUrl: String? = nil,
        currentTrack: Track? = nil,
        location: GeoPoint? = nil,
        geohash: String? = nil,
        date_created: Date? = nil
    ) {
        self.userId = userId
        self.name = name
        self.pronouns = pronouns
        self.bio = bio
        self.imageUrl = imageUrl
        self.currentTrack = currentTrack
        self.location = location
        self.geohash = geohash
        self.date_created = date_created
    }
    
    mutating func updateName(newName: String) {
        name = newName
    }
    
    mutating func updatePronouns(newPronouns: Pronouns) {
        pronouns = newPronouns
    }
    
    mutating func updateBio(newBio: String) {
        bio = newBio
    }
    
    mutating func updateImage(newImageUrl: String) {
        imageUrl = newImageUrl
    }
    
    mutating func updateTrack(newTrack: Track) {
        currentTrack = newTrack
    }
    
    mutating func updateLocationAndGeohash(newLatitude: Double, newLongitude: Double) {
        location = GeoPoint(latitude: newLatitude, longitude: newLongitude)
        geohash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude))
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
        case pronouns = "pronouns"
        case bio = "bio"
        case imageUrl = "image_url"
        case currentTrack = "current_track"
        case location = "location"
        case geohash = "geohash"
        case date_created = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.pronouns = try container.decodeIfPresent(Pronouns.self, forKey: .pronouns)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.currentTrack = try container.decodeIfPresent(Track.self, forKey: .currentTrack)
        self.location = try container.decodeIfPresent(GeoPoint.self, forKey: .location)
        self.geohash = try container.decodeIfPresent(String.self, forKey: .geohash)
        self.date_created = try container.decodeIfPresent(Date.self, forKey: .date_created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.pronouns, forKey: .pronouns)
        try container.encodeIfPresent(self.bio, forKey: .bio)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(self.currentTrack, forKey: .currentTrack)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encodeIfPresent(self.geohash, forKey: .geohash)
        try container.encodeIfPresent(self.date_created, forKey: .date_created)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    private var usersAroundLocation: [AppUser] = []
    private var selectedRadius: Double = 1.0
    
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
    
    func updatePronouns(userId: String, newPronouns: Pronouns) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.pronouns.rawValue: newPronouns.rawValue
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateBio(userId: String, newBio: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.bio.rawValue: newBio
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
        let encoder = Firestore.Encoder()
        guard let data = try? encoder.encode(newTrack) else {
            throw URLError(.badURL)
        }
        let dict: [String: Any] = [
            DBUser.CodingKeys.currentTrack.rawValue: data
        ]
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func updateLocation(userId: String, newLatitude: Double, newLongitude: Double) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.location.rawValue: GeoPoint(latitude: newLatitude, longitude: newLongitude)
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateGeohash(userId: String, newGeohash: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.geohash.rawValue: newGeohash
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateLocationAndGeohash(userId: String, newLatitude: Double, newLongitude: Double) async throws {
        try await self.updateLocation(userId: userId, newLatitude: newLatitude, newLongitude: newLongitude)
        
        let newGeohash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude))
        try await updateGeohash(userId: userId, newGeohash: newGeohash)
    }
    
    private func fetchMatchingDocs(from snapshot: QuerySnapshot, center: CLLocationCoordinate2D, radius: Double) async throws -> [QueryDocumentSnapshot] {     // radius in meters
        // filter false positives
        return snapshot.documents.filter { document in
            let location = document.data()["location"] as? GeoPoint
            guard let latitude = location?.latitude, let longitude = location?.longitude else {
                return false
            }
            let coordinates = CLLocation(latitude: latitude, longitude: longitude)
            let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let distance = GFUtils.distance(from: centerPoint, to: coordinates)
            
            return distance <= radius
        }
    }
    
    func listenToPeopleAroundUser(center: CLLocationCoordinate2D, radius: Double, completion: @escaping ([AppUser]) -> Void) {
        // set query bounds
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radius)
        let queries = queryBounds.map { bound -> Query in
            return userCollection
                    .order(by: "geohash")
                    .start(at: [bound.startValue])
                    .end(at: [bound.endValue])
        }
        
        let queryDispatchGroup = DispatchGroup()
        let taskDispatchGroup = DispatchGroup()
        var hasSnapshotBeenUpdated: Bool = false
        
        // reset usersAroundLocation
        usersAroundLocation.removeAll()
        
        // set selectedRadius
        selectedRadius = radius
        
        for query in queries {
            queryDispatchGroup.enter()
            hasSnapshotBeenUpdated = false
            
            // add listener
            let _ = query.addSnapshotListener { [weak self] querySnapshot, error in
                hasSnapshotBeenUpdated = true
                
                guard let self = self else { return }
                guard let snapshot = querySnapshot else {
                    print("Error fetching document")
                    taskDispatchGroup.leave()
                    return
                }
                
                taskDispatchGroup.enter()
                Task {
                    do {
                        let matchingDocs = try await self.fetchMatchingDocs(from: snapshot, center: center, radius: self.selectedRadius)
                        var users = [AppUser]()
                        for document in matchingDocs {
                            if let userId = document.data()["user_id"] as? String {
                                let dbUser = try await self.getUser(userId: userId)
                                let user = AppUser(dbUser: dbUser)
                                users.append(user)
                            }
                        }

                        // Check if user already exists in self.usersAroundLocation
                        for user in users {
                            DispatchQueue.main.async {
                                if let existingIndex = self.usersAroundLocation.firstIndex(where: { $0.userId == user.userId }) {
                                    // update existing user
                                    self.usersAroundLocation[existingIndex] = user
                                } else {
                                    // append new user
                                    self.usersAroundLocation.append(user)
                                }
                            }
                        }
                        
                        taskDispatchGroup.leave()
                    } catch {
                        print("Error fetching matching documents: \(error)")
                        taskDispatchGroup.leave()
                    }
                }
                
                // call completion handler if all tasks are done
                if hasSnapshotBeenUpdated {
                    taskDispatchGroup.notify(queue: .main) {
                        queryDispatchGroup.notify(queue: .main) {
                            completion(self.usersAroundLocation)
                        }
                    }
                }
            }
            queryDispatchGroup.leave()
        }
    }
    
}
