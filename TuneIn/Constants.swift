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
    static let clientId = "3b028a6bf8154789ae148a0c03ef8e5e"
    static let clientSecret = "14bb0871f5424ef68bd9dac48244481a"
    static let redirectUri = "TuneIn://Test"
    static let responseType = "token"
    static let scopes = "user-read-private"
   
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_uri": redirectUri,
        "scope": scopes
    ]
}
