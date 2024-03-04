//
//  LoadingView.swift
//  TuneIn
//
//  Created by Ashani Sinha on 3/3/24.
//

import Foundation
import SwiftUI

struct LoadingView : View {
    
    @State var openView = false
    var finalURL = SpotifyController.shared.getAccessTokenURL()
    
    var body: some View {
        ZStack {
            Text("Loading...")
            if let unwrappedURLRequest = finalURL {
                if let unwrappedURL = unwrappedURLRequest.url {
                    WebView(url: unwrappedURL)
                        .onAppear {
                            Task {
                                //load data on appear
                                // apply an overlay for loading screen
                                let song = try await SpotifyController.shared.getCurrentlyPlayingTrack()
                                print(song?.name as Any)
                            }
                        }
                }
            }
        }
        .overlay {
                ZStack {
                    Color(white: 0, opacity: 0.75)
                    ProgressView().tint(.white)
                }
        }
    }
}
