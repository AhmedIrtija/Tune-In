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
    private let spotifyClientID = "251fb800ac914bd094ce79cce00d24ae"
    private let spotifyRedirectURL = "spotify-ios-tune-in://spotify-login-callback"
    private lazy var sessionManager: SessionManager = {
        let configuration = Configuration(clientID: spotifyClientID, redirectURLString: spotifyRedirectURL)
        return SessionManager(configuration: configuration)
    }()

    init() {
        sessionManager.delegate = self
    }
}

extension SpotifyController {
    func startAuthorizationCodeProcess() {
        let scopes: Scope = .playlistReadPrivate
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
        state = .success("Authorization Succeeded")
    }
}
