//
//  Constants.swift
//  TuneIn
//
//  Created by Ashani Sinha on 2/21/24.
//
import Foundation
import SwiftUI

let accessTokenKey = "access-token-key"
let redirectUri = URL(string:"spotify-ios-quick-start://spotify-login-callback")
let spotifyClientId = "251fb800ac914bd094ce79cce00d24ae"
let spotifyClientSecretKey = "80ed8f1f0471498e9948b6e388a4851b"

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scopes: SPTScope = [
                            .userReadEmail, .userReadPrivate,
                            .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                            .streaming, .appRemoteControl,
                            .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                            .userLibraryModify, .userLibraryRead,
                            .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                            .userFollowRead, .userFollowModify,
                        ]
let stringScopes = [
                        "user-read-email", "user-read-private",
                        "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                        "streaming", "app-remote-control",
                        "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                        "user-library-modify", "user-library-read",
                        "user-top-read", "user-read-playback-position", "user-read-recently-played",
                        "user-follow-read", "user-follow-modify",
                    ]

struct Colors {
    static let black = Color(red: 0, green: 0, blue: 0)
    static let dark_gray = Color(red: 0.129, green: 0.129, blue: 0.129)
    static let gray = Color(red: 0.702, green: 0.702, blue: 0.702)
    static let white = Color(red: 1, green: 1, blue: 1)
    
    static let spotify_green = Color(red: 0.106, green: 0.725, blue: 0.329)
}
