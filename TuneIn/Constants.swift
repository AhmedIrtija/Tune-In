//
//  Constants.swift
//  TuneIn
//
//  Created by Ashani Sinha on 2/21/24.
//
import Foundation

enum APIConstants {
    static let apiHost = "api.spotify.com"
    static let authHost = "accounts.spotify.com"
    static let clientId = "251fb800ac914bd094ce79cce00d24ae"
    static let clientSecret = "da1029132bb64990a898ceae6367a8e8"
    static let redirectUri = "spotify-ios-quick-start://spotify-login-callback"
    static let responseType = "token"
    static let scopes = "user-read-private"
   
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_uri": redirectUri,
        "scope": scopes
    ]
}
