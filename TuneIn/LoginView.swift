//
//  ContentView.swift
//  Test
//
//  Created by Ahmed Irtija on 2/26/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var spotifyController: SpotifyController

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            if !spotifyController.isAuthenticationFailed {
                Button("Authenticate Again") {
                    spotifyController.authenticate()
                }
            }
        }
        .padding()
    }
}

struct Config {
    private static var configDict: [String: Any]? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Config.plist file not found")
        }
        return dict
    }

    static func value(forKey key: String) -> String? {
        return configDict?[key] as? String
    }
}


#Preview {
    LoginView(spotifyController: SpotifyController())
}
