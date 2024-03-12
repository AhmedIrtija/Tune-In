//
//  SpotifyController.swift
//  TuneIn
//
//  Created by Ahmed Irtija on 3/11/24.
//

import SwiftUI
import SpotifyLogin

final class SpotifyController: ObservableObject {
    private let clientURLScheme = "spotify:"

    enum State: Equatable {
        case idle
        case success(String)
        case failure(String)
    }

    @Published private(set) var state: State = .idle
    private var accessToken: String?
    private let spotifyClientID = "3b028a6bf8154789ae148a0c03ef8e5e"
    private let spotifyRedirectURL = "TuneIn://Test"
    private let spotifyClientSecret = "14bb0871f5424ef68bd9dac48244481a"
    private lazy var sessionManager: SessionManager = {
        let configuration = Configuration(clientID: spotifyClientID, redirectURLString: spotifyRedirectURL)
        return SessionManager(configuration: configuration)
    }()

    init() {
        sessionManager.delegate = self
    }
    
    //URL request
    func createURLRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = APIConstants.apiHost
        components.path = "/v1/me/player/currently-playing"
        
        guard let url = components.url
        else {
            print("exit")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
    
        urlRequest.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpMethod = "GET"
        print("URL: \(urlRequest.url?.absoluteString ?? "N/A")")
        print("HTTP Method: \(urlRequest.httpMethod ?? "N/A")")
        print("AllHTTPHeaderFields: \(urlRequest.allHTTPHeaderFields ?? [:])")
        print("HTTP Body: \(String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) ?? "N/A")")
        return urlRequest
    }
}

extension SpotifyController {
    func startAuthorizationCodeProcess() {
        let scopes: Scope = .userReadCurrentlyPlaying
        sessionManager.startAuthorizationCodeProcess(with: scopes)
    }

    func open(url: URL) {
        let result = sessionManager.openURL(url)
        if !result {
            state = .failure("Authorization Failed")
        }
    }

    func setStateIdle() {
        state = .idle
    }
}

extension SpotifyController: SessionManagerDelegate {
    func sessionManager(manager: SessionManager, didFailWith error: Error) {
        state = .failure("Authorization Failed")
    }

    func sessionManager(manager: SessionManager, shouldRequestAccessTokenWith code: String) {
        requestAccessToken(authorizationCode: code)
        state = .success("Authorization Succeeded")
    }
    
    func requestAccessToken(authorizationCode code: String) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": spotifyRedirectURL,
            "client_id": spotifyClientID,
            "client_secret": spotifyClientSecret
        ]
        
        request.httpBody = parameters.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.state = .failure("Failed to request access token")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let accessTokenResponse = try decoder.decode(AccessTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.accessToken = accessTokenResponse.access_token
                    UserDefaults.standard.set(accessTokenResponse.access_token, forKey: "accessToken")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.state = .failure("Failed to decode access token")
                }
            }
        }
        
        task.resume()
    }
}

struct AccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String?
}
