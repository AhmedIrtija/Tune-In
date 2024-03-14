//
//  MapView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI
import MapKit
import PopupView

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
    @EnvironmentObject var userModel: UserModel
    @Binding var rootViewType: RootViewType
    @StateObject private var locationManager = LocationManager()
    @StateObject var viewModel = SpotifyController()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapStyle: Int = 0
    @State private var selectedRadius: Double = 1.0
    @State private var showProfileView: Bool = false
    @State private var showPopUp: Bool = false
    @State private var showListView: Bool = false
    @State private var usersAroundLocation: [AppUser] = []
    @State var track: Track? = nil
    @State private var previousLocation: CLLocation?
    let moveDistanceThreshold: CLLocationDistance = 1.0     // one meter
    
    let distances: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]     // in miles
    
    var selectedMapStyle: MapStyle {
        return switch(mapStyle) {
            case 0: .standard(elevation: .realistic)
            case 1: .hybrid(elevation: .realistic)
            case 2: .imagery(elevation: .realistic)
            default: .standard(elevation: .realistic)
        }
    }
    
    var selectedMapStyleDescription: String {
        return switch(mapStyle) {
            case 0: "Standard"
            case 1: "Hybrid"
            case 2: "Imagery"
            default: "Standard"
        }
    }
    
    @Namespace var mapScope
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
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
                            
                        ForEach(usersAroundLocation.indices, id:\.self) { index in
                            let otherUser = usersAroundLocation[index]
                            if let otherUserLocation = otherUser.location {
                                let otherUserCoordinates = CLLocationCoordinate2D(latitude: otherUserLocation.latitude, longitude: otherUserLocation.longitude)
                                Annotation(otherUser.name , coordinate: otherUserCoordinates) {
                                    //in loop and if statement
                                    Button(action:{
                                        showPopUp = true
                                        print("Button tapped!")
        
                                    }, label:
                                            {
                                        Image(uiImage: UIImage(imageLiteralResourceName: "SpotifyPlayButton"))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                            .clipShape(Circle())
                                    })
                                
                                    ZStack {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 36.0, height: 36.0)
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 33.0, height: 33.0)
                                        
                                            AsyncImage(url: URL(string: otherUser.imageUrl ?? "")) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 30.0, height: 30.0)
                                                    .foregroundStyle(Color.white)
                                                    .background(Color.black)
                                                    .clipShape(.circle)
                                            } placeholder: {
                                                Image(systemName: "person.circle")
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
                        Button(action: {
                            showProfileView = true
                        }) {
                            Image("DefaultImage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color.blue)
                                .frame(width: 40.0, height: 40.0)
                                .padding(12.0)
                        }
                        .navigationDestination(isPresented: $showProfileView) {
                            ProfileView(rootViewType: $rootViewType)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack {
                            Menu {
                                ForEach((0..<3).reversed(), id:\.self) { styleIndex in
                                    Button(action: {
                                        mapStyle = styleIndex
                                    }) {
                                        switch styleIndex {
                                            case 0: Text("Standard")
                                            case 1: Text("Hybrid")
                                            case 2: Text("Imagery")
                                            default: EmptyView()
                                        }
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(Color.blue)
                                        .frame(width: 48.0, height: 48.0)
                                    VStack {
                                        Image(systemName: "map.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20.0, height: 20.0)
                                            .foregroundStyle(Color.white)
                                        Text("\(selectedMapStyleDescription)")
                                            .font(.system(size: 8.0))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            }
                            
                            Menu {
                                ForEach(distances.reversed(), id: \.self) { distance in
                                    Button(action: {
                                        selectedRadius = distance
                                    }) {
                                        Text("\(Int(distance)) mi")
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(Color.blue)
                                        .frame(width: 48.0, height: 48.0)
                                    VStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 22.0, height: 22.0)
                                            .foregroundStyle(Color.white)
                                        Text("\(Int(selectedRadius)) mi")
                                            .font(.system(size: 10.0))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            }
                        }
                        .padding(12.0)
                        .padding(.bottom, 24.0)
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
                
                VStack {
                    Button(action: {
                        showListView = true
                    }) {
                        Text("EXPLORE MUSIC")
                            .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                            .foregroundColor(.white)
                            .padding(10.0)
                            .frame(height: 55.0)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.green)
                            .cornerRadius(10.0)
                    }
                }
                .padding([.top, .horizontal], 12.0)
            }
            .onReceive(locationManager.$userLocation) { userLocation in
                // * * * update user location * * * //
                guard let currentUserLocation = userLocation else { return }
                guard let previousUserLocation = previousLocation else {
                    previousLocation = currentUserLocation
                    Task {
                        try await userModel.setLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                    }
                    return
                }
                
                // if user moves > 1 meter, update user location on database
                let distance = currentUserLocation.distance(from: previousUserLocation)
                if distance >= moveDistanceThreshold {
                    previousLocation = currentUserLocation
                    Task {
                        try await userModel.setLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                    }
                }
                
                // * * * listen to users around location * * * //
                if let location = userLocation {
                    // listen to users around location
                    let myLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    Task {
                        do {
                            UserManager.shared.listenToPeopleAroundUser(center: myLocation, radius: selectedRadius * 1609.34) { updatedUsers in
                                for updatedUser in updatedUsers {
                                    if let existingIndex = usersAroundLocation.firstIndex(where: { $0.userId == updatedUser.userId }) {
                                        // update existing user
                                        usersAroundLocation[existingIndex] = updatedUser
                                    } else {
                                        // append new user
                                        usersAroundLocation.append(updatedUser)
                                    }
                                }
                                
                                // remove users that are not in updatedUsers
                                usersAroundLocation.removeAll { user in
                                    !updatedUsers.contains(where: { $0.userId == user.userId })
                                }
                            }
                        }
                        do {
                            if let fetchedTrack = try await viewModel.fetchCurrentPlayingTrack() {
                                track = fetchedTrack
                                try await userModel.setCurrentTrack(track: fetchedTrack)
                            }
                        } catch {
                            print("Failed to fetch current track: \(error)")
                        }
                    }
                }
            }
            .sheet(isPresented: $showListView) {
                ListView(usersAroundLocation: usersAroundLocation)
            }
            .popup(isPresented: $showPopUp) {
                HStack(/*spacing: 0*/) {
                    //image here and then vstack with song name and artist
                    VStack{
                        Image("MidnightsTalor")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40.0, height: 40.0)
                            .padding(2)
                        // add a gif of music playing or some icon
                        Image(systemName: "speaker.wave.3")
                            .frame(width: 6.0, height: 6.0)
                    } // end vstack 1
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Karma")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        
                        Text("From \"Midnights\" by Taylor Swift")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .opacity(0.8)
                    }
                }
                .padding(16)
                .background(Color.black.opacity(0.8).cornerRadius(12))
                .shadow(color: Color("9265F8").opacity(0.5), radius: 40, x: 0, y: 12)
                .padding(.horizontal, 16)
            }
            customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .closeOnTapOutside(true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(rootViewType: .constant(.mapView))
    }
}
