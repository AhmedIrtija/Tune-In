//
//  MapViewModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/20/24.
//

import Foundation
import MapKit

final class MapViewModel: ObservableObject {
    @Published var usersAroundLocation: [AppUser] = []
    @Published var selectedRadius: Double = 1.0

    func regionForUserLocation(userLocation: CLLocation) -> MKCoordinateRegion {
        let radiusInMeters = selectedRadius * 1609.34   // convert miles to meters
        let regionSpan = radiusInMeters * 2     // approximation to ensure the circle fits within the view
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: regionSpan, longitudinalMeters: regionSpan)
        return region
    }
    
    func listenToUsersAroundLocation(location: CLLocation) async throws {
        let myLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        do {
            UserManager.shared.listenToPeopleAroundUser(center: myLocation, radius: selectedRadius * 1609.34) { updatedUsers in
                for updatedUser in updatedUsers {
                    if let existingIndex = self.usersAroundLocation.firstIndex(where: { $0.userId == updatedUser.userId }) {
                        // update existing user
                        self.usersAroundLocation[existingIndex] = updatedUser
                    } else {
                        // append new user
                        self.usersAroundLocation.append(updatedUser)
                    }
                }
                
                // remove users that are not in updatedUsers
                self.usersAroundLocation.removeAll { user in
                    !updatedUsers.contains(where: { $0.userId == user.userId })
                }
            }
        }
    }



}
