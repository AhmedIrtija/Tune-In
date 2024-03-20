//
//  SettingsViewModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/20/24.
//

import Foundation
import SwiftUI
import PhotosUI

enum ImageSaveError: Error {
    case dataLoadingFailed
}

@MainActor
final class SettingsViewModel: ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func saveProfileImage(item: PhotosPickerItem, userId: String) async throws -> URL {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw ImageSaveError.dataLoadingFailed
        }
        let (path, _) = try await StorageManager.shared.saveImage(data: data, userId: userId)
        return try await StorageManager.shared.getImageUrl(userId: userId, path: path)
    }
}
