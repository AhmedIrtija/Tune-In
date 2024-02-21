//
//  MapView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI
import MapKit

struct CustomMapAnnotation {
    var title: String
    var coordinate: CLLocationCoordinate2D
    var imageName: String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}


struct MapView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapStyle: Int = 0
    @StateObject private var locationManager = LocationManager()
    @State private var selectedRadius: Double = 1.0
    
    let distances: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]     // in miles
    
    let customMapAnnotations: [CustomMapAnnotation] = [
        // within 1 mile
        CustomMapAnnotation(
            title: "Bookhead",
            coordinate: CLLocationCoordinate2D(latitude: 38.53973870960561, longitude: -121.74989133055733),
            imageName: "BookheadImage"
        ),
        CustomMapAnnotation(
            title: "Eye on Mrak",
            coordinate: CLLocationCoordinate2D(latitude: 38.537927163335574, longitude: -121.74943975806444),
            imageName: "EyeOnMrakImage"
        ),
        CustomMapAnnotation(
            title: "Stargazer",
            coordinate: CLLocationCoordinate2D(latitude: 38.542050297019934, longitude: -121.74802530395576),
            imageName: "StargazerImage"
        ),
        CustomMapAnnotation(
            title: "Yin & Yang",
            coordinate: CLLocationCoordinate2D(latitude: 38.53936629323357, longitude: -121.74793264407816),
            imageName: "YinYangImage"
        ),
        // outside 1 mile
        CustomMapAnnotation(
            title: "Crunchy Cat",
            coordinate: CLLocationCoordinate2D(latitude: 38.526750890398525, longitude: -121.74134733532429),
            imageName: "CrunchyCatImage"
        ),
        CustomMapAnnotation(
            title: "Happy Cat",
            coordinate: CLLocationCoordinate2D(latitude: 38.55956891371994, longitude: -121.74857138735918),
            imageName: "HappyCatImage"
        )
    ]
    
    var selectedMapStyle: MapStyle {
        return switch(mapStyle) {
            case 0: .standard(elevation: .realistic)
            case 1: .hybrid(elevation: .realistic)
            case 2: .imagery(elevation: .realistic)
            default: .standard(elevation: .realistic)
        }
    }
    
    @Namespace var mapScope
    
    var body: some View {
        ZStack {
            Map(position: $position, scope: mapScope) {
                if let location = locationManager.userLocation {
                    MapCircle(
                        center: location.coordinate,
                        radius: selectedRadius * 1609.34    // in meters, = 1 mile
                    )
                    .stroke(Color.green, lineWidth: 4.0)
                    .foregroundStyle(Color.green.opacity(0.4))
                }
                    
                ForEach(customMapAnnotations.indices, id:\.self) { index in
                    let annotation = customMapAnnotations[index]
                    if let userLocation = locationManager.userLocation {
                        let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                        let distance = userLocation.distance(from: annotationLocation)
                        let miles = distance / 1609.34 // Convert meters to miles
                        if miles <= selectedRadius {
                            Annotation(annotation.title, coordinate: annotation.coordinate) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
//                                        .stroke(Color.black, lineWidth: 4.0)
                                        .frame(width: 36.0, height: 36.0)
                                    Circle()
                                        .fill(Color.green)
//                                        .stroke(Color.black, lineWidth: 4.0)
                                        .frame(width: 33.0, height: 33.0)
                                    Image(customMapAnnotations[index].imageName)
                                        .resizable()
                                        .frame(width: 30.0, height: 30.0)
                                        .foregroundStyle(Color.white)
                                        .background(Color.black)
                                        .clipShape(.circle)
                                }
                            }
                        }
                    }
                }
            }
            .mapStyle(selectedMapStyle)
            .mapControlVisibility(.hidden)
            .overlay(alignment: .topTrailing) {
                VStack {
                    Menu {
                        ForEach(distances, id: \.self) { distance in
                            Button(action: {
                                selectedRadius = distance
                            }) {
                                Text("\(Int(distance)) mi")
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.white)
                                .frame(width: 48, height: 48)
                            VStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22.0, height: 22.0)
                                    .foregroundStyle(Color.blue)
                                Text("\(Int(selectedRadius)) mi")
                                    .font(.system(size: 10.0))
                                    .foregroundStyle(Color.blue)
                            }
                        }
                    }
                }
                .padding(12.0)
        }
            .overlay(alignment: .bottomTrailing) {
                VStack {
                    MapUserLocationButton(scope: mapScope)
                    MapPitchToggle(scope: mapScope)
                        .mapControlVisibility(.visible)
                    MapCompass(scope: mapScope)
                        .mapControlVisibility(.visible)
                }
                .padding(12.0)
                .buttonBorderShape(.circle)
            }
        }
        .mapScope(mapScope)
        
        Picker("", selection: $mapStyle) {
            Text("Standard").tag(0)
            Text("Hybrid").tag(1)
            Text("Imagery").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
#Preview {
    MapView()
}
