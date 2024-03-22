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
import ConfettiSwiftUI
import Combine


struct MapView: View {
    @EnvironmentObject var userModel: UserModel
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var rootViewType: RootViewType
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject var spotifyController = SpotifyController()
    
    let pub = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
    
    @State private var isInteractionDisabled: Bool = false
    
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
    
    @State private var averageVibeScore: Double = 0.0
    @State private var showMoodOverlay: Bool = false
    @State private var moodDescription: String = ""
    @State private var counter: Int = 0
    @State private var mood: String = ""

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isPaused = false
  
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
    
    private func calculateMood() async {
        await fetchAudioFeaturesAndCalculateAverage()
        mood = describeMood(for: averageVibeScore)
        moodDescription = "Vibe around you is \(mood)"
        showMoodOverlay = true
        counter += 1  // This will trigger the confetti cannon
    }
    
    func getCurrentTrack() {
        Task {
            do {
                if let fetchedTrack = try await spotifyController.fetchCurrentPlayingTrack() {
                    track = fetchedTrack
//                    print (track?.name ?? "No track name")
                    trackFilled = (true && showPopUp)
                    try await userModel.setCurrentTrack(track: fetchedTrack)
//                    let vibe = try await spotifyController.fetchAudioFeatures()
//                    try await userModel.setValence(valence: vibe ?? "")
                }
            } catch {
                print("Failed to fetch current track: \(error)")
            }
        }
    }
    
    func fetchAudioFeaturesAndCalculateAverage() async {
        var totalVibeScore = 0.0
        var count = 0
        
        for user in viewModel.usersAroundLocation {
            do {
                if let vibeScore = try await spotifyController.fetchAudioFeatures() {
                    totalVibeScore += Double(vibeScore) ?? 0.0
                    count += 1
                }
            } catch {
                print("Error fetching audio features: \(error)")
            }
        }
        
        if count > 0 {
            averageVibeScore = totalVibeScore / Double(count)
        }
    }

    func playMusic(with track: Track?) {
        // play new audio snippet
        if let currentTrack = track {
            guard let previewURL = URL(string: currentTrack.preview_url ?? "") else {
                print("Invalid preview URL")
                return
            }
            
            player = AVPlayer(url: previewURL)
            player?.play()
            isPlaying = true
        }
    }
    
    func pauseMusic() {
        if let player = player, player.timeControlStatus != .playing {
            player.pause()
            isPlaying = false
        }
    }
    
    func stopMusic() {
        if let player = player, player.timeControlStatus != .paused {
            player.pause()
            player.replaceCurrentItem(with: nil)
            isPlaying = false

        }
    }
    
    @Namespace var mapScope
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if showMoodOverlay {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            counter += 1
                            withAnimation {
                                showMoodOverlay = false
                            }
                        }

                    Text(moodDescription)
                        .font(.custom("Damion", size: 45))
                        .foregroundColor(Color.green)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .frame(alignment: .center)
                }
                .transition(.scale)
                .zIndex(1)
            }


            
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
                                        isInteractionDisabled: isInteractionDisabled,
                                        onPlayButtonPressed: {
                                            // if there's already an AVPlayer instance playing, stop it and reset.
                                            stopMusic()
                                            
                                            // check if popup is already displayed
                                            if showPopUp {
                                                // update track on popup
                                                withAnimation {
                                                    popUpTrack = user.currentTrack
                                                }
                                                // play new music
                                                playMusic(with: popUpTrack)

                                            } else {
                                                // disable interaction
                                                isInteractionDisabled = true
                                                
                                                // show popup
                                                popUpTrack = user.currentTrack
                                                withAnimation {
                                                    showPopUp = true
                                                }
                                                
                                                // enable interaction after popup animation is finished
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    isInteractionDisabled = false // Re-enable interaction
                                                }
                                                
                                                // play new music
                                                playMusic(with: popUpTrack)
                                            }

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
                            TitleBarView(showProfileView: $showProfileView, showTitleBar: $showTitleBar, imageUrl: currentUser.imageUrl ?? "", calculateMoodAction: calculateMood)
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
                Task {
                    await fetchAudioFeaturesAndCalculateAverage()
                }
            }
            .onReceive(locationManager.$userLocation) { userLocation in
                // listen to users around location and get current track
                if let location = userLocation {
                    Task {
                        try await viewModel.listenToUsersAroundLocation(location: location)
                        getCurrentTrack()
                        await fetchAudioFeaturesAndCalculateAverage()
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
                        await fetchAudioFeaturesAndCalculateAverage()
                    }
                }
            }
            .confettiCannon(counter: $counter, num: 100, confettiSize: 20, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
            .onChange(of: selectedUser) {
                if let _ = selectedUser {
                    showProfileViewSheet = true
                }
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
                    stopMusic()
                }
            }
            .sheet(isPresented: $showListView) {
                ListView(usersAroundLocation: viewModel.usersAroundLocation)
            }
            .sheet(isPresented: $showProfileViewSheet, onDismiss: {
                selectedUser = nil
            }) {
                if let user = selectedUser {
                    ProfileView(rootViewType: $rootViewType, user: user, isSheet: true)
                        .presentationDetents([.medium])
                }
            }
            .popup(isPresented: $showPopUp) {
                SongPopUpView(showPopUp: $showPopUp, popUpTrack: popUpTrack, isPlaying: isPlaying) {
                    if isPlaying {
                        player?.pause()
                        isPaused = true
                    } else {
                        player?.play()
                        isPaused = false
                    }
                    isPlaying.toggle()
                }
            }
            customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .closeOnTapOutside(false)
            }
        }
        .onReceive(pub) { _ in
            if !isPaused {
                showPopUp = false
            }
        }
    }
}

