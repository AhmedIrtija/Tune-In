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

struct DBUser: Codable {
    let userId: String
    var name: String
    var imageUrl: String?
    var currentTrack: Track?
    var location: GeoPoint?
    var geohash: String?        // database only
    let date_created: Date?     // database only
    
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
        geohash: String? = nil,
        date_created: Date? = nil
    ) {
        self.userId = userId
        self.name = name
        self.imageUrl = imageUrl
        self.currentTrack = currentTrack
        self.location = location
        self.geohash = geohash
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
    
    mutating func updateLocationAndGeohash(newLatitude: Double, newLongitude: Double) {
        location = GeoPoint(latitude: newLatitude, longitude: newLongitude)
        geohash = GFUtils.geoHash(forLocation: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude))
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name = "name"
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
    
    private func fetchMatchingDocs(from query: Query, center: CLLocationCoordinate2D, radius: Double) async throws -> [QueryDocumentSnapshot] {     // radius in meters
        let snapshot = try await query.getDocuments()
        
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
    
    func getPeopleAroundUser(center: CLLocationCoordinate2D, radius: Double) async throws -> [User] {     // radius in meters
        // set query bounds
        let queryBounds = GFUtils.queryBounds(forLocation: center, withRadius: radius)
        let queries = queryBounds.map { bound -> Query in
            return userCollection
                    .order(by: "geohash")
                    .start(at: [bound.startValue])
                    .end(at: [bound.endValue])
        }
        
        do {
            // get documents within specified radius
            let matchingDocs = try await withThrowingTaskGroup(of: [QueryDocumentSnapshot].self) { group -> [QueryDocumentSnapshot] in
                for query in queries {
                    group.addTask {
                        try await self.fetchMatchingDocs(from: query, center: center, radius: radius)
                    }
                }
                var matchingDocs = [QueryDocumentSnapshot]()
                for try await documents in group {
                      matchingDocs.append(contentsOf: documents)
                }
                return matchingDocs
            }
            
            // get list of User objects within specified radius
            var usersInsideRadius = [User]()
            for currentDoc in matchingDocs {
                if let userId = currentDoc.data()["user_id"] as? String {
                    print(userId)
                    let currentDBUser = try await getUser(userId: userId)
                    let currentUser = User(dbUser: currentDBUser)
                    usersInsideRadius.append(currentUser)
                }
            }
            
            return usersInsideRadius
        } catch {
            print("Unable to fetch snapshot data. \(error)")
            throw error
        }
    }
}
