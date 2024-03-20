//
//  StorageManager.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/18/24.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getImageUrl(userId: String, path: String) async throws -> URL {
        try await Storage.storage().reference(withPath: path).downloadURL()
    }

    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/png"
        
        let path = "\(UUID().uuidString).png"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)

    }
    
}
