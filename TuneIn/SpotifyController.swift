//
//  SpotifyController.swift
//  Test
//
//  Created by Ahmed Irtija on 2/27/24.
//

import Foundation
import SwiftUI
import SpotifyiOS
import Combine

struct Response: Codable {
    let tracks: Track
}

class SpotifyController: NSObject, ObservableObject {
    
    
    @Published var isAuthenticationFailed = false
    var hasAttemptedToAuthorize = false
    
    let spotifyClientID = Config.value(forKey: "SPOTIFY_CLIENT") ?? ""
    
    private var _configuration: SPTConfiguration?
       
    lazy var configuration: SPTConfiguration = {
           guard let redirectURI = URL(string: Config.value(forKey: "REDIRECT_URL") ?? "") else {
               fatalError("Error initializing RedirectURL")
           }
           
           let config = SPTConfiguration(
               clientID: spotifyClientID,
               redirectURL: redirectURI
           )
           
           _configuration = config
           return config
       }()
    
    override init() {
    }
    
    
    var accessToken: String? = nil
    var playURI = ""
    var image: UIImage? = nil
    
    private var connectCancellable: AnyCancellable?
    private var disconnectCancellable: AnyCancellable?
    
    

    
    func initialize() {
        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.connect()
            }
        
        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.disconnect()
            }
    }
        


    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    func authenticate() {
        hasAttemptedToAuthorize = false
        isAuthenticationFailed = false

        connect()
    }
    
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
    }
    
    
    func fetchArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.image = image
            }
        })
    }
    
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
              //  self?.update(playerState: playerState)
            }
        })
    }
    
    func getAccessTokenURL() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIConstants.authHost
        components.path = "/authorize"
        
        components.queryItems = APIConstants.authParams.map({URLQueryItem(name: $0, value: $1)})
        
        guard let url = components.url else { return nil }
        
        return URLRequest(url: url)
    }
    
    func createURLRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIConstants.apiHost
        components.path = "/me/player/currently-playing"
        
        guard let url = components.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        
        // Safely unwrap the Authorization token
        if let token = UserDefaults.standard.value(forKey: "Authorization") as? String {
            urlRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "GET"
            return urlRequest
        } else {
            // Handle the case where the token is nil or not a String
            print("Error: Authorization token not found or not a String")
            return nil
        }
    }
    
    func getCurrentlyPlayingTrack() async throws -> Track? {
        if let urlRequest = createURLRequest(){
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let results = try decoder.decode(Response.self, from: data)
            let currentSong = results.tracks
            return currentSong
        }
        return nil
    }

    
    private func connect() {
        // This check ensures that we only proceed with authorization if we haven't successfully obtained an access token.
        if self.accessToken == nil && !hasAttemptedToAuthorize {
            self.hasAttemptedToAuthorize = true
            self.appRemote.authorizeAndPlayURI("")
        } else if let _ = self.accessToken, !appRemote.isConnected {
            // If we have an accessToken and are not connected, attempt to connect.
            appRemote.connect()
        }
    }
    
    
    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
}


extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.pause(nil)
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
}


extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        // This function is a no-op and can be removed or implemented if needed for app functionality beyond login.
    }

}

