//
//  MapView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI
import MapKit
import PopupView
import AVKit

struct MapView: View {
    @EnvironmentObject var userModel: UserModel
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var rootViewType: RootViewType
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject var spotifyController = SpotifyController()
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapStyle: Int = 0
    
    @State private var showProfileView: Bool = false
    @State private var showProfileViewSheet: Bool = false

    @State private var showPopUp: Bool = false
    @State private var showTitleBar: Bool = true
    @State private var showListView: Bool = false
    
    @State private var previousLocation: CLLocation?
    @State private var selectedUser: AppUser?

    @State var track: Track? = nil
    @State var trackFilled = false
    @State var popUpTrack : Track?
    
    let moveDistanceThreshold: CLLocationDistance = 10.0     // ten meters
    let distances: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]     // in miles
    
    var selectedMapStyle: MapStyle {
        return switch(mapStyle) {
            case 0: .standard(elevation: .realistic)
            case 1: .hybrid(elevation: .realistic)
            case 2: .imagery(elevation: .realistic)
            default: .standard(elevation: .realistic)
        }
    }
    
    func getCurrentTrack() {
        Task {
            do {
                if let fetchedTrack = try await spotifyController.fetchCurrentPlayingTrack() {
                    track = fetchedTrack
                    print (track?.name ?? "No track name")
                    trackFilled = (true && showPopUp)
                    try await userModel.setCurrentTrack(track: fetchedTrack)
                }
            } catch {
                print("Failed to fetch current track: \(error)")
            }
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
                        // display green circle around user
                        if let location = locationManager.userLocation {
                            MapCircle(
                                center: location.coordinate,
                                radius: viewModel.selectedRadius * 1609.34    // in meters, = 1 mile
                            )
                            .foregroundStyle(Color.customGreen.opacity(0.4))
                        }
                        
                        // display users on map
                        ForEach(viewModel.usersAroundLocation.indices, id:\.self) { index in
                            let user = viewModel.usersAroundLocation[index]
                            if let userLocation = user.location {
                                let userCoordinates = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
                                Annotation(user.name, coordinate: userCoordinates) {
                                    UserMapAnnotationView(
                                        user: user,
                                        onPlayButtonPressed: {
                                            withAnimation {
                                                showPopUp = true
                                            }
                                            popUpTrack = user.currentTrack
                                        },
                                        onProfileImageTapped: {
                                            selectedUser = user
                                        })
                                }
                            }
                        }
                    }
                    .mapStyle(selectedMapStyle)
                    .mapControlVisibility(.hidden)
                    .overlay(alignment: .topTrailing) {
                        if let currentUser = userModel.currentUser {
                            TitleBarView(showProfileView: $showProfileView, showTitleBar: $showTitleBar, imageUrl: currentUser.imageUrl ?? "")
                                .navigationDestination(isPresented: $showProfileView) {
                                    ProfileView(rootViewType: $rootViewType, user: currentUser, isSheet: false)
                                }
                        }
                        
                    }
                    .overlay(alignment: .bottomLeading) {
                        MapCustomControlsView(mapStyle: $mapStyle, selectedRadius: $viewModel.selectedRadius, colorScheme: colorScheme, distances: distances)
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
                        .tint(Color.customGreen)
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
                            .foregroundStyle(Color.white)
                            .padding(10.0)
                            .frame(height: 55.0)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.customGreen)
                            .cornerRadius(10.0)
                    }
                }
                .padding([.top, .horizontal], 12.0)
            }
            .onAppear {
                // update map region
                if let userLocation = locationManager.userLocation {
                    let newRegion = viewModel.regionForUserLocation(userLocation: userLocation)
                    self.position = .region(newRegion)
                }
            }
            .onReceive(locationManager.$userLocation) { userLocation in
                // listen to users around location and get current track
                if let location = userLocation {
                    Task {
                        try await viewModel.listenToUsersAroundLocation(location: location)
                        getCurrentTrack()
                    }
                }
                
                // set new previous user location
                guard let currentUserLocation = userLocation else { return }
                guard let previousUserLocation = previousLocation else {
                    previousLocation = currentUserLocation
                    Task {
                        try await userModel.setLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                    }
                    return
                }
                
                // update user location after moving distance >= 10 meters
                let distance = currentUserLocation.distance(from: previousUserLocation)
                if distance >= moveDistanceThreshold {
                    previousLocation = currentUserLocation
                    Task {
                        try await userModel.setLocation(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                    }
                }
                
            }
            .onChange(of: viewModel.selectedRadius) {
                // update map region
                if let userLocation = locationManager.userLocation {
                    let newRegion = viewModel.regionForUserLocation(userLocation: userLocation)
                    self.position = .region(newRegion)
                }
                
                // listen to users around location
                if let location = locationManager.userLocation {
                    Task {
                        try await viewModel.listenToUsersAroundLocation(location: location)
                    }
                }
            }
            .onChange(of: selectedUser) {
                showProfileViewSheet = true
            }
            .onChange(of: showPopUp) {
                if showPopUp {
                    withAnimation {
                        showTitleBar = false
                    }
                } else {
                    withAnimation {
                        showTitleBar = true
                    }
                }
            }
            .sheet(isPresented: $showListView) {
                ListView(usersAroundLocation: viewModel.usersAroundLocation)
            }
            .sheet(isPresented: $showProfileViewSheet) {
                if let user = selectedUser {
                    ProfileView(rootViewType: $rootViewType, user: user, isSheet: true)
                        .presentationDetents([.medium])
                }
            }
            .popup(isPresented: $showPopUp) {
                HStack(/*spacing: 0*/) {
                    //image here and then vstack with song name and artist
                    VStack{
                 //   ForEach(usersAroundLocation.indices, id:\.self) { index in
                        if let currenttrack = popUpTrack {
                            AsyncImage(url: URL(string: currenttrack.albumUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "music.note.list")
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 60, height: 60)
                            .padding(.trailing, 20)
                        }

                        // add a gif of music playing or some icon
                        Image(systemName: "speaker.wave.3")
                            .frame(width: 6.0, height: 6.0)
                    } // end vstack 1
                    .padding()
                    VStack(alignment: .leading, spacing: 2) {
                        if let currentTrack = popUpTrack {
                            Text(currentTrack.name)
                                .foregroundStyle(Color.textGray)
                                .font(.system(size: 18))
                            
                            Text("From \"\(currentTrack.album)\" by \"\(currentTrack.artist)\"")
                                .foregroundStyle(Color.textGray)
                                .font(.system(size: 18))
                        }

                    }
                }
                .padding()
                .background(Color.backgroundGray.cornerRadius(12))
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


struct TitleBarView: View {
    @Binding var showProfileView: Bool
    @Binding var showTitleBar: Bool
    let imageUrl: String
    
    var body: some View {
        if showTitleBar {
            ZStack {
                // background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.backgroundGray)
                    .frame(height: 72)
                
                // title
                Text("Tune In")
                    .font(Font.custom("Damion", size: 36))
                    .foregroundColor(.white)
                
                // profile button
                HStack {
                    Spacer()
                    ProfileButtonView(showProfileView: $showProfileView, imageUrl: imageUrl)
                        .padding(.trailing, 20)
                }
            }
            .transition(.blurReplace)
            .padding(.horizontal)
        }
    }
}


struct UserMapAnnotationView: View {
    var user: AppUser
    var onPlayButtonPressed: () -> Void
    var onProfileImageTapped: () -> Void

    var body: some View {
        // popup button
        Button(action: onPlayButtonPressed) {
            Image("playbutton")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .clipShape(Circle())
        }
        
        // user image
        Button(action: onProfileImageTapped) {
            ZStack {
                Circle()
                    .fill(Color.backgroundGray)
                    .frame(width: 58, height: 58)
                Circle()
                    .fill(Color.customGreen)
                    .frame(width: 52, height: 52)
                Circle()
                    .fill(Color.backgroundGray)
                    .frame(width: 50, height: 50)
                AsyncImage(url: URL(string: user.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } placeholder: {
                    Image("DefaultImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                }
            }
        }

    }
}

struct ProfileButtonView: View {
    @Binding var showProfileView: Bool
    let imageUrl: String

    var body: some View {
        Button(action: {
            showProfileView = true
        }) {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32.0, height: 32.0)
                    .foregroundStyle(Color.textGray)
                    .background(Color.backgroundGray)
                    .clipShape(Circle())
                    .padding(12.0)
            } placeholder: {
                Image("DefaultImage")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
                    .foregroundStyle(Color.textGray)
                    .background(Color.backgroundGray)
                    .clipShape(Circle())
                    .padding(12.0)
            }
        }
    }
}

struct MapCustomControlsView: View {
    @Binding var mapStyle: Int
    @Binding var selectedRadius: Double
    let colorScheme: ColorScheme
    let distances: [Double]
    
    var selectedMapStyleDescription: String {
        return switch(mapStyle) {
        case 0: "Standard"
        case 1: "Hybrid"
        case 2: "Imagery"
        default: "Standard"
        }
    }
    
    var body: some View {
        VStack {
            // map style selection button
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
                mapStyleButtonLabel()
            }
            
            // distance selection button
            Menu {
                ForEach(distances.reversed(), id: \.self) { distance in
                    Button(action: {
                        selectedRadius = distance
                    }) {
                        Text("\(Int(distance)) mi")
                    }
                }
            } label: {
                distanceButtonLabel()
            }
        }
        .padding(12.0)
        .padding(.bottom, 24.0)
    }
    
    @ViewBuilder
    private func mapStyleButtonLabel() -> some View {
        ZStack {
            Circle()
                .foregroundStyle(colorScheme == .dark ? Color.backgroundGray : Color.white)
                .frame(width: 48.0, height: 48.0)
            VStack {
                Image(systemName: "map.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20.0, height: 20.0)
                    .foregroundStyle(Color.customGreen)
                Text(selectedMapStyleDescription)
                    .font(.system(size: 8.0))
                    .foregroundStyle(Color.customGreen)
            }
        }
    }
    
    @ViewBuilder
    private func distanceButtonLabel() -> some View {
        ZStack {
            Circle()
                .foregroundStyle(colorScheme == .dark ? Color.backgroundGray : Color.white)
                .frame(width: 48.0, height: 48.0)
            VStack {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22.0, height: 22.0)
                    .foregroundStyle(Color.customGreen)
                Text("\(Int(selectedRadius)) mi")
                    .font(.system(size: 10.0))
                    .foregroundStyle(Color.customGreen)
            }
        }
    }
}



//#Preview {
//    NavigationStack {
//        MapView(rootViewType: .constant(.mapView))
//    }
//}
