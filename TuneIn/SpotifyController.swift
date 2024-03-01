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

class SpotifyController: NSObject, ObservableObject {
    
    
    @Published var isAuthenticationFailed = false
    var hasAttemptedToAuthorize = false
    
    let spotifyClientID = Config.value(forKey: "SPOTIFY_CLIENT") ?? ""
    let spotifyRedirectURL = URL(string: Config.value(forKey: "REDIRECT_URL") ?? "")!
    
    var accessToken: String? = nil
    var playURI = ""
    
    private var connectCancellable: AnyCancellable?
    private var disconnectCancellable: AnyCancellable?
    
    
    override init() {
        
    }
    
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
    
    
    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID ,
        redirectURL: spotifyRedirectURL
    )

    
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