struct PlayPauseButtonView: View {
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.textGray)
        }
        .padding(.trailing, 20)
    }
}


struct SongPopUpView: View {
    @Binding var showPopUp: Bool
    var popUpTrack: Track?
    var isPlaying: Bool
    var togglePlayPause: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                // album image
                if let currentTrack = popUpTrack {
                    AsyncImage(url: URL(string: currentTrack.albumUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "music.note.list")
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.horizontal, 10)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.backgroundGray)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "music.note.list")
                            .foregroundStyle(Color.textGray)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal, 10)
                }
                
                // track info
                VStack(alignment: .leading) {
                    if let currentTrack = popUpTrack {
                        Text(currentTrack.name)
                            .foregroundStyle(Color.textGray)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.bottom, 2)
                        Text("by \(currentTrack.artist)")
                            .foregroundStyle(Color.textGray)
                            .font(.system(size: 12, weight: .light))
                        Text("on \(currentTrack.album)")
                            .foregroundStyle(Color.textGray)
                            .font(.system(size: 12, weight: .light))
                    } else {
                        Text("No song available")
                            .foregroundStyle(Color.textGray)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                Spacer()
                
                // play or pause button
                if let _ = popUpTrack {
                    PlayPauseButtonView(isPlaying: isPlaying, action: togglePlayPause)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.cornerRadius(10))
            .shadow(color: Color.backgroundGray.opacity(0.5), radius: 40, x: 0, y: 12)
        }
        .padding(.horizontal)
    }
}

struct TitleBarView: View {
    @Binding var showProfileView: Bool
    @Binding var showTitleBar: Bool
    let imageUrl: String
    
    let calculateMoodAction: () async -> Void

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
                    Button(action: {
                        Task {
                            await calculateMoodAction()
                        }
                    }) {
                        Text("Vibe Check")
                            .font(.custom("Avenir", size: 14))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.customGreen)
                            .cornerRadius(15)
                    }
                    .shadow(radius: 3)
                
                    
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
    var isInteractionDisabled: Bool
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
        .allowsHitTesting(!isInteractionDisabled)
        
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
        .transition(.blurReplace)
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

struct MoodDescriptor {
    let range: ClosedRange<Double>
    let name: String
}

let moodDescriptors: [MoodDescriptor] = [
    MoodDescriptor(range: 0.0...0.1, name: "Deeply Mellow"),
    MoodDescriptor(range: 0.1...0.2, name: "Softly Serene"),
    MoodDescriptor(range: 0.2...0.3, name: "Muted Melancholy"),
    MoodDescriptor(range: 0.3...0.4, name: "Easy-Going Elegance"),
    MoodDescriptor(range: 0.4...0.5, name: "Moderate Moodiness"),
    MoodDescriptor(range: 0.5...0.6, name: "Balanced Harmony"),
    MoodDescriptor(range: 0.6...0.7, name: "Groovy Glow"),
    MoodDescriptor(range: 0.7...0.8, name: "Vibrant Vibes"),
    MoodDescriptor(range: 0.8...0.9, name: "Euphoric Energy"),
    MoodDescriptor(range: 0.9...1.0, name: "Peak Positivity")
]


func describeMood(for value: Double) -> String {
    for descriptor in moodDescriptors {
        if descriptor.range.contains(value) {
            return descriptor.name
        }
    }
    return "Undefined"
}




//#Preview {
//    NavigationStack {
//        MapView(rootViewType: .constant(.mapView))
//    }
//}
