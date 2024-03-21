//
//  ProfileViewModel.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/20/24.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userLocation: CLLocation?
    
    func setUserLocation(location: GeoPoint) {
        self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    func getLocationAddress(completion: @escaping (String?) -> Void) {
        let geoCoder = CLGeocoder()
        guard let location = self.userLocation else {
            completion(nil)
            return
        }

        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let placeMark = placemarks?.first else {
                completion(nil)
                return
            }

            // Construct the address string
            var addressString = ""

            // City
            if let city = placeMark.locality {
                addressString += city + ", "
            }
            // State
            if let administrativeArea = placeMark.administrativeArea {
                addressString += administrativeArea + ", "
            }
            // Country
            if let country = placeMark.country {
                addressString += country
            }

            // Remove trailing ", " if present
            if addressString.hasSuffix(", ") {
                addressString = String(addressString.dropLast(2))
            }

            completion(addressString) // return the address string
        })
    }
}
